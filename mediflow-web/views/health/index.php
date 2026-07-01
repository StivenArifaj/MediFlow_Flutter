<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Health';

// Metric definitions — values come from the app; none are hardcoded here
$metricDefs = [
    ['name' => 'Weight',           'unit' => 'kg',    'color' => '#00E5FF', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z'],
    ['name' => 'Blood Pressure',   'unit' => 'mmHg',  'color' => '#FF4D6A', 'icon' => 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z'],
    ['name' => 'Heart Rate',       'unit' => 'bpm',   'color' => '#FF4D6A', 'icon' => 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z'],
    ['name' => 'Blood Glucose',    'unit' => 'mg/dL', 'color' => '#00C896', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z'],
    ['name' => 'Temperature',      'unit' => '°C',    'color' => '#FFB800', 'icon' => 'M15 13V5c0-1.66-1.34-3-3-3S9 3.34 9 5v8c-1.21.91-2 2.37-2 4 0 2.76 2.24 5 5 5s5-2.24 5-5c0-1.63-.79-3.09-2-4z'],
    ['name' => 'SpO2',             'unit' => '%',     'color' => '#6B7FCC', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z'],
    ['name' => 'Steps',            'unit' => 'steps', 'color' => '#00C896', 'icon' => 'M13.49 5.48c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm-3.6 13.9l1-4.4 2.1 2v6h2v-7.5l-2.1-2 .6-3c1.3 1.5 3.3 2.5 5.5 2.5v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1l-5.2 2.2v4.7h2v-3.4l1.8-.7-1.6 8.1-4.9-1-.4 2 7 1.4z'],
    ['name' => 'Sleep',            'unit' => 'hrs',   'color' => '#8B5CF6', 'icon' => 'M9 11.24V7.5C9 6.12 10.12 5 11.5 5S14 6.12 14 7.5v3.74c1.21.91 2 2.37 2 4.01C16 17.64 14.12 20 11.5 20S7 17.64 7 15.25c0-1.64.79-3.1 2-4.01z'],
    ['name' => 'Water Intake',     'unit' => 'glasses','color'=> '#00E5FF', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z'],
    ['name' => 'BMI',              'unit' => '',      'color' => '#00E5FF', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z'],
    ['name' => 'Cholesterol',      'unit' => 'mg/dL', 'color' => '#FFB800', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z'],
    ['name' => 'Waist',            'unit' => 'cm',    'color' => '#6B7FCC', 'icon' => 'M20 9H4v2h16V9zM4 15h16v-2H4v2z'],
    ['name' => 'Respiratory Rate', 'unit' => '/min',  'color' => '#FF7F7F', 'icon' => 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z'],
];

ob_start();
?>

<div class="page-header">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
            <h1 class="page-title">Health Dashboard</h1>
            <p class="page-subtitle">Your vital signs and health metrics from the mobile app.</p>
        </div>
    </div>
</div>

<!-- No-data notice -->
<div style="display:flex; align-items:center; gap:10px; background:rgba(0,229,255,0.06); border:1px solid rgba(0,229,255,0.15); border-radius:12px; padding:14px 20px; margin-bottom:var(--spacing-xl);">
    <svg viewBox="0 0 24 24" style="width:20px;height:20px;fill:#00E5FF;flex-shrink:0"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
    <span style="font-size:0.875rem;color:var(--text-secondary)">Health readings are recorded in the <strong style="color:var(--text-primary)">MediFlow mobile app</strong>. Add readings there and they will appear here once synced.</span>
</div>

<!-- Metric cards — values show — when no data is recorded -->
<div class="health-grid">
    <?php foreach ($metricDefs as $metric): ?>
    <div class="health-metric health-metric-empty">
        <div class="health-metric-icon" style="background:linear-gradient(135deg,<?= $metric['color'] ?>18,<?= $metric['color'] ?>35)">
            <svg viewBox="0 0 24 24" style="fill:<?= $metric['color'] ?>">
                <path d="<?= $metric['icon'] ?>"/>
            </svg>
        </div>
        <div class="health-metric-name"><?= htmlspecialchars($metric['name']) ?></div>
        <div class="health-metric-value" style="color:<?= $metric['color'] ?>">
            <span style="opacity:0.35">—</span>
            <?php if (!empty($metric['unit'])): ?>
            <span class="health-metric-unit" style="opacity:0.3"><?= htmlspecialchars($metric['unit']) ?></span>
            <?php endif; ?>
        </div>
        <div style="font-size:0.65rem;color:var(--text-secondary);margin-top:4px;opacity:0.5">No data yet</div>
    </div>
    <?php endforeach; ?>
</div>

<?php
$content = ob_get_clean();
require_once __DIR__ . '/../layouts/main.php';
