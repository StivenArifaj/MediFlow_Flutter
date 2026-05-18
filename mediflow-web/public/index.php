<?php

session_start();

require_once __DIR__ . '/../config/firebase.php';
require_once __DIR__ . '/../config/functions.php';
require_once __DIR__ . '/../services/AuthService.php';
require_once __DIR__ . '/../services/FirebaseService.php';

$authService = new AuthService();
$dataService = new DataService();

$page = $_GET['page'] ?? 'dashboard';
$action = $_GET['action'] ?? 'index';

if ($authService->isLoggedIn()) {
    $user = $authService->getCurrentUser();
    $dataService->setIdToken($_SESSION['firebase_token'] ?? null);
    $userUid = $user['uid'] ?? $user['firebase_uid'] ?? null;
    $userRole = $user['role'] ?? 'patient';
    $dataService->setUser($userUid, $userRole);
}

switch ($page) {
    case 'auth':
        if ($authService->isLoggedIn()) {
            redirect(APP_URL . '/?page=dashboard');
        }
        require_once __DIR__ . '/../views/auth/login.php';
        break;

    case 'login':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $email = sanitize($_POST['email'] ?? '');
            $password = $_POST['password'] ?? '';

            if (empty($email) || empty($password)) {
                $error = 'Please enter both email and password';
                require_once __DIR__ . '/../views/auth/login.php';
            } else {
                $result = $authService->login($email, $password);

                if ($result) {
                    redirect(APP_URL . '/?page=dashboard');
                } else {
                    $error = 'Invalid email or password';
                    require_once __DIR__ . '/../views/auth/login.php';
                }
            }
        } else {
            redirect(APP_URL . '/?page=auth');
        }
        break;

    case 'register':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $name = sanitize($_POST['name'] ?? '');
            $email = sanitize($_POST['email'] ?? '');
            $password = $_POST['password'] ?? '';

            if (empty($name) || empty($email) || empty($password)) {
                $error = 'Please fill in all fields';
                require_once __DIR__ . '/../views/auth/login.php';
            } else {
                $result = $authService->register($email, $password, $name, 'patient');
                
                error_log("Registration result: " . json_encode($result));

                if (isset($result['success']) && $result['success']) {
                    redirect(APP_URL . '/?page=dashboard');
                } else {
                    $error = $result['error'] ?? 'Registration failed';
                    if (isset($result['raw_response'])) {
                        error_log("Raw response: " . json_encode($result['raw_response']));
                    }
                    require_once __DIR__ . '/../views/auth/login.php';
                }
            }
        } else {
            redirect(APP_URL . '/?page=auth');
        }
        break;

    case 'logout':
        $authService->logout();
        redirect(APP_URL . '/?page=auth');
        break;

    case 'dashboard':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();

        $stats = $dataService->getStats();
        $todayHistory = $dataService->getTodayHistory();
        $medicines = $dataService->getMedicines();

        require_once __DIR__ . '/../views/dashboard/index.php';
        break;

    case 'medicines':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        $medicines = $dataService->getMedicines();

        require_once __DIR__ . '/../views/medicines/index.php';
        break;

    case 'history':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        $history = $dataService->getHistory(200);

        require_once __DIR__ . '/../views/history/index.php';
        break;

    case 'health':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();

        require_once __DIR__ . '/../views/health/index.php';
        break;

    case 'api':
        header('Content-Type: application/json');
        $authService->requireLogin();

        $idToken = $_SESSION['firebase_token'] ?? null;
        $dataService->setIdToken($idToken);
        $dataService->setCaregiverUid($user['uid'] ?? null);

        $apiAction = $_GET['api_action'] ?? '';

        switch ($apiAction) {
            case 'medicines':
                jsonResponse(['success' => true, 'data' => $dataService->getMedicines()]);
                break;

            case 'reminders':
                jsonResponse(['success' => true, 'data' => $dataService->getReminders()]);
                break;

            case 'history':
                jsonResponse(['success' => true, 'data' => $dataService->getHistory()]);
                break;

            case 'today_history':
                jsonResponse(['success' => true, 'data' => $dataService->getTodayHistory()]);
                break;

            case 'stats':
                jsonResponse(['success' => true, 'data' => $dataService->getStats()]);
                break;

            case 'linked_patient':
                jsonResponse(['success' => true, 'data' => $dataService->getLinkedPatient()]);
                break;

            default:
                jsonResponse(['success' => false, 'message' => 'Unknown API action'], 404);
        }
        break;

    default:
        if ($authService->isLoggedIn()) {
            redirect(APP_URL . '/?page=dashboard');
        } else {
            redirect(APP_URL . '/?page=auth');
        }
        break;
}