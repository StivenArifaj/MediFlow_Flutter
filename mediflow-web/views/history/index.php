<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'History';

ob_start();

$grouped = [];
if (!empty($history)) {
    foreach ($history as $entry) {
        $date = date('Y-m-d', strtotime($entry['timestamp'] ?? time()));
        if (!isset($grouped[$date])) $grouped[$date] = [];
        $grouped[$date][] = $entry;
    }
    krsort($grouped);
}

$totalTaken = count(array_filter($history ?? [], fn($h) => ($h['status'] ?? '') === 'taken'));
$totalSkipped = count(array_filter($history ?? [], fn($h) => ($h['status'] ?? '') === 'skipped'));
$totalMissed = count(array_filter($history ?? [], fn($h) => ($h['status'] ?? '') === 'missed'));
$total = count($history ?? []);
$adherence = $total > 0 ? round(($totalTaken / $total) * 100) : 0;

?>

<div class="page-header">
    <h1 class="page-title">Medication History</h1>
    <p class="page-subtitle">Track your medication intake over time.</p>
</div>

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

<div class="card mb-lg">
    <div class="card-body">
        <div style="display: flex; gap: var(--spacing-md); flex-wrap: wrap;">
            <button class="btn btn-primary btn-sm" onclick="filterHistory('today')">Today</button>
            <button class="btn btn-secondary btn-sm" onclick="filterHistory('7days')">7 Days</button>
            <button class="btn btn-secondary btn-sm" onclick="filterHistory('30days')">30 Days</button>
            <button class="btn btn-secondary btn-sm" onclick="filterHistory('all')">All Time</button>
            <div style="flex: 1;"></div>
            <select class="form-input" style="width: 120px; background: var(--bg-input);" onchange="filterByStatus(this.value)">
                <option value="">All Status</option>
                <option value="taken">Taken</option>
                <option value="skipped">Skipped</option>
                <option value="missed">Missed</option>
                <option value="taken_late">Taken Late</option>
            </select>
        </div>
    </div>
</div>

<div id="history-list">
    <?php if (!empty($grouped)): ?>
        <?php foreach ($grouped as $date => $entries): ?>
        <div class="mb-lg history-date-group" data-date="<?= $date ?>">
            <h4 class="text-secondary mb-md" style="font-size: 0.875rem; font-weight: 600;">
                <?= date('l, d M Y', strtotime($date)) ?>
            </h4>
            <div class="history-timeline">
                <?php foreach ($entries as $entry): ?>
                <div class="history-item" data-status="<?= $entry['status'] ?? '' ?>">
                    <div class="history-time"><?= date('H:i', strtotime($entry['timestamp'] ?? time())) ?></div>
                    <div class="history-content">
                        <span class="history-status <?= $entry['status'] ?? 'pending' ?>"><?= ucfirst($entry['status'] ?? 'Pending') ?></span>
                        <div class="history-medicine"><?= htmlspecialchars($entry['medicineName'] ?? 'Medicine') ?></div>
                        <div class="history-scheduled">Scheduled: <?= date('d MMM, H:i', strtotime($entry['timestamp'] ?? time())) ?></div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </div>
        <?php endforeach; ?>
    <?php else: ?>
    <div class="empty-state">
        <div class="empty-state-icon">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
        </div>
        <div class="empty-state-title">No History Records</div>
        <div class="empty-state-text">Your medication history will appear here</div>
    </div>
    <?php endif; ?>
</div>

<script>
function filterHistory(period) {
    const buttons = document.querySelectorAll('.btn-sm');
    buttons.forEach(btn => btn.classList.remove('btn-primary'));
    buttons.forEach(btn => btn.classList.add('btn-secondary'));
    event.target.classList.remove('btn-secondary');
    event.target.classList.add('btn-primary');

    const now = new Date();
    const groups = document.querySelectorAll('.history-date-group');

    groups.forEach(group => {
        const dateStr = group.dataset.date;
        const date = new Date(dateStr);
        const diffDays = Math.floor((now - date) / (1000 * 60 * 60 * 24));

        let show = false;
        switch(period) {
            case 'today':
                show = diffDays === 0;
                break;
            case '7days':
                show = diffDays <= 7;
                break;
            case '30days':
                show = diffDays <= 30;
                break;
            default:
                show = true;
        }
        group.style.display = show ? 'block' : 'none';
    });
}

function filterByStatus(status) {
    const items = document.querySelectorAll('.history-item');
    items.forEach(item => {
        if (!status || item.dataset.status === status) {
            item.style.display = 'flex';
        } else {
            item.style.display = 'none';
        }
    });
}
</script>

<?php

$content = ob_get_clean();

require_once __DIR__ . '/../layouts/main.php';