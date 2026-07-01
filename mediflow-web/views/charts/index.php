<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../config/functions.php';

$pageTitle = 'Charts';

// ── Process raw data ──────────────────────────────────────────────────────────

$history   = $history   ?? [];
$medicines = $medicines ?? [];
$stats     = $stats     ?? [];

// 1. Adherence overview (doughnut)
$adh_taken   = (int)($stats['taken']   ?? 0);
$adh_skipped = (int)($stats['skipped'] ?? 0);
$adh_missed  = (int)($stats['missed']  ?? 0);

// 2. 30-day adherence trend (line) — group history by calendar date
$trendDays    = 30;
$trendData    = [];     // date => ['taken'=>0,'total'=>0]
$trendLabels  = [];
$trendPct     = [];

for ($i = $trendDays - 1; $i >= 0; $i--) {
    $d = date('Y-m-d', strtotime("-$i days"));
    $trendData[$d] = ['taken' => 0, 'total' => 0];
}
foreach ($history as $h) {
    $ts = $h['timestamp'] ?? '';
    if (!$ts) continue;
    $d = date('Y-m-d', is_numeric($ts) ? $ts : strtotime($ts));
    if (!isset($trendData[$d])) continue;
    $trendData[$d]['total']++;
    if (($h['status'] ?? '') === 'taken') $trendData[$d]['taken']++;
}
foreach ($trendData as $d => $v) {
    $trendLabels[] = date('M j', strtotime($d));
    $trendPct[]    = $v['total'] > 0 ? round($v['taken'] / $v['total'] * 100) : null;
}

// 3. Per-medicine adherence (bar)
$medNames      = [];
$medTaken      = [];
$medSkipped    = [];
$medMissed     = [];
$medAgg        = [];  // name => [taken,skipped,missed]
foreach ($history as $h) {
    $n = $h['medicineName'] ?? 'Unknown';
    if (!isset($medAgg[$n])) $medAgg[$n] = ['taken' => 0, 'skipped' => 0, 'missed' => 0];
    $s = $h['status'] ?? '';
    if (isset($medAgg[$n][$s])) $medAgg[$n][$s]++;
}
// Sort by total desc, cap at 10
uasort($medAgg, fn($a, $b) => array_sum($b) <=> array_sum($a));
$medAgg = array_slice($medAgg, 0, 10, true);
foreach ($medAgg as $n => $v) {
    $medNames[]   = $n;
    $medTaken[]   = $v['taken'];
    $medSkipped[] = $v['skipped'];
    $medMissed[]  = $v['missed'];
}

// 4. Day-of-week pattern (bar) — Mon-Sun
$dowLabels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
$dowTaken  = array_fill(0, 7, 0);
$dowMissed = array_fill(0, 7, 0);
foreach ($history as $h) {
    $ts = $h['timestamp'] ?? '';
    if (!$ts) continue;
    $dow = (int)date('N', is_numeric($ts) ? $ts : strtotime($ts)) - 1; // 0=Mon
    if (($h['status'] ?? '') === 'taken')  $dowTaken[$dow]++;
    if (($h['status'] ?? '') === 'missed') $dowMissed[$dow]++;
}

// 5. Time-of-day distribution (bar) — Morning/Afternoon/Evening/Night
$todLabels = ['Night (0-6h)', 'Morning (6-12h)', 'Afternoon (12-18h)', 'Evening (18-24h)'];
$todCounts = array_fill(0, 4, 0);
foreach ($history as $h) {
    if (($h['status'] ?? '') !== 'taken') continue;
    $ts   = $h['timestamp'] ?? '';
    if (!$ts) continue;
    $hour = (int)date('G', is_numeric($ts) ? $ts : strtotime($ts));
    if ($hour < 6)       $todCounts[0]++;
    elseif ($hour < 12)  $todCounts[1]++;
    elseif ($hour < 18)  $todCounts[2]++;
    else                 $todCounts[3]++;
}

// 6. Medicine form distribution (doughnut)
$formCounts = [];
foreach ($medicines as $m) {
    $f = ucfirst(strtolower($m['form'] ?? 'Unknown'));
    $formCounts[$f] = ($formCounts[$f] ?? 0) + 1;
}
$formLabels = array_keys($formCounts);
$formValues = array_values($formCounts);

