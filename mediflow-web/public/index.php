<?php

session_start();

require_once __DIR__ . '/../config/firebase.php';
require_once __DIR__ . '/../config/functions.php';
require_once __DIR__ . '/../services/AuthService.php';
require_once __DIR__ . '/../services/FirebaseService.php';

$authService = new AuthService();
$dataService = new DataService();

$page   = $_GET['page']   ?? 'dashboard';
$action = $_GET['action'] ?? 'index';

// Refresh the Firebase token before doing any Firestore reads.
// Tokens expire after 1 hour; this refreshes automatically after 55 minutes.
if ($authService->isLoggedIn()) {
    $authService->refreshTokenIfNeeded();
    $user    = $authService->getCurrentUser();
    $dataService->setIdToken($_SESSION['firebase_token'] ?? null);
    $userUid  = $user['uid']   ?? null;
    $userRole = $user['role']  ?? 'patient';
    $dataService->setUser($userUid, $userRole);
}

switch ($page) {
    case 'auth':
        session_unset();
        if ($authService->isLoggedIn()) {
            redirect(APP_URL . '/?page=dashboard');
        }
        require_once __DIR__ . '/../views/auth/login.php';
        break;

    case 'login':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $email    = sanitize($_POST['email']    ?? '');
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
            $name     = sanitize($_POST['name']     ?? '');
            $email    = sanitize($_POST['email']    ?? '');
            $password = $_POST['password'] ?? '';

            if (empty($name) || empty($email) || empty($password)) {
                $error = 'Please fill in all fields';
                require_once __DIR__ . '/../views/auth/login.php';
            } else {
                $result = $authService->register($email, $password, $name, 'patient');
                if (isset($result['success']) && $result['success']) {
                    redirect(APP_URL . '/?page=dashboard');
                } else {
                    $error = $result['error'] ?? 'Registration failed';
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

    case 'debug':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        $uid  = $user['uid']  ?? null;
        $role = $user['role'] ?? 'patient';

        $dataService->setUser($uid, $role);

        $collection   = ($role === 'caregiver') ? 'caregivers' : 'patients';
        $firestoreUrl = FIRESTORE_URL;
        $token        = $_SESSION['firebase_token'] ?? null;
        $tokenAge     = $token ? (time() - ($user['login_time'] ?? 0)) : null;

        // Direct Firestore call with verbose logging
        $ch = curl_init();
        $testUrl = $firestoreUrl . '/' . $collection . '/' . $uid . '/medicines?pageSize=5';
        curl_setopt($ch, CURLOPT_URL, $testUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $token,
        ]);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        $rawResponse  = curl_exec($ch);
        $httpCode     = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError    = curl_error($ch);
        curl_close($ch);

        header('Content-Type: text/plain; charset=utf-8');
        echo "=== MediFlow Firestore Diagnostic ===\n\n";
        echo "Session UID   : " . ($uid  ?? '(null)') . "\n";
        echo "Session Role  : " . ($role ?? '(null)') . "\n";
        echo "Collection    : $collection\n";
        echo "Token present : " . ($token ? 'YES' : 'NO') . "\n";
        echo "Token age     : " . ($tokenAge !== null ? $tokenAge . 's' : 'unknown') . "\n";
        echo "\nFirestore URL being hit:\n$testUrl\n";
        echo "\nHTTP Response : $httpCode\n";
        if ($curlError) echo "cURL error    : $curlError\n";
        echo "\nFirestore raw response:\n" . json_encode(json_decode($rawResponse, true), JSON_PRETTY_PRINT) . "\n";
        echo "\n--- Also checking users/{uid} ---\n";
        $ch2 = curl_init();
        $usersUrl = $firestoreUrl . '/users/' . $uid;
        curl_setopt($ch2, CURLOPT_URL, $usersUrl);
        curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch2, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Authorization: Bearer ' . $token]);
        curl_setopt($ch2, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch2, CURLOPT_TIMEOUT, 15);
        $usersRaw  = curl_exec($ch2);
        $usersCode = curl_getinfo($ch2, CURLINFO_HTTP_CODE);
        curl_close($ch2);
        echo "users/$uid HTTP: $usersCode\n";
        echo json_encode(json_decode($usersRaw, true), JSON_PRETTY_PRINT) . "\n";
        exit;
        break;

    case 'dashboard':
        $authService->requireLogin();
        $user     = $authService->getCurrentUser();
        $userUid  = $user['uid']  ?? null;
        $userRole = $user['role'] ?? 'patient';

        $dataService->setUser($userUid, $userRole);

        // Try to get a fresher display name from Firestore
        if ($userUid) {
            $userProfile = $dataService->getUserProfileByUid($userUid, $userRole);
            if ($userProfile && !empty($userProfile['name'])) {
                $user['name'] = $userProfile['name'];
            }
        }

        $stats        = $dataService->getStats();
        $todayHistory = $dataService->getTodayHistory();
        $medicines    = $dataService->getMedicines();

        require_once __DIR__ . '/../views/dashboard/index.php';
        break;

    case 'medicines':
        $authService->requireLogin();
        $user    = $authService->getCurrentUser();
        $dataService->setUser($user['uid'] ?? null, $user['role'] ?? 'patient');

        $userProfile = $dataService->getUserProfile();
        if ($userProfile && isset($userProfile['name'])) {
            $user['name'] = $userProfile['name'];
        }

        $medicines = $dataService->getMedicines();
        require_once __DIR__ . '/../views/medicines/index.php';
        break;

    case 'history':
        $authService->requireLogin();
        $user    = $authService->getCurrentUser();
        $dataService->setUser($user['uid'] ?? null, $user['role'] ?? 'patient');

        $userProfile = $dataService->getUserProfile();
        if ($userProfile && isset($userProfile['name'])) {
            $user['name'] = $userProfile['name'];
        }

        $history = $dataService->getHistory(200);
        require_once __DIR__ . '/../views/history/index.php';
        break;

    case 'health':
        $authService->requireLogin();
        $user = $authService->getCurrentUser();
        $dataService->setUser($user['uid'] ?? null, $user['role'] ?? 'patient');
        require_once __DIR__ . '/../views/health/index.php';
        break;

    case 'charts':
        $authService->requireLogin();
        $user     = $authService->getCurrentUser();
        $dataService->setUser($user['uid'] ?? null, $user['role'] ?? 'patient');
        $medicines = $dataService->getMedicines();
        $history   = $dataService->getHistory(1000);
        $stats     = $dataService->getStats();
        require_once __DIR__ . '/../views/charts/index.php';
        break;

    case 'api':
        header('Content-Type: application/json');
        $authService->requireLogin();

        $dataService->setIdToken($_SESSION['firebase_token'] ?? null);
        $dataService->setUser($user['uid'] ?? null, $user['role'] ?? 'patient');

        switch ($_GET['api_action'] ?? '') {
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
