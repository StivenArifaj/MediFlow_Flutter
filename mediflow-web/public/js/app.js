/**
 * MediFlow Web Dashboard - Main Application
 */

// Wait for DOM to be ready
document.addEventListener('DOMContentLoaded', () => {
    // Initialize app
    MediFlow.init();
});

const MediFlow = {
    // Current page
    currentPage: null,
    
    // Demo data for when Firebase isn't connected
    demoData: {
        medicines: [
            { id: '1', verifiedName: 'Aspirin', brandName: 'Bayer', strength: '100mg', form: 'Tablet', apiSource: 'openFDA' },
            { id: '2', verifiedName: 'Metformin', brandName: 'Glucophage', strength: '500mg', form: 'Tablet', apiSource: 'manual' },
            { id: '3', verifiedName: 'Lisinopril', brandName: 'Zestril', strength: '10mg', form: 'Tablet', apiSource: 'manual' },
            { id: '4', verifiedName: 'Atorvastatin', brandName: 'Lipitor', strength: '20mg', form: 'Tablet', apiSource: 'openFDA' },
            { id: '5', verifiedName: 'Omeprazole', brandName: 'Prilosec', strength: '20mg', form: 'Capsule', apiSource: 'manual' }
        ],
        history: [
            { id: '1', status: 'taken', medicineName: 'Aspirin', timestamp: Math.floor(Date.now() / 1000) - 3600 },
            { id: '2', status: 'taken', medicineName: 'Metformin', timestamp: Math.floor(Date.now() / 1000) - 7200 },
            { id: '3', status: 'skipped', medicineName: 'Lisinopril', timestamp: Math.floor(Date.now() / 1000) - 10800 },
            { id: '4', status: 'taken', medicineName: 'Atorvastatin', timestamp: Math.floor(Date.now() / 1000) - 14400 },
            { id: '5', status: 'missed', medicineName: 'Omeprazole', timestamp: Math.floor(Date.now() / 1000) - 18000 },
            { id: '6', status: 'taken', medicineName: 'Aspirin', timestamp: Math.floor(Date.now() / 1000) - 86400 },
            { id: '7', status: 'taken', medicineName: 'Metformin', timestamp: Math.floor(Date.now() / 1000) - 90000 },
            { id: '8', status: 'taken', medicineName: 'Lisinopril', timestamp: Math.floor(Date.now() / 1000) - 93600 }
        ],
        healthMetrics: {
            'Blood Pressure': { value: 120, unit: 'mmHg', recordedAt: Math.floor(Date.now() / 1000) - 86400 },
            'Heart Rate': { value: 72, unit: 'bpm', recordedAt: Math.floor(Date.now() / 1000) - 86400 },
            'Blood Glucose': { value: 95, unit: 'mg/dL', recordedAt: Math.floor(Date.now() / 1000) - 43200 },
            'Weight': { value: 75, unit: 'kg', recordedAt: Math.floor(Date.now() / 1000) - 172800 },
            'Temperature': { value: 36.8, unit: '°C', recordedAt: Math.floor(Date.now() / 1000) - 259200 },
            'SpO2': { value: 98, unit: '%', recordedAt: Math.floor(Date.now() / 1000) - 86400 },
            'Steps': { value: 8500, unit: 'steps', recordedAt: Math.floor(Date.now() / 1000) - 3600 },
            'Sleep': { value: 7.5, unit: 'hrs', recordedAt: Math.floor(Date.now() / 1000) - 28800 },
            'Water Intake': { value: 8, unit: 'glasses', recordedAt: Math.floor(Date.now() / 1000) - 1800 },
            'BMI': { value: 24.2, unit: '', recordedAt: Math.floor(Date.now() / 1000) - 172800 },
            'Cholesterol': { value: 185, unit: 'mg/dL', recordedAt: Math.floor(Date.now() / 1000) - 604800 },
            'Waist': { value: 82, unit: 'cm', recordedAt: Math.floor(Date.now() / 1000) - 259200 },
            'Respiratory Rate': { value: 16, unit: '/min', recordedAt: Math.floor(Date.now() / 1000) - 172800 }
        }
    },
    
    // Initialize
    init() {
        this.detectPage();
        this.loadPageData();
    },
    
    // Detect current page
    detectPage() {
        const path = window.location.pathname;
        if (path.includes('login')) {
            this.currentPage = 'login';
        } else if (path.includes('dashboard')) {
            this.currentPage = 'dashboard';
        } else if (path.includes('medicines')) {
            this.currentPage = 'medicines';
        } else if (path.includes('history')) {
            this.currentPage = 'history';
        } else if (path.includes('health')) {
            this.currentPage = 'health';
        } else {
            this.currentPage = 'dashboard';
        }
    },
    
    // Load data for current page
    loadPageData() {
        switch (this.currentPage) {
            case 'dashboard':
                this.loadDashboard();
                break;
            case 'medicines':
                this.loadMedicines();
                break;
            case 'history':
                this.loadHistory();
                break;
            case 'health':
                this.loadHealth();
                break;
        }
    },
    
    // ============ DASHBOARD ============
    
    async loadDashboard() {
        const container = document.getElementById('dashboard-content');
        if (!container) return;
        
        // Show loading
        container.innerHTML = this.renderLoading();
        
        try {
            // Try to get data from API
            const [stats, history, medicines] = await Promise.all([
                MediFlowAPI.getStats().catch(() => this.calculateStatsFromHistory(this.demoData.history)),
                MediFlowAPI.getTodayHistory().catch(() => this.demoData.history),
                MediFlowAPI.getMedicines().catch(() => this.demoData.medicines)
            ]);
            
            container.innerHTML = this.renderDashboard(stats, history, medicines);
            this.initDashboardCharts();
        } catch (error) {
            // Use demo data if API fails
            const stats = this.calculateStatsFromHistory(this.demoData.history);
            container.innerHTML = this.renderDashboard(stats, this.demoData.history, this.demoData.medicines);
            this.initDashboardCharts();
        }
    },
    
    calculateStatsFromHistory(history) {
        const taken = history.filter(h => h.status === 'taken').length;
        const skipped = history.filter(h => h.status === 'skipped').length;
        const missed = history.filter(h => h.status === 'missed').length;
        const total = history.length;
        
        return {
            taken,
            skipped,
            missed,
            total,
            adherence: total > 0 ? Math.round((taken / total) * 100) : 0
        };
    },
    
    initDashboardCharts() {
        // Initialize adherence ring
        const ringCanvas = document.getElementById('adherence-ring');
        if (ringCanvas) {
            const percentage = parseInt(ringCanvas.dataset.percentage) || 0;
            ringCanvas.innerHTML = this.renderAdherenceRing(percentage);
        }
        
        // Initialize streak calendar
        const calendar = document.getElementById('streak-calendar');
        if (calendar) {
            MediFlowCharts.createStreakCalendar(calendar, this.demoData.history);
        }
    },
    
    // ============ MEDICINES ============
    
    async loadMedicines() {
        const container = document.getElementById('medicines-list');
        if (!container) return;
        
        container.innerHTML = this.renderLoading();
        
        try {
            const medicines = await MediFlowAPI.getMedicines().catch(() => this.demoData.medicines);
            container.innerHTML = this.renderMedicines(medicines);
        } catch (error) {
            container.innerHTML = this.renderMedicines(this.demoData.medicines);
        }
    },
    
    // ============ HISTORY ============
    
    async loadHistory() {
        const container = document.getElementById('history-list');
        if (!container) return;
        
        container.innerHTML = this.renderLoading();
        
        try {
            const history = await MediFlowAPI.getHistory().catch(() => this.demoData.history);
            container.innerHTML = this.renderHistory(history);
        } catch (error) {
            container.innerHTML = this.renderHistory(this.demoData.history);
        }
    },
    
    // ============ HEALTH ============
    
    async loadHealth() {
        const container = document.getElementById('health-grid');
        if (!container) return;
        
        container.innerHTML = this.renderLoading();
        
        // Health metrics come from demo data
        container.innerHTML = this.renderHealthMetrics(this.demoData.healthMetrics);
    },
    
    // ============ RENDERING ============
    
    renderLoading() {
        return `
            <div class="loading">
                <div class="spinner"></div>
            </div>
        `;
    },
    
    renderDashboard(stats, history, medicines) {
        const todayHistory = history.filter(h => {
            const today = new Date().setHours(0, 0, 0, 0);
            const entryTime = (h.timestamp || 0) * 1000;
            return entryTime >= today;
        });
        
        const todayTaken = todayHistory.filter(h => h.status === 'taken').length;
        const todayTotal = todayHistory.length;
        
        return `
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div class="stat-card-icon taken">
                            <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                        </div>
                    </div>
                    <div class="stat-card-value" style="color: var(--primary)">${todayTaken}</div>
                    <div class="stat-card-label">Taken Today</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div class="stat-card-icon skipped">
                            <svg viewBox="0 0 24 24"><path d="M6 18l8.5-6L6 6v12zM16 6v12h2V6h-2z"/></svg>
                        </div>
                    </div>
                    <div class="stat-card-value" style="color: var(--info)">${todayHistory.filter(h => h.status === 'skipped').length}</div>
                    <div class="stat-card-label">Skipped Today</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div class="stat-card-icon missed">
                            <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                        </div>
                    </div>
                    <div class="stat-card-value" style="color: var(--error)">${todayHistory.filter(h => h.status === 'missed').length}</div>
                    <div class="stat-card-label">Missed Today</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div class="stat-card-icon adherence">
                            <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                        </div>
                    </div>
                    <div class="stat-card-value" style="color: var(--success)">${stats.adherence}%</div>
                    <div class="stat-card-label">Overall Adherence</div>
                </div>
            </div>
            
            <!-- Adherence Section -->
            <div class="adherence-section">
                <div class="card-header">
                    <h3 class="card-title">Medication Adherence</h3>
                    <span class="text-secondary">Last 30 Days</span>
                </div>
                <div class="card-body">
                    <div class="adherence-ring-container">
                        <div class="adherence-ring" id="adherence-ring" data-percentage="${stats.adherence}">
                            ${this.renderAdherenceRing(stats.adherence)}
                        </div>
                        <div class="adherence-stats">
                            <div class="adherence-stat">
                                <div class="adherence-stat-value" style="color: var(--primary)">${stats.taken}</div>
                                <div class="adherence-stat-label">Taken</div>
                            </div>
                            <div class="adherence-stat">
                                <div class="adherence-stat-value" style="color: var(--info)">${stats.skipped}</div>
                                <div class="adherence-stat-label">Skipped</div>
                            </div>
                            <div class="adherence-stat">
                                <div class="adherence-stat-value" style="color: var(--error)">${stats.missed}</div>
                                <div class="adherence-stat-label">Missed</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Today's Schedule & Quick Stats -->
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: var(--spacing-lg);">
                <!-- Today's Schedule -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Today's Schedule</h3>
                        <a href="?page=history" class="btn btn-sm btn-ghost">View All</a>
                    </div>
                    <div class="card-body">
                        ${todayHistory.length > 0 ? this.renderTodaySchedule(todayHistory) : this.renderEmptyState('No medications scheduled for today')}
                    </div>
                </div>
                
                <!-- Quick Stats -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Quick Stats</h3>
                    </div>
                    <div class="card-body">
                        <div style="margin-bottom: var(--spacing-md)">
                            <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Active Medicines</div>
                            <div style="font-size: 1.5rem; font-weight: 700">${medicines.length}</div>
                        </div>
                        <div style="margin-bottom: var(--spacing-md)">
                            <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Current Streak</div>
                            <div style="font-size: 1.5rem; font-weight: 700">🔥 ${this.calculateStreak(history)} days</div>
                        </div>
                        <div>
                            <div class="text-secondary" style="font-size: 0.75rem; margin-bottom: var(--spacing-xs)">Next Reminder</div>
                            <div style="font-size: 1rem; font-weight: 600">08:00 - Metformin</div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    },
    
    renderAdherenceRing(percentage) {
        const radius = 70;
        const circumference = 2 * Math.PI * radius;
        const offset = circumference - (percentage / 100) * circumference;
        
        return `
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
                    style="font-size: 2.5rem; font-weight: 800; fill: var(--primary)">${percentage}%</text>
                <text x="90" y="110" text-anchor="middle" 
                    style="font-size: 0.75rem; fill: var(--text-secondary)">adherence</text>
            </svg>
        `;
    },
    
    renderTodaySchedule(history) {
        return history.slice(0, 5).map(entry => `
            <div class="history-item" style="margin-bottom: var(--spacing-sm)">
                <div class="history-time">${this.formatTime(entry.timestamp)}</div>
                <div class="history-content" style="padding: var(--spacing-sm)">
                    <span class="history-status ${entry.status}">${entry.status}</span>
                    <div style="font-weight: 600; margin-top: var(--spacing-xs)">${entry.medicineName || 'Medicine'}</div>
                </div>
            </div>
        `).join('');
    },
    
    renderMedicines(medicines) {
        if (!medicines || medicines.length === 0) {
            return this.renderEmptyState('No medicines added yet');
        }
        
        return `
            <div class="medicine-list">
                ${medicines.map(medicine => `
                    <div class="medicine-item">
                        <div class="medicine-icon">
                            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                        </div>
                        <div class="medicine-info">
                            <div class="medicine-name">${medicine.verifiedName || 'Unknown Medicine'}</div>
                            <div class="medicine-details">
                                ${medicine.brandName ? medicine.brandName + ' - ' : ''}
                                ${medicine.strength || ''}
                                ${medicine.form ? ' ' + medicine.form : ''}
                            </div>
                        </div>
                        <span class="medicine-badge ${medicine.apiSource || 'manual'}">${medicine.apiSource === 'openFDA' ? 'OpenFDA ✓' : 'Manual'}</span>
                    </div>
                `).join('')}
            </div>
        `;
    },
    
    renderHistory(history) {
        if (!history || history.length === 0) {
            return this.renderEmptyState('No history records yet');
        }
        
        // Group by date
        const grouped = {};
        history.forEach(entry => {
            const date = new Date((entry.timestamp || 0) * 1000).toLocaleDateString();
            if (!grouped[date]) grouped[date] = [];
            grouped[date].push(entry);
        });
        
        return Object.entries(grouped).map(([date, entries]) => `
            <div class="mb-lg">
                <h4 class="text-secondary mb-md" style="font-size: 0.875rem; font-weight: 600">${date}</h4>
                <div class="history-timeline">
                    ${entries.map(entry => `
                        <div class="history-item">
                            <div class="history-time">${this.formatTime(entry.timestamp)}</div>
                            <div class="history-content">
                                <span class="history-status ${entry.status}">${entry.status}</span>
                                <div class="history-medicine">${entry.medicineName || 'Medicine'}</div>
                                <div class="history-scheduled">Scheduled: ${this.formatDateTime(entry.timestamp)}</div>
                            </div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `).join('');
    },
    
    renderHealthMetrics(metrics) {
        const metricIcons = {
            'Weight': 'monitor_weight',
            'Blood Pressure': 'favorite',
            'Heart Rate': 'favorite_rounded',
            'Blood Glucose': 'water_drop',
            'Temperature': 'thermostat',
            'SpO2': 'air',
            'Steps': 'directions_walk',
            'Sleep': 'bedtime',
            'Water Intake': 'local_drink',
            'BMI': 'accessibility_new',
            'Cholesterol': 'opacity',
            'Waist': 'straighten',
            'Respiratory Rate': 'waves'
        };
        
        const metricColors = {
            'Weight': '#00E5FF',
            'Blood Pressure': '#FF4D6A',
            'Heart Rate': '#FF4D6A',
            'Blood Glucose': '#00C896',
            'Temperature': '#FFB800',
            'SpO2': '#6B7FCC',
            'Steps': '#00C896',
            'Sleep': '#8B5CF6',
            'Water Intake': '#00E5FF',
            'BMI': '#00E5FF',
            'Cholesterol': '#FFB800',
            'Waist': '#6B7FCC',
            'Respiratory Rate': '#FF7F7F'
        };
        
        return `
            <div class="health-grid">
                ${Object.entries(metrics).map(([type, data]) => `
                    <div class="health-metric">
                        <div class="health-metric-icon" style="background: linear-gradient(135deg, ${metricColors[type]}20, ${metricColors[type]}40)">
                            <svg viewBox="0 0 24 24" style="fill: ${metricColors[type]}">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                            </svg>
                        </div>
                        <div class="health-metric-name">${type}</div>
                        <div class="health-metric-value" style="color: ${metricColors[type]}">
                            ${data.value}
                            <span class="health-metric-unit">${data.unit}</span>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    },
    
    renderEmptyState(message) {
        return `
            <div class="empty-state">
                <div class="empty-state-icon">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                </div>
                <div class="empty-state-title">No Data</div>
                <div class="empty-state-text">${message}</div>
            </div>
        `;
    },
    
    // ============ HELPERS ============
    
    calculateStreak(history) {
        if (!history || history.length === 0) return 0;
        
        let streak = 0;
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        
        // Group by date
        const byDate = {};
        history.forEach(entry => {
            const date = new Date((entry.timestamp || 0) * 1000);
            date.setHours(0, 0, 0, 0);
            const key = date.toISOString().split('T')[0];
            if (!byDate[key]) byDate[key] = [];
            byDate[key].push(entry);
        });
        
        // Count backwards from today
        let checkDate = new Date(today);
        for (let i = 0; i < 365; i++) {
            const key = checkDate.toISOString().split('T')[0];
            const dayEntries = byDate[key];
            
            if (dayEntries) {
                const hasMissed = dayEntries.some(e => e.status === 'missed');
                if (!hasMissed) {
                    streak++;
                } else {
                    break;
                }
            } else if (i > 0) {
                break;
            }
            
            checkDate.setDate(checkDate.getDate() - 1);
        }
        
        return streak;
    },
    
    formatTime(timestamp) {
        if (!timestamp) return '—';
        const date = new Date(timestamp * 1000);
        return date.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: false });
    },
    
    formatDateTime(timestamp) {
        if (!timestamp) return '—';
        const date = new Date(timestamp * 1000);
        return date.toLocaleDateString('en-US', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
    }
};

// Export for global use
window.MediFlow = MediFlow;