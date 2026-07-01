<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Dashboard';

ob_start();


$todayTaken = count(array_filter($todayHistory ?? [], fn($h) => ($h['status'] ?? '') === 'taken'));
$todaySkipped = count(array_filter($todayHistory ?? [], fn($h) => ($h['status'] ?? '') === 'skipped'));
$todayMissed = count(array_filter($todayHistory ?? [], fn($h) => ($h['status'] ?? '') === 'missed'));

?>

<div class="page-header">
    <h1 class="page-title">Welcome back, <?= htmlspecialchars($user['name'] ?? 'User') ?>!</h1>
    <p class="page-subtitle">Here's your medication overview for today.</p>
</div>

<div id="dashboard-content">
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon taken">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--primary)"><?= $todayTaken ?></div>
            <div class="stat-card-label">Taken Today</div>
        </div>

        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon skipped">
                    <svg viewBox="0 0 24 24"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--info)"><?= $todaySkipped ?></div>
            <div class="stat-card-label">Skipped Today</div>
        </div>

        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon missed">
                    <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--error)"><?= $todayMissed ?></div>
            <div class="stat-card-label">Missed Today</div>
        </div>

        <div class="stat-card">
            <div class="stat-card-header">
                <div class="stat-card-icon adherence">
                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                </div>
            </div>
            <div class="stat-card-value" style="color: var(--success)"><?= $stats['adherence'] ?? 0 ?>%</div>
            <div class="stat-card-label">Overall Adherence</div>
        </div>
    </div>

    <div class="adherence-section">
        <div class="card-header">
            <h3 class="card-title">Medication Adherence</h3>
            <span class="text-secondary">Last 30 Days</span>
        </div>
        <div class="card-body">
            <div class="adherence-ring-container">
                <?php
                $percentage    = $stats['adherence'] ?? 0;
                $radius        = 96;
                $cx            = 110;
                $circumference = 2 * M_PI * $radius;
                $offset        = $circumference - ($percentage / 100) * $circumference;
                ?>
                <div class="adherence-ring" id="adherence-ring" data-percentage="<?= $percentage ?>">
                    <svg width="220" height="220" viewBox="0 0 220 220">
                        <defs>
                            <linearGradient id="adherenceGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                <stop offset="0%" style="stop-color:#00E5FF"/>
                                <stop offset="100%" style="stop-color:#0080FF"/>
                            </linearGradient>
                            <filter id="glow">
                                <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                                <feMerge><feMergeNode in="coloredBlur"/><feMergeNode in="SourceGraphic"/></feMerge>
                            </filter>
                        </defs>
                        <circle cx="<?= $cx ?>" cy="<?= $cx ?>" r="<?= $radius ?>" fill="none" stroke="#1a2535" stroke-width="14"/>
                        <circle cx="<?= $cx ?>" cy="<?= $cx ?>" r="<?= $radius ?>" fill="none"
                            stroke="url(#adherenceGradient)" stroke-width="14" stroke-linecap="round"
                            stroke-dasharray="<?= round($circumference, 2) ?>"
                            stroke-dashoffset="<?= round($offset, 2) ?>"
                            transform="rotate(-90 <?= $cx ?> <?= $cx ?>)"
                            filter="url(#glow)"/>
                    </svg>
                    <div class="adherence-ring-text">
                        <div class="adherence-ring-value"><?= $percentage ?>%</div>
                        <div class="adherence-ring-label">adherence</div>
                    </div>
                </div>

                <div class="adherence-stats">
                    <div class="adherence-stat">
                        <div class="adherence-stat-icon" style="background:rgba(0,229,255,0.1)">
                            <svg viewBox="0 0 24 24" style="fill:#00E5FF"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                        </div>
                        <div class="adherence-stat-value" style="color:var(--primary)"><?= $stats['taken'] ?? 0 ?></div>
                        <div class="adherence-stat-label">Taken</div>
                    </div>
                    <div class="adherence-stat">
                        <div class="adherence-stat-icon" style="background:rgba(107,127,204,0.1)">
                            <svg viewBox="0 0 24 24" style="fill:#6B7FCC"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                        </div>
                        <div class="adherence-stat-value" style="color:var(--info)"><?= $stats['skipped'] ?? 0 ?></div>
                        <div class="adherence-stat-label">Skipped</div>
                    </div>
                    <div class="adherence-stat">
                        <div class="adherence-stat-icon" style="background:rgba(255,59,92,0.1)">
                            <svg viewBox="0 0 24 24" style="fill:#FF3B5C"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                        </div>
                        <div class="adherence-stat-value" style="color:var(--error)"><?= $stats['missed'] ?? 0 ?></div>
                        <div class="adherence-stat-label">Missed</div>
                    </div>
                    <div class="adherence-stat">
                        <div class="adherence-stat-icon" style="background:rgba(0,200,150,0.1)">
                            <svg viewBox="0 0 24 24" style="fill:#00C896"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 14l-5-5 1.41-1.41L12 14.17l7.59-7.59L21 8l-9 9z"/></svg>
                        </div>
                        <div class="adherence-stat-value" style="color:#00C896"><?= $stats['total'] ?? 0 ?></div>
                        <div class="adherence-stat-label">Total</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div style="display: grid; grid-template-columns: 2fr 1fr; gap: var(--spacing-lg);">
        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Today's Schedule</h3>
                <a href="?page=history" class="btn btn-sm btn-ghost">View All</a>
            </div>
            <div class="card-body">
                <?php if (!empty($todayHistory)): ?>
                <div class="history-timeline">
                    <?php foreach (array_slice($todayHistory, 0, 5) as $entry): ?>
                    <div class="history-item">
                        <div class="history-time"><?= date('H:i', strtotime($entry['timestamp'] ?? time())) ?></div>
                        <div class="history-content">
                            <span class="history-status <?= $entry['status'] ?? 'pending' ?>"><?= ucfirst($entry['status'] ?? 'Pending') ?></span>
                            <div class="history-medicine" style="font-weight: 600; margin-top: var(--spacing-xs)"><?= htmlspecialchars($entry['medicineName'] ?? 'Medicine') ?></div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>
                <?php else: ?>
                <div class="empty-state">
                    <div class="empty-state-icon">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                    </div>
                    <div class="empty-state-title">No medications scheduled</div>
                    <div class="empty-state-text">No medications recorded for today</div>
                </div>
                <?php endif; ?>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3 class="card-title">Quick Stats</h3>
            </div>
            <div class="card-body">
                <div style="margin-bottom: var(--spacing-md)">
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Active Medicines</div>
                    <div style="font-size: 1.5rem; font-weight: 700"><?= count($medicines ?? []) ?></div>
                </div>
                <div style="margin-bottom: var(--spacing-md)">
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Total Doses</div>
                    <div style="font-size: 1.5rem; font-weight: 700"><?= $stats['total'] ?? 0 ?></div>
                </div>
                <div>
                    <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Next Reminder</div>
                    <div style="font-size: 1rem; font-weight: 600">--:-- - --</div>
                </div>
            </div>
        </div>
    </div>
</div>

<?php

$content = ob_get_clean();

require_once __DIR__ . '/../layouts/main.php';