// 7. Stock levels (horizontal bar) — cap at 15 medicines
$stockNames  = [];
$stockValues = [];
$stockSorted = $medicines;
usort($stockSorted, fn($a, $b) => (float)($a['remainingStock'] ?? $a['currentStock'] ?? 0) <=> (float)($b['remainingStock'] ?? $b['currentStock'] ?? 0));
foreach (array_slice($stockSorted, 0, 15) as $m) {
    $qty = (float)($m['remainingStock'] ?? $m['currentStock'] ?? $m['quantity'] ?? 0);
    $stockNames[]  = $m['name'] ?? 'Unknown';
    $stockValues[] = $qty;
}

$hasHistory   = count($history)   > 0;
$hasMedicines = count($medicines) > 0;
$hasStats     = ($adh_taken + $adh_skipped + $adh_missed) > 0;

ob_start();
?>

<div class="page-header">
    <div>
        <h1 class="page-title">Charts</h1>
        <p class="page-subtitle">Visual overview of your medication data.</p>
    </div>
</div>

<?php if (!$hasHistory && !$hasMedicines): ?>
<div style="display:flex;align-items:center;gap:10px;background:rgba(0,229,255,0.06);border:1px solid rgba(0,229,255,0.15);border-radius:12px;padding:14px 20px;margin-bottom:var(--spacing-xl)">
    <svg viewBox="0 0 24 24" style="width:20px;height:20px;fill:#00E5FF;flex-shrink:0"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
    <span style="font-size:0.875rem;color:var(--text-secondary)">No medication data found. Use the <strong style="color:var(--text-primary)">MediFlow mobile app</strong> to add medicines and record doses, then return here to see your charts.</span>
</div>
<?php endif; ?>

<!-- Row 1: Adherence overview + 30-day trend -->
<div style="display:grid;grid-template-columns:1fr 2fr;gap:var(--spacing-lg);margin-bottom:var(--spacing-lg)">

    <!-- Adherence Doughnut -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Adherence Breakdown</h3>
            <span class="text-secondary">All time</span>
        </div>
        <div class="card-body" style="display:flex;flex-direction:column;align-items:center">
            <?php if ($hasStats): ?>
            <div style="position:relative;width:200px;height:200px">
                <canvas id="chartAdherenceDoughnut"></canvas>
                <div style="position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);text-align:center">
                    <div style="font-size:1.6rem;font-weight:700;color:var(--text-primary)"><?= $stats['adherence'] ?? 0 ?>%</div>
                    <div style="font-size:0.7rem;color:var(--text-secondary)">adherence</div>
                </div>
            </div>
            <div style="display:flex;gap:16px;margin-top:16px;flex-wrap:wrap;justify-content:center">
                <div style="display:flex;align-items:center;gap:6px"><span style="width:10px;height:10px;border-radius:50%;background:#00E5FF;display:inline-block"></span><span style="font-size:0.78rem;color:var(--text-secondary)">Taken <?= $adh_taken ?></span></div>
                <div style="display:flex;align-items:center;gap:6px"><span style="width:10px;height:10px;border-radius:50%;background:#6B7FCC;display:inline-block"></span><span style="font-size:0.78rem;color:var(--text-secondary)">Skipped <?= $adh_skipped ?></span></div>
                <div style="display:flex;align-items:center;gap:6px"><span style="width:10px;height:10px;border-radius:50%;background:#FF3B5C;display:inline-block"></span><span style="font-size:0.78rem;color:var(--text-secondary)">Missed <?= $adh_missed ?></span></div>
            </div>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No data yet</div></div>
            <?php endif; ?>
        </div>
    </div>

    <!-- 30-day Trend -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">30-Day Adherence Trend</h3>
            <span class="text-secondary">Daily %</span>
        </div>
        <div class="card-body">
            <?php if ($hasHistory): ?>
            <canvas id="chartTrend" style="max-height:220px"></canvas>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No history yet</div></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Row 2: Per-medicine adherence -->
<?php if (count($medNames) > 0): ?>
<div class="card" style="margin-bottom:var(--spacing-lg)">
    <div class="card-header">
        <h3 class="card-title">Per-Medicine Adherence</h3>
        <span class="text-secondary">Top <?= count($medNames) ?> medicines</span>
    </div>
    <div class="card-body">
        <canvas id="chartPerMed" style="max-height:260px"></canvas>
    </div>
</div>
<?php endif; ?>

