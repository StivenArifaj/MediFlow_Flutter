<?php

// Load .env file
function loadEnv() {
    $envFile = __DIR__ . '/../.env';
    if (file_exists($envFile)) {
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            if (strpos(trim($line), '#') === 0) continue;
            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $_ENV[trim($key)] = trim($value);
                define(trim($key), trim($value));
            }
        }
    }
}
loadEnv();

// Helper functions for MediFlow

// Sanitize input
function sanitize($input) {
    return htmlspecialchars(trim($input), ENT_QUOTES, 'UTF-8');
}

// Format date
function formatDate($timestamp) {
    if (!$timestamp) return '—';
    $date = is_numeric($timestamp) ? date_create_from_format('U', $timestamp) : new DateTime($timestamp);
    return $date ? $date->format('d MMM, YYYY') : '—';
}

// Format time
function formatTime($timestamp) {
    if (!$timestamp) return '—';
    $date = is_numeric($timestamp) ? date_create_from_format('U', $timestamp) : new DateTime($timestamp);
    return $date ? $date->format('H:i') : '—';
}

// Format datetime
function formatDateTime($timestamp) {
    if (!$timestamp) return '—';
    $date = is_numeric($timestamp) ? date_create_from_format('U', $timestamp) : new DateTime($timestamp);
    return $date ? $date->format('d MMM, H:i') : '—';
}

// Convert Firebase timestamp to Unix timestamp
function firebaseTimestampToUnix($firebaseTimestamp) {
    if (isset($firebaseTimestamp['_seconds'])) {
        return $firebaseTimestamp['_seconds'];
    }
    if (isset($firebaseTimestamp['seconds'])) {
        return $firebaseTimestamp['seconds'];
    }
    return null;
}

// Get current timestamp
function now() {
    return time();
}

// Redirect to URL
function redirect($url) {
    header("Location: $url");
    exit;
}

// Check if user is logged in
function isLoggedIn() {
    return isset($_SESSION['user']) && !empty($_SESSION['user']);
}

// Get current user
function getCurrentUser() {
    return $_SESSION['user'] ?? null;
}

// JSON response
function jsonResponse($data, $statusCode = 200) {
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

// Generate invite code (same as Flutter)
function generateInviteCode() {
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $code = '';
    for ($i = 0; $i < 6; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;
}

// Calculate adherence percentage
function calculateAdherence($taken, $total) {
    if ($total == 0) return 0;
    return round(($taken / $total) * 100);
}

// Get status color
function getStatusColor($status) {
    switch ($status) {
        case 'taken':
            return '#00E5FF';
        case 'skipped':
            return '#6B7FCC';
        case 'missed':
            return '#FF3B5C';
        case 'taken_late':
            return '#FFB800';
        default:
            return '#FFB800';
    }
}

// Get status label
function getStatusLabel($status) {
    switch ($status) {
        case 'taken':
            return 'Taken';
        case 'skipped':
            return 'Skipped';
        case 'missed':
            return 'Missed';
        case 'taken_late':
            return 'Taken Late';
        default:
            return ucfirst($status);
    }
}

// Get health metric icon
function getHealthMetricIcon($type) {
    $icons = [
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
        'Respiratory Rate' => 'waves',
    ];
    return $icons[$type] ?? 'analytics';
}

// Format health value
function formatHealthValue($value, $unit) {
    if ($value == floor($value)) {
        return $value . ($unit ? " $unit" : '');
    }
    return number_format($value, 1) . ($unit ? " $unit" : '');
}