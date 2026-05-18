<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';
require_once __DIR__ . '/../../services/AuthService.php';

$error = '';
$success = '';

$authService = new AuthService();

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = sanitize($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    
    if (empty($email) || empty($password)) {
        $error = 'Please enter both email and password';
    } else {
        $user = $authService->login($email, $password);
        
        if ($user) {
            redirect(APP_URL . '/public/index.php?page=dashboard');
        } else {
            $error = 'Invalid email or password';
        }
    }
}

// If already logged in, redirect to dashboard
if ($authService->isLoggedIn()) {
    redirect(APP_URL . '/public/index.php?page=dashboard');
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - <?= APP_NAME ?></title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Styles -->
    <link rel="stylesheet" href="<?= APP_URL ?>/public/css/style.css">
    
    <style>
        .login-page {
            background: radial-gradient(ellipse at top, #0D1A2A 0%, #08090F 70%);
        }
    </style>
</head>
<body>
    <div class="login-page">
        <div class="login-card">
            <div class="login-header">
                <div class="login-logo">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                </div>
                <h1 class="login-title"><?= APP_NAME ?></h1>
                <p class="login-subtitle">Welcome back! Please sign in to continue.</p>
            </div>
            
            <?php if ($error): ?>
            <div class="alert alert-error">
                <?= htmlspecialchars($error) ?>
            </div>
            <?php endif; ?>
            
            <?php if ($success): ?>
            <div class="alert alert-success">
                <?= htmlspecialchars($success) ?>
            </div>
            <?php endif; ?>
            
            <form method="POST" action="">
                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-input" 
                           placeholder="Enter your email" required 
                           value="<?= htmlspecialchars($_POST['email'] ?? '') ?>">
                </div>
                
                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-input" 
                           placeholder="Enter your password" required>
                </div>
                
                <button type="submit" class="btn btn-primary btn-block">
                    Sign In
                </button>
            </form>
            
            <div class="login-footer">
                <p>Demo Credentials:</p>
                <p style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 4px;">
                    Email: <strong>demo@mediflow.app</strong> | Password: <strong>demo123</strong>
                </p>
            </div>
        </div>
    </div>
</body>
</html>