// document.addEventListener("DOMContentLoaded", function () {
//   fetch("/check_login")
//     .then((response) => response.json())
//     .then((data) => {
//       if (data.logged_in) {
//         const heroText = document.getElementById("hero-welcome");
//         if (heroText) {
//           heroText.textContent = `Welcome to the Dojo, ${data.user}`;
//         }
//       }
//     });
// });

function logout() {
  if (confirm("Are you sure you want to log out?")) {
    window.location.href = "/logout";
  }
}
