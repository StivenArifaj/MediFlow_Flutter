<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= APP_NAME ?> - <?= $pageTitle ?? 'Dashboard' ?></title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Material Icons -->
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
    
    <!-- Styles -->
    <link rel="stylesheet" href="<?= APP_URL ?>/public/css/style.css">
</head>
<body>
    <div class="app-layout">
        <!-- Sidebar -->
        <aside class="sidebar">
            <!-- Logo -->
            <div class="sidebar-logo">
                <div class="sidebar-logo-icon">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                </div>
                <span class="sidebar-logo-text">MediFlow</span>
            </div>
            
            <!-- Navigation -->
            <nav class="sidebar-nav">
                <a href="<?= APP_URL ?>/public/index.php?page=dashboard" class="sidebar-nav-item <?= ($_GET['page'] ?? 'dashboard') === 'dashboard' ? 'active' : '' ?>">
                    <svg viewBox="0 0 24 24"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>
                    Dashboard
                </a>
                <a href="<?= APP_URL ?>/public/index.php?page=medicines" class="sidebar-nav-item <?= ($_GET['page'] ?? '') === 'medicines' ? 'active' : '' ?>">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                    Medicines
                </a>
                <a href="<?= APP_URL ?>/public/index.php?page=history" class="sidebar-nav-item <?= ($_GET['page'] ?? '') === 'history' ? 'active' : '' ?>">
                    <svg viewBox="0 0 24 24"><path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
                    History
                </a>
                <a href="<?= APP_URL ?>/public/index.php?page=health" class="sidebar-nav-item <?= ($_GET['page'] ?? '') === 'health' ? 'active' : '' ?>">
                    <svg viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                    Health
                </a>
                <a href="<?= APP_URL ?>/public/index.php?page=charts" class="sidebar-nav-item <?= ($_GET['page'] ?? '') === 'charts' ? 'active' : '' ?>">
                    <svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg>
                    Charts
                </a>
            </nav>
            
            <!-- User Info -->
            <?php if (isset($user) && $user): ?>
            <div class="sidebar-user">
                <div class="sidebar-user-info">
                    <div class="sidebar-user-avatar">
                        <?= strtoupper(substr($user['name'] ?? 'U', 0, 1)) ?>
                    </div>
                    <div>
                        <div class="sidebar-user-name"><?= htmlspecialchars($user['name'] ?? 'User') ?></div>
                        <div class="sidebar-user-role"><?= ucfirst($user['role'] ?? 'patient') ?></div>
                    </div>
                </div>
                <a href="<?= APP_URL ?>/public/index.php?page=logout" class="btn btn-sm btn-ghost w-full mt-sm" style="margin-top: var(--spacing-sm)">
                    Sign Out
                </a>
            </div>
            <?php endif; ?>
        </aside>
        
        <!-- Main Content -->
        <main class="main-content">
            <?= $content ?? '' ?>
        </main>
    </div>
    
    <!-- Scripts -->
    <script src="<?= APP_URL ?>/public/js/api.js"></script>
    <script src="<?= APP_URL ?>/public/js/charts.js"></script>
    <script src="<?= APP_URL ?>/public/js/app.js"></script>
    
    <?= $scripts ?? '' ?>
</body>
</html>