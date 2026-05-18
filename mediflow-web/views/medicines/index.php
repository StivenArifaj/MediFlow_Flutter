<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Medicines';

// Demo medicines data
$medicines = [
    ['id' => '1', 'verifiedName' => 'Aspirin', 'brandName' => 'Bayer', 'strength' => '100mg', 'form' => 'Tablet', 'apiSource' => 'openFDA'],
    ['id' => '2', 'verifiedName' => 'Metformin', 'brandName' => 'Glucophage', 'strength' => '500mg', 'form' => 'Tablet', 'apiSource' => 'manual'],
    ['id' => '3', 'verifiedName' => 'Lisinopril', 'brandName' => 'Zestril', 'strength' => '10mg', 'form' => 'Tablet', 'apiSource' => 'manual'],
    ['id' => '4', 'verifiedName' => 'Atorvastatin', 'brandName' => 'Lipitor', 'strength' => '20mg', 'form' => 'Tablet', 'apiSource' => 'openFDA'],
    ['id' => '5', 'verifiedName' => 'Omeprazole', 'brandName' => 'Prilosec', 'strength' => '20mg', 'form' => 'Capsule', 'apiSource' => 'manual']
];

ob_start();

?>

<!-- Page Header -->
<div class="page-header">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
            <h1 class="page-title">Medicines</h1>
            <p class="page-subtitle">Manage your medications and track their details.</p>
        </div>
        <button class="btn btn-primary">
            <svg viewBox="0 0 24 24" style="width: 20px; height: 20px; fill: currentColor;"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
            Add Medicine
        </button>
    </div>
</div>

<!-- Search & Filter -->
<div class="card mb-lg">
    <div class="card-body">
        <div style="display: flex; gap: var(--spacing-md);">
            <div style="flex: 1;">
                <input type="text" class="form-input" placeholder="Search medicines..." 
                       style="background: var(--bg-input);">
            </div>
            <select class="form-input" style="width: 150px; background: var(--bg-input);">
                <option value="">All Sources</option>
                <option value="manual">Manual</option>
                <option value="openFDA">OpenFDA</option>
            </select>
        </div>
    </div>
</div>

<!-- Medicines List -->
<div id="medicines-list">
    <div class="medicine-list">
        <?php foreach ($medicines as $medicine): ?>
        <div class="medicine-item">
            <div class="medicine-icon">
                <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
            </div>
            <div class="medicine-info">
                <div class="medicine-name"><?= htmlspecialchars($medicine['verifiedName']) ?></div>
                <div class="medicine-details">
                    <?= htmlspecialchars($medicine['brandName'] ?? '') ?><?= !empty($medicine['brandName']) ? ' - ' : '' ?>
                    <?= htmlspecialchars($medicine['strength'] ?? '') ?>
                    <?= !empty($medicine['form']) ? ' ' . htmlspecialchars($medicine['form']) : '' ?>
                </div>
            </div>
            <span class="medicine-badge <?= $medicine['apiSource'] ?>">
                <?= $medicine['apiSource'] === 'openFDA' ? 'OpenFDA ✓' : 'Manual' ?>
            </span>
        </div>
        <?php endforeach; ?>
    </div>
</div>

<?php

$content = ob_get_clean();

// Include layout
require_once __DIR__ . '/../layouts/main.php';