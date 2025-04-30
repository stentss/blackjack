import pymysql
import os
from flask import Flask, render_template, request, redirect, session, jsonify, send_from_directory
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import uuid
from textblob import TextBlob

# Get the current directory (where the app is running)
BASE_DIR = os.path.abspath(os.path.dirname(__file__))

app = Flask(
    __name__,
    template_folder=os.path.join(BASE_DIR, '../public_html'),  # assumes public_html is one level up
    static_folder=os.path.join(BASE_DIR, '../public_html/static')
)

app.secret_key = 'cd147fb8a2bacb53c58c23ec089588e8d98438119044bdc7c986099dd0e9a79c'

# development purposes
# DB_HOST = '
# DB_USER = ''
# DB_PASSWORD = ''
# DB_NAME = ''

DB_HOST = os.getenv('DB_HOST')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_NAME = os.getenv('DB_NAME')

# Upload folder inside your project structure
UPLOAD_FOLDER = os.path.join(BASE_DIR, '../public_html/static/uploads')
ALLOWED_EXTENSIONS = {'pdf'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Create the upload folder if it doesn't exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def get_db_connection():
    # local connection
    # return pymysql.connect(
    #     user=DB_USER,
    #     password=DB_PASSWORD,
    #     database=DB_NAME,
    #     unix_socket='/var/run/mysqld/mysqld.sock',
    #     cursorclass=pymysql.cursors.DictCursor
    # )
    return pymysql.connect(
    host=DB_HOST,
    user=DB_USER,
    password=DB_PASSWORD,
    database=DB_NAME,
    port=3306,
    cursorclass=pymysql.cursors.DictCursor
    )

@app.route('/favicon.ico')
def favicon():
    return '', 204

@app.route('/')
def home():
    return render_template('index.html')

# checking for login when called
@app.route('/check_login')
def check_login():
    if 'user' in session:
        username = session['user']
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT Username, Email, Usertype FROM User WHERE Username = %s", (username,))
            user = cur.fetchone()
        conn.close()
        if user:
            return jsonify({"logged_in": True, "user": user})
    return jsonify({"logged_in": False})



# @app.route('/dashboard.html')
# def dashboard():
#     if 'user' not in session:
#         return redirect('/login.html')
#     return render_template('dashboard.html')

@app.route('/<page>')
def serve_page(page):
    if not page.endswith(".html"):
        return "Not Found", 404
    return render_template(page)

@app.route('/static/<path:filename>')
def static_files(filename):
    return send_from_directory("/home/rhnguyen/public_html/static", filename)

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data['username']
    email = data['email']
    password = generate_password_hash(data['password'])
    security_question = data['securityQuestion']
    security_answer = generate_password_hash(data['securityAnswer'])  # Hash answer

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO User (Username, Email, Password, Usertype, SecurityQuestion, SecurityAnswer)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (username, email, password, "player", security_question, security_answer)
        )
        conn.commit()
    conn.close()
    return jsonify({"message": "User registered successfully"}), 201

# login register pages

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data['username']
    password = data['password']

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Password FROM User WHERE Username = %s", (username,))
        user = cur.fetchone()
    conn.close()

    if user and check_password_hash(user['Password'], password):
        session['user'] = username
        return jsonify({"message": "Login successful", "redirect": "/"})
    else:
        return jsonify({"error": "Invalid credentials"}), 401

@app.route('/logout')
def logout():
    session.pop('user', None)
    return redirect('/login.html')

@app.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.json
    username = data.get('username')
    email = data.get('email')

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT SecurityQuestion FROM User WHERE Username = %s AND Email = %s", (username, email))
        user = cur.fetchone()
    conn.close()

    if user:
        return jsonify({"question": user['SecurityQuestion']})
    else:
        return jsonify({"error": "User not found or email mismatch"}), 404

@app.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.json
    username = data.get('username')
    answer = data.get('answer')
    new_password = data.get('new_password')

    if not username or not answer or not new_password:
        return jsonify({"error": "Missing fields"}), 400

    hashed_password = generate_password_hash(new_password)

    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT SecurityAnswer FROM User WHERE Username = %s", (username,))
            user = cur.fetchone()

            if user and check_password_hash(user['SecurityAnswer'], answer):
                cur.execute("UPDATE User SET Password = %s WHERE Username = %s", (hashed_password, username))
                conn.commit()
                return jsonify({"message": "Password reset successful"}), 200
            else:
                return jsonify({"error": "Incorrect answer"}), 401
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()


# topic

@app.route('/topic.html')
def topic_page():
    return render_template('topic.html')

