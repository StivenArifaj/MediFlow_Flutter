<?php

// MediFlow Web Dashboard - Entry Point

// Start session
session_start();

// Load configuration and functions
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/functions.php';
require_once __DIR__ . '/../services/AuthService.php';
require_once __DIR__ . '/../services/FirebaseService.php';

// Initialize services
$authService = new AuthService();
$firebaseService = new FirebaseService();

// Get current page
$page = $_GET['page'] ?? 'dashboard';
$action = $_GET['action'] ?? 'index';

// Route handling
switch ($page) {
    case 'auth':
        require_once __DIR__ . '/../views/auth/login.php';
        break;
    
    case 'logout':
        $authService->logout();
        redirect(APP_URL . '/views/auth/login.php');
        break;
    
    case 'dashboard':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        require_once __DIR__ . '/../views/dashboard/index.php';
        break;
    
    case 'medicines':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        require_once __DIR__ . '/../views/medicines/index.php';
        break;
    
    case 'history':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        require_once __DIR__ . '/../views/history/index.php';
        break;
    
    case 'health':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        require_once __DIR__ . '/../views/health/index.php';
        break;
    
    case 'api':
        // API endpoints
        header('Content-Type: application/json');
        
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        
        // Get Firebase token from session if available
        $idToken = $_SESSION['id_token'] ?? null;
        $firebaseService->setIdToken($idToken);
        
        $apiAction = $_GET['api_action'] ?? '';
        
        switch ($apiAction) {
            case 'medicines':
                $medicines = $firebaseService->getCaregiverMedicines($user['firebase_uid'] ?? 'demo-caregiver-uid');
                jsonResponse(['success' => true, 'data' => $medicines]);
                break;
            
            case 'reminders':
                $reminders = $firebaseService->getCaregiverReminders($user['firebase_uid'] ?? 'demo-caregiver-uid');
                jsonResponse(['success' => true, 'data' => $reminders]);
                break;
            
            case 'history':
                $history = $firebaseService->getCaregiverHistory($user['firebase_uid'] ?? 'demo-caregiver-uid');
                jsonResponse(['success' => true, 'data' => $history]);
                break;
            
            case 'today_history':
                $history = $firebaseService->getCaregiverTodayHistory($user['firebase_uid'] ?? 'demo-caregiver-uid');
                jsonResponse(['success' => true, 'data' => $history]);
                break;
            
            case 'stats':
                $history = $firebaseService->getCaregiverHistory($user['firebase_uid'] ?? 'demo-caregiver-uid');
                $taken = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'taken'));
                $skipped = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'skipped'));
                $missed = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'missed'));
                $total = count($history);
                $adherence = $total > 0 ? round(($taken / $total) * 100) : 0;
                jsonResponse([
                    'success' => true,
                    'data' => [
                        'taken' => $taken,
                        'skipped' => $skipped,
                        'missed' => $missed,
                        'total' => $total,
                        'adherence' => $adherence
                    ]
                ]);
                break;
            
            case 'linked_patient':
                $patient = $firebaseService->getLinkedPatientForCaregiver($user['firebase_uid'] ?? 'demo-caregiver-uid');
                jsonResponse(['success' => true, 'data' => $patient]);
                break;
            
            default:
                jsonResponse(['success' => false, 'message' => 'Unknown API action'], 404);
        }
        break;
    
    default:
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        require_once __DIR__ . '/../views/dashboard/index.php';
        break;
}