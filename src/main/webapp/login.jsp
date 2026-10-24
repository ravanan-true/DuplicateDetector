
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In | DuplicateDetector</title>

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
                radial-gradient(ellipse at 15% 15%,
                    rgba(79, 124, 255, 0.18), transparent 40%),
                radial-gradient(ellipse at 85% 85%,
                    rgba(139, 92, 246, 0.16), transparent 38%),
                var(--bg);
        }

        .login-card {
            width: 100%;
            max-width: 460px;
            padding: 40px;
            background: rgba(17, 26, 46, 0.94);
            border: 1px solid var(--border);
            border-radius: 24px;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.35);
            animation: appear 0.55s ease both;
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
            width: 58px;
            height: 58px;
            margin: 0 auto 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 18px;
            color: white;
            font-size: 28px;
            font-weight: 800;
            background: linear-gradient(135deg, var(--blue), var(--purple));
            box-shadow: 0 8px 28px rgba(79, 124, 255, 0.25);
        }

        .brand {
            font-size: 27px;
            font-weight: 800;
            letter-spacing: -0.7px;
        }

        .brand span {
            color: #7797ff;
        }

        .subtitle {
            color: var(--muted);
            font-size: 14px;
            line-height: 1.7;
        }

        .form-label {
            color: #dbe4f5;
            font-size: 13px;
            font-weight: 600;
            margin-bottom: 9px;
        }

        .form-control {
            min-height: 49px;
            padding: 12px 14px;
            color: var(--text);
            background: #0b1325;
            border: 1px solid #293650;
            border-radius: 11px;
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
            padding-right: 78px;
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

        .btn-login {
            min-height: 49px;
            border: none;
            border-radius: 11px;
            color: white;
            font-weight: 700;
            background: linear-gradient(100deg, var(--blue), var(--purple));
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn-login:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 10px 28px rgba(79, 124, 255, 0.28);
        }

        .btn-login:active {
            transform: translateY(0);
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

        .security-note {
            margin-top: 25px;
            padding-top: 17px;
            border-top: 1px solid var(--border);
            color: #8391a9;
            font-size: 12px;
            text-align: center;
        }

        .alert {
            font-size: 13px;
            border-radius: 10px;
        }

        @media (max-width: 480px) {
            body {
                padding: 16px;
            }

            .login-card {
                padding: 28px 22px;
                border-radius: 19px;
            }

            .brand {
                font-size: 24px;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: 0.01ms !important;
                transition-duration: 0.01ms !important;
            }
        }
        
        .error {
		    background: #451d2b;
		    color: #fecaca;
		    padding: 12px;
		    border-radius: 8px;
		    margin-bottom: 15px;
		}
    </style>
</head>

<body>

<main class="login-card">

    <header class="text-center mb-4">
        <div class="brand-icon">D</div>

        <div class="brand">
            Duplicate<span>Detector</span>
        </div>

        <h2 class="h4 mt-4 mb-2 fw-bold">Welcome back!</h2>

        <p class="subtitle mb-0">
            Sign in to find duplicate files and manage your scan history.
        </p>
    </header>

    <%
        String error = request.getParameter("error");
        String registered = request.getParameter("registered");
    %>

    <% if ("1".equals(registered)) { %>
        <div class="alert alert-success" role="alert">
            Account created successfully! Please sign in.
        </div>
    <% } %>

    <% if ("invalid".equals(error)) { %>
        <div class="alert alert-danger" role="alert">
            Invalid email or password. Please try again.
        </div>
    <% } %>

    <% if ("1".equals(request.getParameter("logout"))) { %>
        <div class="alert alert-success" role="alert">
            You have been logged out successfully.
        </div>
    <% } %>

    <% if ("login".equals(error)) { %>
        <div class="alert alert-warning" role="alert">
            Please sign in to access that page.
        </div>
    <% } %>
    
    
	<%
	    String loginError = request.getParameter("error");
	    if ("account_inactive".equals(loginError)) {
	%>
	    <div class="error">
	        Your account is inactive. Please contact the administrator.
	    </div>
	<% } %>
    

    <form action="<%= request.getContextPath() %>/login" method="post">

        <div class="mb-3">
            <label for="email" class="form-label">Email Address</label>

            <input type="email"
                   class="form-control"
                   id="email"
                   name="email"
                   maxlength="150"
                   autocomplete="username"
                   placeholder="you@example.com"
                   required>
        </div>

        <div class="mb-4">
            <label for="password" class="form-label">Password</label>

            <div class="password-wrap">
                <input type="password"
                       class="form-control"
                       id="password"
                       name="password"
                       maxlength="128"
                       autocomplete="current-password"
                       placeholder="Enter your password"
                       required>

                <button type="button"
                        class="toggle-password"
                        id="togglePassword"
                        aria-label="Show password"
                        aria-pressed="false">
                    Show
                </button>
            </div>
        </div>

        <button type="submit" class="btn btn-login w-100">
            Sign In &rarr;
        </button>

    </form>

    <div class="form-links text-center mt-4">
        <span class="subtitle">Don't have an account?</span>
        <a href="<%= request.getContextPath() %>/register.jsp">
            Create Account
        </a>
    </div>

    <div class="text-center mt-3">
        <a href="<%= request.getContextPath() %>/index.jsp"
           class="back-link">
            &larr; Back to Scanner
        </a>
    </div>

    <div class="security-note">
        &#128274; Your account is protected by secure authentication.
    </div>

</main>

<script>
    const passwordInput = document.getElementById("password");
    const toggleButton = document.getElementById("togglePassword");

    toggleButton.addEventListener("click", function () {
        const isPassword = passwordInput.type === "password";

        passwordInput.type = isPassword ? "text" : "password";
        toggleButton.textContent = isPassword ? "Hide" : "Show";
        toggleButton.setAttribute("aria-label",
            isPassword ? "Hide password" : "Show password");
        toggleButton.setAttribute("aria-pressed", String(isPassword));
    });
</script>
</body>
</html>
