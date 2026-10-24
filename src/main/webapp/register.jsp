
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account | DuplicateDetector</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <style>
        :root {
            --bg: #080d1b;
            --card: #111a2e;
            --border: rgba(148, 163, 184, 0.17);
            --text: #f1f5f9;
            --muted: #94a3b8;
            --blue: #4f7cff;
            --purple: #8b5cf6;
        }

        * {
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            margin: 0;
            padding: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: "Segoe UI", Arial, sans-serif;
            color: var(--text);
            background:
                radial-gradient(ellipse at 12% 12%,
                    rgba(79, 124, 255, 0.18), transparent 40%),
                radial-gradient(ellipse at 88% 88%,
                    rgba(139, 92, 246, 0.16), transparent 38%),
                var(--bg);
        }

        .register-card {
            width: 100%;
            max-width: 470px;
            padding: 36px 40px;
            background: rgba(17, 26, 46, 0.96);
            border: 1px solid var(--border);
            border-radius: 24px;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.35);
            animation: appear 0.5s ease both;
        }

        @keyframes appear {
            from {
                opacity: 0;
                transform: translateY(18px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .brand-icon {
            width: 54px;
            height: 54px;
            margin: 0 auto 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 17px;
            color: white;
            font-size: 27px;
            font-weight: 800;
            background: linear-gradient(135deg, var(--blue), var(--purple));
            box-shadow: 0 8px 25px rgba(79, 124, 255, 0.25);
        }

        .brand {
            font-size: 26px;
            font-weight: 800;
            letter-spacing: -0.7px;
        }

        .brand span {
            color: #829dff;
        }

        .subtitle {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.7;
        }

        .form-label {
            color: #dbe4f5;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .form-control {
            min-height: 46px;
            padding: 11px 13px;
            color: var(--text);
            background: #0b1325;
            border: 1px solid #293650;
            border-radius: 10px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .form-control:focus {
            color: white;
            background: #0b1325;
            border-color: var(--blue);
            box-shadow: 0 0 0 3px rgba(79, 124, 255, 0.15);
        }

        .form-control::placeholder {
            color: #64748b;
        }

        .password-wrap {
            position: relative;
        }

        .password-wrap .form-control {
            padding-right: 76px;
        }

        .toggle-password {
            position: absolute;
            top: 50%;
            right: 12px;
            transform: translateY(-50%);
            border: none;
            background: transparent;
            color: #91a8e8;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
        }

        .password-hint {
            display: block;
            margin-top: 7px;
            color: var(--muted);
            font-size: 11px;
        }

        .password-status {
            margin-top: 5px;
            font-size: 12px;
        }

        .btn-register {
            min-height: 48px;
            border: none;
            border-radius: 11px;
            color: white;
            font-weight: 700;
            background: linear-gradient(100deg, var(--blue), var(--purple));
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn-register:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(79, 124, 255, 0.28);
        }

        .form-links a {
            color: #8ca7ff;
            font-weight: 600;
            text-decoration: none;
        }

        .form-links a:hover {
            color: #c4b5fd;
            text-decoration: underline;
        }

        .back-link {
            color: var(--muted);
            font-size: 13px;
            text-decoration: none;
        }

        .back-link:hover {
            color: white;
        }

        .alert {
            border-radius: 10px;
            font-size: 13px;
        }

        @media (max-width: 480px) {
            body {
                padding: 15px;
            }

            .register-card {
                padding: 28px 22px;
                border-radius: 19px;
            }

            .brand {
                font-size: 23px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: 0.01ms !important;
                transition-duration: 0.01ms !important;
            }
        }
    </style>
</head>

<body>

<main class="register-card">

    <header class="text-center mb-4">
        <div class="brand-icon">D</div>

        <div class="brand">
            Duplicate<span>Detector</span>
        </div>

        <h2 class="h4 mt-3 mb-2 fw-bold">Create your account</h2>

        <p class="subtitle mb-0">
            Register to organize your scans and find duplicate files.
        </p>
    </header>

    <%
        String error = request.getParameter("error");
        String message = null;

        if ("empty".equals(error)) {
            message = "Please fill in all fields.";
        } else if ("email".equals(error)) {
            message = "Please enter a valid email address.";
        } else if ("password".equals(error)) {
            message = "Passwords do not match.";
        } else if ("exists".equals(error)) {
            message = "This email is already registered.";
        } else if ("invalid".equals(error)) {
            message = "Please check your details and password length.";
        }
    %>

    <% if (message != null) { %>
        <div class="alert alert-danger" role="alert">
            <%= message %>
        </div>
    <% } %>

    <form id="registerForm"
          action="<%= request.getContextPath() %>/register"
          method="post">

        <div class="mb-3">
            <label for="fullName" class="form-label">Full Name</label>

            <input type="text"
                   class="form-control"
                   id="fullName"
                   name="fullName"
                   maxlength="100"
                   autocomplete="name"
                   placeholder="Enter your full name"
                   required>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">Email Address</label>

            <input type="email"
                   class="form-control"
                   id="email"
                   name="email"
                   maxlength="150"
                   autocomplete="email"
                   placeholder="you@example.com"
                   required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">Password</label>

            <div class="password-wrap">
                <input type="password"
                       class="form-control"
                       id="password"
                       name="password"
                       minlength="8"
                       maxlength="128"
                       autocomplete="new-password"
                       placeholder="Create a password"
                       required>

                <button type="button"
                       class="toggle-password"
                       data-target="password"
                       aria-label="Show password"
                       aria-pressed="false">
                    Show
                </button>
            </div>

            <small class="password-hint">
                Use at least 8 characters.
            </small>

            <div id="passwordStatus"
                 class="password-status"
                 aria-live="polite"></div>
        </div>

        <div class="mb-4">
            <label for="confirmPassword" class="form-label">
                Confirm Password
            </label>

            <div class="password-wrap">
                <input type="password"
                       class="form-control"
                       id="confirmPassword"
                       name="confirmPassword"
                       minlength="8"
                       maxlength="128"
                       autocomplete="new-password"
                       placeholder="Re-enter your password"
                       required>

                <button type="button"
                        class="toggle-password"
                        data-target="confirmPassword"
                        aria-label="Show confirm password"
                        aria-pressed="false">
                    Show
                </button>
            </div>

            <div id="confirmStatus"
                 class="password-status"
                 aria-live="polite"></div>
        </div>

        <button type="submit" class="btn btn-register w-100">
            Create Account &rarr;
        </button>

    </form>

    <div class="form-links text-center mt-4">
        <span class="subtitle">Already have an account?</span>
        <a href="<%= request.getContextPath() %>/login.jsp">
            Sign in
        </a>
    </div>

    <div class="text-center mt-3">
        <a href="<%= request.getContextPath() %>/index.jsp"
           class="back-link">
            &larr; Back to Scanner
        </a>
    </div>

</main>

<script>
    const registerForm = document.getElementById("registerForm");
    const password = document.getElementById("password");
    const confirmPassword = document.getElementById("confirmPassword");
    const passwordStatus = document.getElementById("passwordStatus");
    const confirmStatus = document.getElementById("confirmStatus");

    function validatePasswords() {
        password.setCustomValidity("");
        confirmPassword.setCustomValidity("");

        if (password.value.length > 0 && password.value.length < 8) {
            password.setCustomValidity(
                "Password must contain at least 8 characters."
            );
            passwordStatus.textContent =
                "Password must contain at least 8 characters.";
            passwordStatus.style.color = "#f87171";
        } else if (password.value.length >= 8) {
            passwordStatus.textContent = "Password length looks good.";
            passwordStatus.style.color = "#4ade80";
        } else {
            passwordStatus.textContent = "";
        }

        if (confirmPassword.value.length > 0 &&
            password.value !== confirmPassword.value) {
            confirmPassword.setCustomValidity("Passwords do not match.");
            confirmStatus.textContent = "Passwords do not match.";
            confirmStatus.style.color = "#f87171";
        } else if (confirmPassword.value.length > 0) {
            confirmStatus.textContent = "Passwords match.";
            confirmStatus.style.color = "#4ade80";
        } else {
            confirmStatus.textContent = "";
        }
    }

    password.addEventListener("input", validatePasswords);
    confirmPassword.addEventListener("input", validatePasswords);

    document.querySelectorAll(".toggle-password").forEach(function (button) {
        button.addEventListener("click", function () {
            const target = document.getElementById(button.dataset.target);
            const showing = target.type === "password";

            target.type = showing ? "text" : "password";
            button.textContent = showing ? "Hide" : "Show";
            button.setAttribute("aria-label",
                showing ? "Hide password" : "Show password");
            button.setAttribute("aria-pressed", String(showing));
        });
    });

    registerForm.addEventListener("submit", function (event) {
        validatePasswords();

        if (!registerForm.checkValidity()) {
            event.preventDefault();
            registerForm.reportValidity();
        }
    });
</script>

</body>
</html>