@app.route('/submit-topic', methods=['POST'])
def submit_topic():
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 401

    data = request.json
    title = data.get('title')
    description = data.get('description')

    if not title or not description:
        return jsonify({"error": "Missing title or description"}), 400

    conn = get_db_connection()
    with conn.cursor() as cur:
        # Get the UserID from session username
        cur.execute("SELECT UserID FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()

        if not user:
            return jsonify({"error": "User not found"}), 404

        cur.execute("""
            INSERT INTO Topic (Title, Description, CreatedBy, CreatedAt)
            VALUES (%s, %s, %s, NOW())
        """, (title, description, user['UserID']))
        conn.commit()

    conn.close()
    return jsonify({"message": "Topic added successfully!"})

@app.route('/get-topics')
def get_topics():
    all_requested = request.args.get('all') == 'true'
    usertype = None

    if 'user' in session:
        conn = get_db_connection()
        with conn.cursor() as cur:
            cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
            result = cur.fetchone()
            if result:
                usertype = result['Usertype']
        conn.close()

    conn = get_db_connection()
    with conn.cursor() as cur:
        if all_requested and usertype == 'admin':
            cur.execute("SELECT * FROM Topic ORDER BY CreatedAt DESC")
        else:
            cur.execute("SELECT * FROM Topic WHERE IsApproved = TRUE ORDER BY CreatedAt DESC")
        topics = cur.fetchall()
    conn.close()

    return jsonify(topics)

@app.route('/approve-topic/<int:topic_id>', methods=['POST'])
def approve_topic(topic_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()
        if not user or user['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        cur.execute("UPDATE Topic SET IsApproved = TRUE WHERE TopicID = %s", (topic_id,))
        conn.commit()
    conn.close()

    return jsonify({"message": "Topic approved!"})

@app.route('/reject-topic/<int:topic_id>', methods=['POST'])
def reject_topic(topic_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()
        if not user or user['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        cur.execute("DELETE FROM Topic WHERE TopicID = %s", (topic_id,))
        conn.commit()
    conn.close()

    return jsonify({"message": "Topic rejected and deleted."})

@app.route('/get-topic/<int:topic_id>')
def get_single_topic(topic_id):
    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM Topic WHERE TopicID = %s", (topic_id,))
        topic = cur.fetchone()
    conn.close()
    return jsonify(topic)

@app.route('/get-topic-content/<int:topic_id>')
def get_topic_content(topic_id):
    approved_only = request.args.get('approved') == 'true'

    conn = get_db_connection()
    with conn.cursor() as cur:
        if approved_only:
            cur.execute("""
                SELECT * FROM EducationalContent 
                WHERE TopicID = %s AND IsApproved = 1
                ORDER BY CreatedAt DESC
            """, (topic_id,))
        else:
            cur.execute("""
                SELECT * FROM EducationalContent 
                WHERE TopicID = %s
                ORDER BY CreatedAt DESC
            """, (topic_id,))
        content = cur.fetchall()
    conn.close()
    return jsonify(content)


@app.route('/delete-topic/<int:topic_id>', methods=['POST'])
def delete_topic(topic_id):
    try:
        conn = get_db_connection()
        with conn.cursor() as cur:
            # First delete related content
            cur.execute("DELETE FROM EducationalContent WHERE TopicID = %s", (topic_id,))
            # Then delete the topic
            cur.execute("DELETE FROM Topic WHERE TopicID = %s", (topic_id,))
            conn.commit()
        return jsonify({"success": True})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)})
    finally:
        conn.close()

# content
@app.route('/submit-content', methods=['POST'])
def submit_content():
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    title = request.form['title']
    content_type = request.form['content_type']
    content_url = request.form.get('content_url')
    content_text = request.form.get('content_text')
    topic_id = request.form['topic_id']

    # Handle file upload
    uploaded_file = request.files.get('content_file')
    if uploaded_file and allowed_file(uploaded_file.filename):
        #filename = secure_filename(uploaded_file.filename)
        filename = str(uuid.uuid4()) + '_' + secure_filename(uploaded_file.filename)

        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        uploaded_file.save(file_path)
        content_url = '/static/uploads/' + filename

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT UserID FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()
        if not user:
            return jsonify({"error": "Invalid user"}), 403

        cur.execute("""
            INSERT INTO EducationalContent 
            (Title, ContentType, ContentURL, ContentText, CreatedAt, CreatedBy, TopicID)
            VALUES (%s, %s, %s, %s, CURDATE(), %s, %s)
        """, (title, content_type, content_url, content_text, user['UserID'], topic_id))

        conn.commit()
    conn.close()

    return redirect(f"/topic.html?id={topic_id}")

@app.route('/get-content/<int:content_id>')
def get_content(content_id):
    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT ec.*, t.TopicID
            FROM EducationalContent ec
            JOIN Topic t ON ec.TopicID = t.TopicID
            WHERE ec.ID = %s
        """, (content_id,))
        content = cur.fetchone()
    conn.close()
    return jsonify(content)

@app.route('/delete-content/<int:content_id>', methods=['POST'])
def delete_content(content_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
            user = cur.fetchone()
            if not user or user['Usertype'] != 'admin':
                return jsonify({"error": "Forbidden"}), 403
            cur.execute("DELETE FROM Comment WHERE EducationalContent_ID = %s", (content_id,))
            conn.commit()
            cur.execute("DELETE FROM EducationalContent WHERE ID = %s", (content_id,))
            conn.commit()
        return jsonify({"message": "Content and associated comments deleted successfully."})
    finally:
        conn.close()


# approve content

@app.route('/approve-content.html')
def approve_content_page():
    if 'user' not in session:
        return redirect('/login.html')
    
    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        result = cur.fetchone()
        if not result or result['Usertype'] != 'admin':
            return redirect('/')
    conn.close()

    return render_template('approve-content.html')

@app.route('/get-unapproved-content')
def get_unapproved_content():
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        result = cur.fetchone()
        if not result or result['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        cur.execute("""
            SELECT ec.*, t.Title AS TopicTitle, u.Username AS Author
            FROM EducationalContent ec
            JOIN Topic t ON ec.TopicID = t.TopicID
            JOIN User u ON ec.CreatedBy = u.UserID
            WHERE ec.IsApproved = FALSE
            ORDER BY ec.CreatedAt DESC
        """)
        rows = cur.fetchall()
    conn.close()

    return jsonify(rows)

@app.route('/approve-content/<int:content_id>', methods=['POST'])
def approve_content(content_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        result = cur.fetchone()
        if not result or result['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        cur.execute("UPDATE EducationalContent SET IsApproved = TRUE WHERE ID = %s", (content_id,))
        conn.commit()
    conn.close()

    return jsonify({"message": "Content approved."})

@app.route('/reject-content/<int:content_id>', methods=['POST'])
def reject_content(content_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        result = cur.fetchone()
        if not result or result['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        cur.execute("DELETE FROM EducationalContent WHERE ID = %s", (content_id,))
        conn.commit()
    conn.close()

    return jsonify({"message": "Content rejected and deleted."})

# comment

@app.route('/submit-comment', methods=['POST'])
def submit_comment():
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    data = request.get_json()
    comment_text = data.get('comment')
    content_id = data.get('content_id')

    if not comment_text or not content_id:
        return jsonify({"error": "Missing fields"}), 400

    # Sentiment analysis
    blob = TextBlob(comment_text)
    sentiment = blob.sentiment.polarity  # -1 (bad) to +1 (good)

    if sentiment < -0.1:  # adjust threshold
        return jsonify({"error": "Comment seems too negative. Please be respectful."}), 400

    conn = get_db_connection()
    with conn.cursor() as cur:
        # Get user ID
        cur.execute("SELECT UserID FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()

        if not user:
            return jsonify({"error": "User not found"}), 403

        # Insert comment
        cur.execute("""
            INSERT INTO Comment (CommentText, CreatedAt, UserID, EducationalContent_ID)
            VALUES (%s, NOW(), %s, %s)
        """, (comment_text, user['UserID'], content_id))
        conn.commit()
    conn.close()

    return jsonify({"message": "Comment posted successfully."})

@app.route('/get-comments/<int:content_id>')
def get_comments(content_id):
    conn = get_db_connection()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT c.CommentID, c.CommentText, c.CreatedAt, u.Username
            FROM Comment c
            JOIN User u ON c.UserID = u.UserID
            WHERE c.EducationalContent_ID = %s
            ORDER BY c.CreatedAt DESC
        """, (content_id,))
        comments = cur.fetchall()
    conn.close()
    return jsonify(comments)

@app.route('/delete-comment/<int:comment_id>', methods=['POST'])
def delete_comment(comment_id):
    if 'user' not in session:
        return jsonify({"error": "Unauthorized"}), 403

    conn = get_db_connection()
    with conn.cursor() as cur:
        # Check if user is admin
        cur.execute("SELECT Usertype FROM User WHERE Username = %s", (session['user'],))
        user = cur.fetchone()

        if not user or user['Usertype'] != 'admin':
            return jsonify({"error": "Forbidden"}), 403

        # Delete comment
        cur.execute("DELETE FROM Comment WHERE CommentID = %s", (comment_id,))
        conn.commit()
    conn.close()

    return jsonify({"message": "Comment deleted successfully."})


# account settings

# /check-username route
@app.route('/check-username')
def check_username():
    username = request.args.get('username')
    if not username:
        return jsonify({'available': False})

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM User WHERE Username = %s", (username,))
            existing = cursor.fetchone()
            if existing:
                return jsonify({'available': False})
            else:
                return jsonify({'available': True})
    finally:
        conn.close()

# /update-account route
@app.route('/update-account', methods=['POST'])
def update_account():
    if 'user' not in session:
        return jsonify({'success': False, 'error': 'Not logged in.'})

    data = request.get_json()
    current_password = data.get('currentPassword')
    new_password = data.get('newPassword')

    if not current_password or not new_password:
        return jsonify({'success': False, 'error': 'Missing fields.'})

    username = session['user']

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # Get user's current hashed password based on username
            cursor.execute("SELECT Password FROM User WHERE Username = %s", (username,))
            user = cursor.fetchone()

            if not user:
                return jsonify({'success': False, 'error': 'User not found.'})

            stored_password_hash = user['Password']

            # verify
            if not check_password_hash(stored_password_hash, current_password):
                return jsonify({'success': False, 'error': 'Current password is incorrect.'})

            new_password_hash = generate_password_hash(new_password, method='scrypt')

            cursor.execute(
                "UPDATE User SET Password = %s WHERE Username = %s",
                (new_password_hash, username)
            )
            conn.commit()

            return jsonify({'success': True})
    finally:
        conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8047)