<!-- Row 3: Day-of-week + Time of day -->
<div style="display:grid;grid-template-columns:1fr 1fr;gap:var(--spacing-lg);margin-bottom:var(--spacing-lg)">

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Day-of-Week Pattern</h3>
            <span class="text-secondary">Taken vs missed</span>
        </div>
        <div class="card-body">
            <?php if ($hasHistory): ?>
            <canvas id="chartDow" style="max-height:220px"></canvas>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No history yet</div></div>
            <?php endif; ?>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Time of Day</h3>
            <span class="text-secondary">When doses are taken</span>
        </div>
        <div class="card-body">
            <?php if ($hasHistory): ?>
            <canvas id="chartTod" style="max-height:220px"></canvas>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No history yet</div></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Row 4: Form distribution + Stock levels -->
<div style="display:grid;grid-template-columns:1fr 2fr;gap:var(--spacing-lg);margin-bottom:var(--spacing-lg)">

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Medicine Forms</h3>
        </div>
        <div class="card-body" style="display:flex;flex-direction:column;align-items:center">
            <?php if ($hasMedicines && count($formLabels) > 0): ?>
            <canvas id="chartForms" style="max-height:200px;max-width:200px"></canvas>
            <div style="display:flex;gap:10px;margin-top:12px;flex-wrap:wrap;justify-content:center">
                <?php
                $formColors = ['#00E5FF','#FF3B5C','#00C896','#FFB800','#6B7FCC','#8B5CF6','#FF7F7F'];
                foreach ($formLabels as $i => $lbl): ?>
                <div style="display:flex;align-items:center;gap:5px">
                    <span style="width:9px;height:9px;border-radius:50%;background:<?= $formColors[$i % count($formColors)] ?>;display:inline-block"></span>
                    <span style="font-size:0.75rem;color:var(--text-secondary)"><?= htmlspecialchars($lbl) ?></span>
                </div>
                <?php endforeach; ?>
            </div>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No medicines yet</div></div>
            <?php endif; ?>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Stock Levels</h3>
            <span class="text-secondary">Remaining doses</span>
        </div>
        <div class="card-body">
            <?php if ($hasMedicines && count($stockNames) > 0): ?>
            <canvas id="chartStock" style="max-height:<?= max(160, count($stockNames) * 28) ?>px"></canvas>
            <?php else: ?>
            <div class="empty-state"><div class="empty-state-title" style="margin-top:0">No medicines yet</div></div>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php
$content = ob_get_clean();

