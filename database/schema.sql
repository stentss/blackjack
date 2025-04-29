DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS Session;
DROP TABLE IF EXISTS Statistics;
DROP TABLE IF EXISTS Comment;
DROP TABLE IF EXISTS EducationalContent;
DROP TABLE IF EXISTS Topic;

-- Created by Vertabelo (http://vertabelo.com)
-- Updated: 2025-03-31 - Blackjack Mastery Schema

-- ========================
-- TABLES
-- ========================

-- Table: User
CREATE TABLE User (
    UserID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(255) NOT NULL,
    Username VARCHAR(255) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Usertype VARCHAR(50) NOT NULL,
    SecurityQuestion TEXT NOT NULL,
    SecurityAnswer TEXT NOT NULL
);

-- Table: Topic
CREATE TABLE Topic (
    TopicID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    IsApproved BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (CreatedBy) REFERENCES User(UserID)
);


-- Table: EducationalContent
CREATE TABLE EducationalContent (
    ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    ContentType VARCHAR(50) NOT NULL,
    ContentURL TEXT,
    ContentText TEXT,
    CreatedAt DATE NOT NULL,
    CreatedBy INT NOT NULL,
    TopicID INT NOT NULL,
    FOREIGN KEY (CreatedBy) REFERENCES User(UserID),
    FOREIGN KEY (TopicID) REFERENCES Topic(TopicID)
);

-- Table: Comment
CREATE TABLE Comment (
    CommentID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CommentText TEXT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    UserID INT NOT NULL,
    EducationalContent_ID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (EducationalContent_ID) REFERENCES EducationalContent(ID)
);

-- Table: Session
CREATE TABLE Session (
    SessionID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    StartTime INT NOT NULL,
    EndTime INT NOT NULL,
    Status VARCHAR(50) NOT NULL,
    TotalWagered INT NOT NULL,
    TotalWon INT NOT NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

-- Table: Game
CREATE TABLE Game (
    GameID INT NOT NULL PRIMARY KEY,
    RoundNumber INT NOT NULL,
    UserAction VARCHAR(100) NOT NULL,
    DealerHand TEXT NOT NULL,
    UserHand TEXT NOT NULL,
    Result TEXT NOT NULL,
    SessionID INT NOT NULL,
    FOREIGN KEY (SessionID) REFERENCES Session(SessionID)
);

-- Table: Statistics
CREATE TABLE Statistics (
    StatisticsID INT NOT NULL PRIMARY KEY,
    SessionCount INT NOT NULL,
    TotalWagered INT NOT NULL,
    TotalWon INT NOT NULL,
    WinPercentage DOUBLE(5,2) NOT NULL,
    AverageBet INT NOT NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES User(UserID)
);

ALTER TABLE EducationalContent
  ADD CONSTRAINT fk_topic_content
  FOREIGN KEY (TopicID) REFERENCES Topic(TopicID)
  ON DELETE CASCADE;

ALTER TABLE EducationalContent ADD COLUMN IsApproved BOOLEAN NOT NULL DEFAULT 0;


-- End of File
