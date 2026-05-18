<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Dashboard';

// Demo data for when Firebase isn't connected
$demoStats = [
    'taken' => 45,
    'skipped' => 8,
    'missed' => 5,
    'total' => 58,
    'adherence' => 77
];

$demoMedicines = [
    ['id' => '1', 'verifiedName' => 'Aspirin', 'brandName' => 'Bayer', 'strength' => '100mg', 'form' => 'Tablet', 'apiSource' => 'openFDA'],
    ['id' => '2', 'verifiedName' => 'Metformin', 'brandName' => 'Glucophage', 'strength' => '500mg', 'form' => 'Tablet', 'apiSource' => 'manual'],
    ['id' => '3', 'verifiedName' => 'Lisinopril', 'brandName' => 'Zestril', 'strength' => '10mg', 'form' => 'Tablet', 'apiSource' => 'manual'],
    ['id' => '4', 'verifiedName' => 'Atorvastatin', 'brandName' => 'Lipitor', 'strength' => '20mg', 'form' => 'Tablet', 'apiSource' => 'openFDA'],
    ['id' => '5', 'verifiedName' => 'Omeprazole', 'brandName' => 'Prilosec', 'strength' => '20mg', 'form' => 'Capsule', 'apiSource' => 'manual']
];

$demoHistory = [
    ['id' => '1', 'status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time() - 3600],
    ['id' => '2', 'status' => 'taken', 'medicineName' => 'Metformin', 'timestamp' => time() - 7200],
    ['id' => '3', 'status' => 'skipped', 'medicineName' => 'Lisinopril', 'timestamp' => time() - 10800],
    ['id' => '4', 'status' => 'taken', 'medicineName' => 'Atorvastatin', 'timestamp' => time() - 14400],
    ['id' => '5', 'status' => 'missed', 'medicineName' => 'Omeprazole', 'timestamp' => time() - 18000],
    ['id' => '6', 'status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time() - 86400],
    ['id' => '7', 'status' => 'taken', 'medicineName' => 'Metformin', 'timestamp' => time() - 90000],
    ['id' => '8', 'status' => 'taken', 'medicineName' => 'Lisinopril', 'timestamp' => time() - 93600]
];

ob_start();

?>

<!-- Page Header -->
<div class="page-header">
    <h1 class="page-title">Welcome back, <?= htmlspecialchars($user['name'] ?? 'User') ?>!</h1>
    <p class="page-subtitle">Here's your medication overview for today.</p>
</div>

<!-- Dashboard Content -->
<div id="dashboard-content">
    <!-- Stats Grid -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon taken">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--primary)">3</div>
            <div class="stat-card-label">Taken Today</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon skipped">
                    <svg viewBox="0 0 24 24"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--info)">1</div>
            <div class="stat-card-label">Skipped Today</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon missed">
                    <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--error)">1</div>
            <div class="stat-card-label">Missed Today</div>
        </div>
        
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon adherence">
                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--success)"><?= $demoStats['adherence'] ?>%</div>
            <div class="stat-card-label">Overall Adherence</div>
        </div>
    </div>
    
    <!-- Adherence Section -->
    <div class="adherence-section">
        <div class="card-header">
            <h3 class="card-title">Medication Adherence</h3>
            <span class="text-secondary">Last 30 Days</span>
        </div>
        <div class="card-body">
            <div class="adherence-ring-container">
                <div class="adherence-ring">
                    <svg width="180" height="180" viewBox="0 0 180 180">
                        <defs>
                            <linearGradient id="adherenceGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                <stop offset="0%" style="stop-color:#00E5FF"/>
                                <stop offset="100%" style="stop-color:#0080FF"/>
                            </linearGradient>
                        </defs>
                        <circle cx="90" cy="90" r="70" fill="none" stroke="#162032" stroke-width="12"/>
                        <circle cx="90" cy="90" r="70" fill="none" stroke="url(#adherenceGradient)" stroke-width="12" 
                            stroke-linecap="round" stroke-dasharray="439.82" stroke-dashoffset="101.15" transform="rotate(-90 90 90)"/>
                        <text x="90" y="90" text-anchor="middle" dy="0.35em" 
                            style="font-size: 2.5rem; font-weight: 800; fill: var(--primary)">77%</text>
                        <text x="90" y="110" text-anchor="middle" 
                            style="font-size: 0.75rem; fill: var(--text-secondary)">adherence</text>
                    </svg>
                </div>
                <div class="adherence-stats">
                    <div class="adherence-stat">
                        <div class="adherence-stat-value" style="color: var(--primary)"><?= $demoStats['taken'] ?></div>
                        <div class="adherence-stat-label">Taken</div>
                    </div>
                    <div class="adherence-stat">
                        <div class="adherence-stat-value" style="color: var(--info)"><?= $demoStats['skipped'] ?></div>
                        <div class="adherence-stat-label">Skipped</div>
                    </div>
                    <div class="adherence-stat">
                        <div class="adherence-stat-value" style="color: var(--error)"><?= $demoStats['missed'] ?></div>
                        <div class="adherence-stat-label">Missed</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Today's Schedule & Quick Stats -->
    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: var(--spacing-lg);">
        <!-- Today's Schedule -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Today's Schedule</h3>
                <a href="?page=history" class="btn btn-sm btn-ghost">View All</a>
            </div>
            <div class="card-body">
                <div class="history-timeline">
                    <?php foreach (array_slice($demoHistory, 0, 5) as $entry): ?>
                    <div class="history-item">
                        <div class="history-time"><?= date('H:i', $entry['timestamp']) ?></div>
                        <div class="history-content">
                            <span class="history-status <?= $entry['status'] ?>"><?= ucfirst($entry['status']) ?></span>
                            <div class="history-medicine" style="font-weight: 600; margin-top: var(--spacing-xs)"><?= htmlspecialchars($entry['medicineName']) ?></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
        
        <!-- Quick Stats -->
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Quick Stats</h3>
            </div>
            <div class="card-body">
                <div style="margin-bottom: var(--spacing-md)">
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Active Medicines</div>
                    <div style="font-size: 1.5rem; font-weight: 700"><?= count($demoMedicines) ?></div>
                </div>
                <div style="margin-bottom: var(--spacing-md)">
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Current Streak</div>
                    <div style="font-size: 1.5rem; font-weight: 700">🔥 7 days</div>
                </div>
                <div>
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Next Reminder</div>
                    <div style="font-size: 1rem; font-weight: 600">08:00 - Metformin</div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php

$content = ob_get_clean();

// Include layout
require_once __DIR__ . '/../layouts/main.php';