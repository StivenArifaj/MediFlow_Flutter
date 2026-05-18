<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Medicines';

ob_start();

?>

<div class="page-header">
    <div style="display: flex; justify-content: space-between; align-items: center;">
        <div>
            <h1 class="page-title">Medicines</h1>
            <p class="page-subtitle">Manage your medications and track their details.</p>
        </div>
    </div>
</div>

<div class="card mb-lg">
    <div class="card-body">
        <div style="display: flex; gap: var(--spacing-md);">
            <div style="flex: 1;">
                <input type="text" class="form-input" placeholder="Search medicines..." id="medicineSearch"
                       style="background: var(--bg-input);" onkeyup="filterMedicines()">
            </div>
            <select class="form-input" style="width: 150px; background: var(--bg-input);" onchange="filterMedicines()">
                <option value="">All Types</option>
                <option value="tablet">Tablet</option>
                <option value="capsule">Capsule</option>
                <option value="liquid">Liquid</option>
                <option value="injection">Injection</option>
            </select>
        </div>
    </div>
</div>

<div id="medicines-list">
    <?php if (!empty($medicines)): ?>
    <div class="medicine-list" id="medicineListContainer">
        <?php foreach ($medicines as $medicine): ?>
        <div class="medicine-item" data-form="<?= strtolower($medicine['form'] ?? 'tablet') ?>">
            <div class="medicine-icon">
                <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
            </div>
            <div class="medicine-info">
                <div class="medicine-name"><?= htmlspecialchars($medicine['verifiedName'] ?? 'Unknown Medicine') ?></div>
                <div class="medicine-details">
                    <?= htmlspecialchars($medicine['brandName'] ?? '') ?><?= !empty($medicine['brandName']) ? ' - ' : '' ?>
                    <?= htmlspecialchars($medicine['strength'] ?? '') ?>
                    <?= !empty($medicine['form']) ? ' ' . htmlspecialchars($medicine['form']) : '' ?>
                </div>
            </div>
            <?php if (isset($medicine['quantity'])): ?>
            <div class="medicine-stock">
                <span class="stock-badge <?= $medicine['quantity'] > 10 ? 'in-stock' : ($medicine['quantity'] > 0 ? 'low-stock' : 'out-of-stock') ?>">
                    <?= $medicine['quantity'] ?> left
                </span>
            </div>
            <?php endif; ?>
        </div>
        <?php endforeach; ?>
    </div>
    <?php else: ?>
    <div class="empty-state">
        <div class="empty-state-icon">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
        </div>
        <div class="empty-state-title">No Medicines</div>
        <div class="empty-state-text">Add medicines from the mobile app to see them here</div>
    </div>
    <?php endif; ?>
</div>

<script>
function filterMedicines() {
    const search = document.getElementById('medicineSearch').value.toLowerCase();
    const typeFilter = document.querySelector('select.form-input').value.toLowerCase();
    const items = document.querySelectorAll('.medicine-item');

    items.forEach(item => {
        const name = item.querySelector('.medicine-name').textContent.toLowerCase();
        const form = item.dataset.form || '';
        const matchesSearch = name.includes(search);
        const matchesType = !typeFilter || form.includes(typeFilter);

        item.style.display = matchesSearch && matchesType ? 'flex' : 'none';
    });
}
</script>

<?php

$content = ob_get_clean();

require_once __DIR__ . '/../layouts/main.php';