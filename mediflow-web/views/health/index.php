<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Health';

// Health metrics data (13 types)
$healthMetrics = [
    'Weight' => ['value' => 75, 'unit' => 'kg', 'color' => '#00E5FF'],
    'Blood Pressure' => ['value' => '120/80', 'unit' => 'mmHg', 'color' => '#FF4D6A'],
    'Heart Rate' => ['value' => 72, 'unit' => 'bpm', 'color' => '#FF4D6A'],
    'Blood Glucose' => ['value' => 95, 'unit' => 'mg/dL', 'color' => '#00C896'],
    'Temperature' => ['value' => 36.8, 'unit' => '°C', 'color' => '#FFB800'],
    'SpO2' => ['value' => 98, 'unit' => '%', 'color' => '#6B7FCC'],
    'Steps' => ['value' => 8500, 'unit' => 'steps', 'color' => '#00C896'],
    'Sleep' => ['value' => 7.5, 'unit' => 'hrs', 'color' => '#8B5CF6'],
    'Water Intake' => ['value' => 8, 'unit' => 'glasses', 'color' => '#00E5FF'],
    'BMI' => ['value' => 24.2, 'unit' => '', 'color' => '#00E5FF'],
    'Cholesterol' => ['value' => 185, 'unit' => 'mg/dL', 'color' => '#FFB800'],
    'Waist' => ['value' => 82, 'unit' => 'cm', 'color' => '#6B7FCC'],
    'Respiratory Rate' => ['value' => 16, 'unit' => '/min', 'color' => '#FF7F7F']
];

$metricIcons = [
    'Weight' => 'monitor_weight',
    'Blood Pressure' => 'favorite',
    'Heart Rate' => 'favorite_rounded',
    'Blood Glucose' => 'water_drop',
    'Temperature' => 'thermostat',
    'SpO2' => 'air',
    'Steps' => 'directions_walk',
    'Sleep' => 'bedtime',
    'Water Intake' => 'local_drink',
    'BMI' => 'accessibility_new',
    'Cholesterol' => 'opacity',
    'Waist' => 'straighten',
    'Respiratory Rate' => 'waves'
];

ob_start();

?>

<!-- Page Header -->
<div class="page-header">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
            <h1 class="page-title">Health Dashboard</h1>
            <p class="page-subtitle">Track your vital signs and health metrics.</p>
        </div>
        <button class="btn btn-primary">
            <svg viewBox="0 0 24 24" style="width: 20px; height: 20px; fill: currentColor;"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
            Add Reading
        </button>
    </div>
</div>

<!-- Health Metrics Grid -->
<div id="health-grid">
    <div class="health-grid">
        <?php foreach ($healthMetrics as $type => $data): ?>
        <div class="health-metric">
            <div class="health-metric-icon" style="background: linear-gradient(135deg, <?= $data['color'] ?>20, <?= $data['color'] ?>40)">
                <svg viewBox="0 0 24 24" style="fill: <?= $data['color'] ?>">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                </svg>
            </div>
            <div class="health-metric-name"><?= htmlspecialchars($type) ?></div>
            <div class="health-metric-value" style="color: <?= $data['color'] ?>">
                <?= htmlspecialchars($data['value']) ?>
                <?php if (!empty($data['unit'])): ?>
                <span class="health-metric-unit"><?= htmlspecialchars($data['unit']) ?></span>
                <?php endif; ?>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Charts Section -->
<div style="display: grid; grid-template-columns: 1fr 1fr; gap: var(--spacing-lg); margin-top: var(--spacing-xl);">
    <!-- Blood Pressure Trend -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Blood Pressure Trend</h3>
            <span class="text-secondary">Last 30 days</span>
        </div>
        <div class="card-body">
            <div class="chart-container">
                <canvas id="bpChart"></canvas>
            </div>
        </div>
    </div>
    
    <!-- Steps Trend -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Daily Steps</h3>
            <span class="text-secondary">Last 30 days</span>
        </div>
        <div class="card-body">
            <div class="chart-container">
                <canvas id="stepsChart"></canvas>
            </div>
        </div>
    </div>
</div>

<?php

$content = ob_get_clean();

$scripts = '
<script>
    // Initialize charts when page loads
    document.addEventListener("DOMContentLoaded", function() {
        // Blood Pressure Chart
        const bpCtx = document.getElementById("bpChart").getContext("2d");
        new Chart(bpCtx, {
            type: "line",
            data: {
                labels: Array.from({length: 30}, (_, i) => "Day " + (i + 1)),
                datasets: [{
                    label: "Systolic",
                    data: Array.from({length: 30}, () => 115 + Math.random() * 15),
                    borderColor: "#FF4D6A",
                    backgroundColor: "rgba(255, 77, 106, 0.1)",
                    fill: true,
                    tension: 0.4
                }, {
                    label: "Diastolic",
                    data: Array.from({length: 30}, () => 75 + Math.random() * 10),
                    borderColor: "#00E5FF",
                    backgroundColor: "rgba(0, 229, 255, 0.1)",
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: "bottom" }
                },
                scales: {
                    y: { grid: { color: "rgba(255,255,255,0.05)" } },
                    x: { grid: { display: false } }
                }
            }
        });
        
        // Steps Chart
        const stepsCtx = document.getElementById("stepsChart").getContext("2d");
        new Chart(stepsCtx, {
            type: "bar",
            data: {
                labels: Array.from({length: 30}, (_, i) => "Day " + (i + 1)),
                datasets: [{
                    label: "Steps",
                    data: Array.from({length: 30}, () => 5000 + Math.random() * 8000),
                    backgroundColor: "#00E5FF",
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: { grid: { color: "rgba(255,255,255,0.05)" } },
                    x: { grid: { display: false } }
                }
            }
        });
    });
</script>
';

// Include layout
require_once __DIR__ . '/../layouts/main.php';