// ── Chart.js defaults and chart init ─────────────────────────────────────────
$scripts = '<script>
(function() {
    Chart.defaults.color           = "#8899aa";
    Chart.defaults.borderColor     = "rgba(255,255,255,0.06)";
    Chart.defaults.font.family     = "Inter, sans-serif";
    Chart.defaults.font.size       = 12;
    Chart.defaults.plugins.legend.display = false;

    const T = (val, min, max, alpha) => `rgba(${min + Math.round((max-min)*val/100)},${Math.round(alpha*255)})`;

    // ── 1. Adherence doughnut ────────────────────────────────────────────────
    const dCtx = document.getElementById("chartAdherenceDoughnut");
    if (dCtx) {
        new Chart(dCtx, {
            type: "doughnut",
            data: {
                labels: ["Taken","Skipped","Missed"],
                datasets: [{
                    data: [' . $adh_taken . ',' . $adh_skipped . ',' . $adh_missed . '],
                    backgroundColor: ["#00E5FF","#6B7FCC","#FF3B5C"],
                    borderWidth: 0,
                    hoverOffset: 6
                }]
            },
            options: {
                cutout: "72%",
                plugins: { legend: { display: false }, tooltip: {
                    callbacks: { label: ctx => " " + ctx.label + ": " + ctx.parsed }
                }}
            }
        });
    }

    // ── 2. 30-day trend line ─────────────────────────────────────────────────
    const tCtx = document.getElementById("chartTrend");
    if (tCtx) {
        const labels = ' . json_encode($trendLabels) . ';
        const pct    = ' . json_encode($trendPct) . ';
        new Chart(tCtx, {
            type: "line",
            data: {
                labels,
                datasets: [{
                    label: "Adherence %",
                    data: pct,
                    borderColor: "#00E5FF",
                    backgroundColor: "rgba(0,229,255,0.08)",
                    fill: true,
                    tension: 0.35,
                    pointRadius: 3,
                    pointBackgroundColor: "#00E5FF",
                    spanGaps: true
                }]
            },
            options: {
                scales: {
                    x: { ticks: { maxTicksLimit: 10 } },
                    y: { min: 0, max: 100, ticks: { callback: v => v + "%" } }
                },
                plugins: { legend: { display: false }, tooltip: {
                    callbacks: { label: ctx => " " + (ctx.parsed.y !== null ? ctx.parsed.y + "%" : "no data") }
                }}
            }
        });
    }

    // ── 3. Per-medicine bar ──────────────────────────────────────────────────
    const pmCtx = document.getElementById("chartPerMed");
    if (pmCtx) {
        new Chart(pmCtx, {
            type: "bar",
            data: {
                labels: ' . json_encode($medNames) . ',
                datasets: [
                    { label: "Taken",   data: ' . json_encode($medTaken) . ',   backgroundColor: "#00E5FF" },
                    { label: "Skipped", data: ' . json_encode($medSkipped) . ', backgroundColor: "#6B7FCC" },
                    { label: "Missed",  data: ' . json_encode($medMissed) . ',  backgroundColor: "#FF3B5C" }
                ]
            },
            options: {
                plugins: { legend: { display: true, position: "bottom", labels: { boxWidth: 12, padding: 16 } } },
                scales: {
                    x: { stacked: false },
                    y: { stacked: false, ticks: { precision: 0 } }
                }
            }
        });
    }

    // ── 4. Day-of-week bar ───────────────────────────────────────────────────
    const dowCtx = document.getElementById("chartDow");
    if (dowCtx) {
        new Chart(dowCtx, {
            type: "bar",
            data: {
                labels: ' . json_encode($dowLabels) . ',
                datasets: [
                    { label: "Taken",  data: ' . json_encode(array_values($dowTaken)) . ',  backgroundColor: "#00E5FF" },
                    { label: "Missed", data: ' . json_encode(array_values($dowMissed)) . ', backgroundColor: "#FF3B5C" }
                ]
            },
            options: {
                plugins: { legend: { display: true, position: "bottom", labels: { boxWidth: 12, padding: 16 } } },
                scales: { y: { ticks: { precision: 0 } } }
            }
        });
    }

    // ── 5. Time-of-day bar ───────────────────────────────────────────────────
    const todCtx = document.getElementById("chartTod");
    if (todCtx) {
        new Chart(todCtx, {
            type: "bar",
            data: {
                labels: ' . json_encode($todLabels) . ',
                datasets: [{
                    label: "Doses taken",
                    data: ' . json_encode(array_values($todCounts)) . ',
                    backgroundColor: ["#8B5CF6","#00E5FF","#FFB800","#FF7F7F"],
                    borderRadius: 6
                }]
            },
            options: {
                plugins: { legend: { display: false } },
                scales: { y: { ticks: { precision: 0 } } }
            }
        });
    }

    // ── 6. Medicine forms doughnut ───────────────────────────────────────────
    const fCtx = document.getElementById("chartForms");
    if (fCtx) {
        new Chart(fCtx, {
            type: "doughnut",
            data: {
                labels: ' . json_encode($formLabels) . ',
                datasets: [{
                    data: ' . json_encode($formValues) . ',
                    backgroundColor: ["#00E5FF","#FF3B5C","#00C896","#FFB800","#6B7FCC","#8B5CF6","#FF7F7F"],
                    borderWidth: 0,
                    hoverOffset: 6
                }]
            },
            options: { cutout: "60%", plugins: { legend: { display: false } } }
        });
    }

    // ── 7. Stock horizontal bar ──────────────────────────────────────────────
    const sCtx = document.getElementById("chartStock");
    if (sCtx) {
        const stockVals = ' . json_encode($stockValues) . ';
        const maxStock  = Math.max(...stockVals, 1);
        new Chart(sCtx, {
            type: "bar",
            data: {
                labels: ' . json_encode($stockNames) . ',
                datasets: [{
                    label: "Remaining",
                    data: stockVals,
                    backgroundColor: stockVals.map(v => v <= maxStock * 0.2 ? "#FF3B5C" : v <= maxStock * 0.5 ? "#FFB800" : "#00C896"),
                    borderRadius: 4
                }]
            },
            options: {
                indexAxis: "y",
                plugins: { legend: { display: false } },
                scales: { x: { ticks: { precision: 0 } } }
            }
        });
    }
})();
</script>';

require_once __DIR__ . '/../layouts/main.php';
