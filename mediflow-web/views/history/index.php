<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'History';

// Demo history data
$history = [
    ['id' => '1', 'status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time() - 3600],
    ['id' => '2', 'status' => 'taken', 'medicineName' => 'Metformin', 'timestamp' => time() - 7200],
    ['id' => '3', 'status' => 'skipped', 'medicineName' => 'Lisinopril', 'timestamp' => time() - 10800],
    ['id' => '4', 'status' => 'taken', 'medicineName' => 'Atorvastatin', 'timestamp' => time() - 14400],
    ['id' => '5', 'status' => 'missed', 'medicineName' => 'Omeprazole', 'timestamp' => time() - 18000],
    ['id' => '6', 'status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time() - 86400],
    ['id' => '7', 'status' => 'taken', 'medicineName' => 'Metformin', 'timestamp' => time() - 90000],
    ['id' => '8', 'status' => 'taken', 'medicineName' => 'Lisinopril', 'timestamp' => time() - 93600],
    ['id' => '9', 'status' => 'skipped', 'medicineName' => 'Atorvastatin', 'timestamp' => time() - 172800],
    ['id' => '10', 'status' => 'taken', 'medicineName' => 'Omeprazole', 'timestamp' => time() - 259200],
    ['id' => '11', 'status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time() - 345600],
    ['id' => '12', 'status' => 'missed', 'medicineName' => 'Metformin', 'timestamp' => time() - 432000]
];

// Group by date
$grouped = [];
foreach ($history as $entry) {
    $date = date('Y-m-d', $entry['timestamp']);
    if (!isset($grouped[$date])) $grouped[$date] = [];
    $grouped[$date][] = $entry;
}

// Calculate stats
$totalTaken = count(array_filter($history, fn($h) => $h['status'] === 'taken'));
$totalSkipped = count(array_filter($history, fn($h) => $h['status'] === 'skipped'));
$totalMissed = count(array_filter($history, fn($h) => $h['status'] === 'missed'));
$total = count($history);
$adherence = $total > 0 ? round(($totalTaken / $total) * 100) : 0;

ob_start();

?>

<!-- Page Header -->
<div class="page-header">
    <h1 class="page-title">Medication History</h1>
    <p class="page-subtitle">Track your medication intake over time.</p>
</div>

<!-- Stats Summary -->
<div class="stats-grid mb-lg">
    <div class="stat-card">
        <div class="stat-card-value" style="color: var(--primary)"><?= $adherence ?>%</div>
        <div class="stat-card-label">Overall Adherence</div>
    </div>
    <div class="stat-card">
        <div class="stat-card-value" style="color: var(--primary)"><?= $totalTaken ?></div>
        <div class="stat-card-label">Total Taken</div>
    </div>
    <div class="stat-card">
        <div class="stat-card-value" style="color: var(--info)"><?= $totalSkipped ?></div>
        <div class="stat-card-label">Total Skipped</div>
    </div>
    <div class="stat-card">
        <div class="stat-card-value" style="color: var(--error)"><?= $totalMissed ?></div>
        <div class="stat-card-label">Total Missed</div>
    </div>
</div>

<!-- Filters -->
<div class="card mb-lg">
    <div class="card-body">
        <div style="display: flex; gap: var(--spacing-md); flex-wrap: wrap;">
            <button class="btn btn-primary btn-sm">Today</button>
            <button class="btn btn-secondary btn-sm">7 Days</button>
            <button class="btn btn-secondary btn-sm">30 Days</button>
            <button class="btn btn-secondary btn-sm">All Time</button>
            <div style="flex: 1;"></div>
            <select class="form-input" style="width: 120px; background: var(--bg-input);">
                <option value="">All Status</option>
                <option value="taken">Taken</option>
                <option value="skipped">Skipped</option>
                <option value="missed">Missed</option>
            </select>
        </div>
    </div>
</div>

<!-- History List -->
<div id="history-list">
    <?php foreach ($grouped as $date => $entries): ?>
    <div class="mb-lg">
        <h4 class="text-secondary mb-md" style="font-size: 0.875rem; font-weight: 600;">
            <?= date('l, d M Y', strtotime($date)) ?>
        </h4>
        <div class="history-timeline">
            <?php foreach ($entries as $entry): ?>
            <div class="history-item">
                <div class="history-time"><?= date('H:i', $entry['timestamp']) ?></div>
                <div class="history-content">
                    <span class="history-status <?= $entry['status'] ?>"><?= ucfirst($entry['status']) ?></span>
                    <div class="history-medicine"><?= htmlspecialchars($entry['medicineName']) ?></div>
                    <div class="history-scheduled">Scheduled: <?= date('d MMM, H:i', $entry['timestamp']) ?></div>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
    <?php endforeach; ?>
</div>

<?php

$content = ob_get_clean();

// Include layout
require_once __DIR__ . '/../layouts/main.php';