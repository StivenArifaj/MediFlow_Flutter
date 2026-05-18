/**
 * MediFlow API Client
 * Handles all communication with the PHP backend API
 */

const MediFlowAPI = {
    baseUrl: '',

    async request(endpoint, options = {}) {
        const url = this.baseUrl + endpoint;
        const defaultOptions = {
            credentials: 'same-origin'
        };

        try {
            const response = await fetch(url, { ...defaultOptions, ...options });
            const data = await response.json();
            return data;
        } catch (error) {
            console.error('API Error:', error);
            return { success: false, error: error.message };
        }
    },

    async getStats() {
        return this.request('/?page=api&api_action=stats');
    },

    async getMedicines() {
        return this.request('/?page=api&api_action=medicines');
    },

    async getReminders() {
        return this.request('/?page=api&api_action=reminders');
    },

    async getHistory(limit = 100) {
        return this.request(`/?page=api&api_action=history`);
    },

    async getTodayHistory() {
        return this.request('/?page=api&api_action=today_history');
    },

    async getLinkedPatient() {
        return this.request('/?page=api&api_action=linked_patient');
    },

    calculateStats(history) {
        const taken = history.filter(h => h.status === 'taken').length;
        const skipped = history.filter(h => h.status === 'skipped').length;
        const missed = history.filter(h => h.status === 'missed').length;
        const total = history.length;
        const adherence = total > 0 ? Math.round((taken / total) * 100) : 0;

        return { taken, skipped, missed, total, adherence };
    },

    groupHistoryByDate(history) {
        const grouped = {};
        history.forEach(entry => {
            const date = new Date(entry.timestamp).toLocaleDateString();
            if (!grouped[date]) grouped[date] = [];
            grouped[date].push(entry);
        });
        return grouped;
    },

    getHistoryForPeriod(history, days) {
        const now = new Date();
        const cutoff = new Date(now.getTime() - (days * 24 * 60 * 60 * 1000));

        return history.filter(entry => {
            const entryDate = new Date(entry.timestamp);
            return entryDate >= cutoff;
        });
    }
};

const MediFlowCharts = {
    colors: {
        primary: '#00E5FF',
        success: '#00C896',
        warning: '#FFB800',
        error: '#FF3B5C',
        info: '#6B7FCC',
        purple: '#8B5CF6'
    },

    createAdherenceRing(canvasId, percentage) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        const radius = 70;
        const circumference = 2 * Math.PI * radius;
        const offset = circumference - (percentage / 100) * circumference;

        canvas.innerHTML = `
            <svg width="180" height="180" viewBox="0 0 180 180">
                <defs>
                    <linearGradient id="adherenceGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" style="stop-color:${this.colors.primary}"/>
                        <stop offset="100%" style="stop-color:#0080FF"/>
                    </linearGradient>
                </defs>
                <circle cx="90" cy="90" r="${radius}" fill="none" stroke="#162032" stroke-width="12"/>
                <circle cx="90" cy="90" r="${radius}" fill="none" stroke="url(#adherenceGradient)" stroke-width="12"
                    stroke-linecap="round" stroke-dasharray="${circumference}"
                    stroke-dashoffset="${offset}" transform="rotate(-90 90 90)"/>
                <text x="90" y="90" text-anchor="middle" dy="0.35em"
                    style="font-size: 2.5rem; font-weight: 800; fill: ${this.colors.primary}">${percentage}%</text>
                <text x="90" y="110" text-anchor="middle"
                    style="font-size: 0.75rem; fill: #8A9BB5">adherence</text>
            </svg>
        `;
    },

    createBarChart(canvasId, labels, datasets, options = {}) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return null;

        const ctx = canvas.getContext('2d');
        return new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: datasets
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: options.legend !== false,
                        position: 'bottom',
                        labels: { color: '#8A9BB5', padding: 20 }
                    }
                },
                scales: {
                    x: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' }
                    },
                    y: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' },
                        beginAtZero: true
                    }
                },
                ...options
            }
        });
    },

    createLineChart(canvasId, labels, datasets, options = {}) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return null;

        const ctx = canvas.getContext('2d');
        return new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: datasets
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: options.legend !== false,
                        position: 'bottom',
                        labels: { color: '#8A9BB5', padding: 20 }
                    }
                },
                scales: {
                    x: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' }
                    },
                    y: {
                        grid: { color: '#162032' },
                        ticks: { color: '#8A9BB5' }
                    }
                },
                ...options
            }
        });
    },

    createDoughnutChart(canvasId, labels, data, colors, options = {}) {
        const canvas = document.getElementById(canvasId);
        if (!canvas) return null;

        const ctx = canvas.getContext('2d');
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
                        display: options.legend !== false,
                        position: 'bottom',
                        labels: { color: '#8A9BB5', padding: 20 }
                    }
                },
                ...options
            }
        });
    },

    prepareAdherenceData(history) {
        const last30Days = MediFlowAPI.getHistoryForPeriod(history, 30);

        const byDate = {};
        last30Days.forEach(entry => {
            const date = new Date(entry.timestamp).toLocaleDateString();
            if (!byDate[date]) byDate[date] = { taken: 0, skipped: 0, missed: 0 };

            if (entry.status === 'taken') byDate[date].taken++;
            else if (entry.status === 'skipped') byDate[date].skipped++;
            else if (entry.status === 'missed') byDate[date].missed++;
        });

        const labels = Object.keys(byDate).slice(-7);
        const taken = labels.map(d => byDate[d].taken);
        const missed = labels.map(d => byDate[d].missed);

        return { labels, taken, missed };
    }
};

window.MediFlowAPI = MediFlowAPI;
window.MediFlowCharts = MediFlowCharts;