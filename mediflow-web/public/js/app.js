/**
 * MediFlow Web Dashboard - UI Enhancements
 * PHP renders all page content. This file handles client-side UI only.
 */

document.addEventListener('DOMContentLoaded', () => {
    MediFlow.init();
});

const MediFlow = {
    init() {
        this.initAdherenceRing();
        this.initMedicineFilter();
    },

    // Animate the adherence ring SVG already rendered by PHP
    initAdherenceRing() {
        const ring = document.getElementById('adherence-ring');
        if (!ring) return;
        const percentage = parseInt(ring.dataset.percentage) || 0;
        const radius = 70;
        const circumference = 2 * Math.PI * radius;
        const offset = circumference - (percentage / 100) * circumference;

        const circle = ring.querySelector('circle:last-of-type');
        if (circle) {
            circle.style.transition = 'stroke-dashoffset 1s ease';
            circle.setAttribute('stroke-dashoffset', offset);
        }
    },

    // Wire up the medicine search/filter on the medicines page
    initMedicineFilter() {
        const searchInput = document.getElementById('medicineSearch');
        if (!searchInput) return;

        searchInput.addEventListener('input', filterMedicines);

        const typeSelect = document.querySelector('select.form-input');
        if (typeSelect) {
            typeSelect.addEventListener('change', filterMedicines);
        }
    },

    formatTime(timestamp) {
        if (!timestamp) return '—';
        return new Date(timestamp * 1000).toLocaleTimeString('en-US', {
            hour: '2-digit', minute: '2-digit', hour12: false,
        });
    },
};

function filterMedicines() {
    const search = (document.getElementById('medicineSearch')?.value || '').toLowerCase();
    const typeSelect = document.querySelector('select.form-input');
    const typeFilter = typeSelect ? typeSelect.value.toLowerCase() : '';

    document.querySelectorAll('.medicine-item').forEach(item => {
        const name = (item.querySelector('.medicine-name')?.textContent || '').toLowerCase();
        const form = (item.dataset.form || '').toLowerCase();
        const matchesSearch = name.includes(search);
        const matchesType = !typeFilter || form.includes(typeFilter);
        item.style.display = matchesSearch && matchesType ? 'flex' : 'none';
    });
}

window.MediFlow = MediFlow;
