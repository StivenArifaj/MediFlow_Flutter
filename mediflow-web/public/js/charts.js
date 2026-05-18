/**
 * MediFlow Charts
 * Chart.js configurations for dashboard visualizations
 */

const MediFlowCharts = {
    charts: {},

    init() {
        this.initAdherenceRing();
        this.initHistoryChart();
        this.initWeeklyChart();
    },

    initAdherenceRing() {
        const ring = document.getElementById('adherence-ring');
        if (!ring) return;

        const percentage = parseInt(ring.dataset.percentage) || 0;
        const radius = 70;
        const circumference = 2 * Math.PI * radius;
        const offset = circumference - (percentage / 100) * circumference;

        ring.innerHTML = `
            <svg width="180" height="180" viewBox="0 0 180 180">
                <defs>
                    <linearGradient id="adherenceGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" style="stop-color:#00E5FF"/>
                        <stop offset="100%" style="stop-color:#0080FF"/>
                    </linearGradient>
                </defs>
                <circle cx="90" cy="90" r="${radius}" fill="none" stroke="#162032" stroke-width="12"/>
                <circle cx="90" cy="90" r="${radius}" fill="none" stroke="url(#adherenceGradient)" stroke-width="12"
                    stroke-linecap="round" stroke-dasharray="${circumference}"
                    stroke-dashoffset="${offset}" transform="rotate(-90 90 90)"/>
                <text x="90" y="90" text-anchor="middle" dy="0.35em"
                    style="font-size: 2.5rem; font-weight: 800; fill: #00E5FF">${percentage}%</text>
                <text x="90" y="110" text-anchor="middle"
                    style="font-size: 0.75rem; fill: #8A9BB5">adherence</text>
            </svg>
        `;
    },

    initHistoryChart() {
        const ctx = document.getElementById('historyChart');
        if (!ctx) return;

        if (this.charts.history) {
            this.charts.history.destroy();
        }

        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const takenData = [5, 4, 6, 5, 4, 3, 5];
        const missedData = [1, 0, 1, 0, 2, 1, 0];

        this.charts.history = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Taken',
                        data: takenData,
                        backgroundColor: '#00E5FF',
                        borderRadius: 6,
                        barPercentage: 0.6
                    },
                    {
                        label: 'Missed',
                        data: missedData,
                        backgroundColor: '#FF3B5C',
                        borderRadius: 6,
                        barPercentage: 0.6
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#8A9BB5',
                            padding: 20,
                            usePointStyle: true
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#8A9BB5' }
                    },
                    y: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' },
                        beginAtZero: true
                    }
                }
            }
        });
    },

    initWeeklyChart() {
        const ctx = document.getElementById('weeklyChart');
        if (!ctx) return;

        if (this.charts.weekly) {
            this.charts.weekly.destroy();
        }

        const labels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        const adherenceData = [75, 82, 78, 85];

        this.charts.weekly = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Adherence %',
                    data: adherenceData,
                    borderColor: '#00E5FF',
                    backgroundColor: 'rgba(0, 229, 255, 0.1)',
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#00E5FF',
                    pointBorderColor: '#00E5FF',
                    pointRadius: 6,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        ticks: { color: '#8A9BB5' }
                    },
                    y: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' },
                        min: 0,
                        max: 100
                    }
                }
            }
        });
    },

    createDoughnut(canvasId, labels, data, colors) {
        const ctx = document.getElementById(canvasId);
        if (!ctx) return null;

        return new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: data,
                    backgroundColor: colors,
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#8A9BB5',
                            padding: 15,
                            usePointStyle: true
                        }
                    }
                }
            }
        });
    }
};

if (typeof Chart !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        MediFlowCharts.init();
    });
}