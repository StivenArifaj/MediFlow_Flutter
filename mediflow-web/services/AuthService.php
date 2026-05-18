<?php

require_once __DIR__ . '/../config/firebase.php';

class AuthService {
    private $db;
    private $firebaseService;
    private $sessionKey = 'mediflow_user';

    public function __construct($db = null) {
        $this->db = $db;
        $this->firebaseService = new FirebaseService();
    }

    public function login($email, $password) {
        $result = $this->firebaseService->signIn($email, $password);

        if ($result['success']) {
            $user = [
                'uid' => $result['localId'],
                'email' => $result['email'],
                'idToken' => $result['idToken'],
                'refreshToken' => $result['refreshToken'],
                'name' => $this->extractNameFromEmail($email),
                'role' => 'patient',
                'login_time' => time()
            ];

            $_SESSION[$this->sessionKey] = $user;
            $_SESSION['firebase_token'] = $result['idToken'];
            $_SESSION['refresh_token'] = $result['refreshToken'];

            return $user;
        }

        return false;
    }

    public function register($email, $password, $name = null, $role = 'patient') {
        $result = $this->firebaseService->signUp($email, $password);

        if ($result['success']) {
            $user = [
                'uid' => $result['localId'],
                'email' => $result['email'],
                'idToken' => $result['idToken'],
                'refreshToken' => $result['refreshToken'],
                'name' => $name ?? $this->extractNameFromEmail($email),
                'role' => $role,
                'login_time' => time()
            ];

            $_SESSION[$this->sessionKey] = $user;
            $_SESSION['firebase_token'] = $result['idToken'];
            $_SESSION['refresh_token'] = $result['refreshToken'];

            return $user;
        }

        return ['success' => false, 'error' => $result['error'] ?? 'Registration failed'];
    }

    public function logout() {
        session_destroy();
        return true;
    }

    public function getCurrentUser() {
        if (!isset($_SESSION[$this->sessionKey])) {
            return null;
        }

        $user = $_SESSION[$this->sessionKey];

        if (isset($_SESSION['firebase_token'])) {
            $this->firebaseService->setIdToken($_SESSION['firebase_token']);
        }

        return $user;
    }

    public function isLoggedIn() {
        return isset($_SESSION[$this->sessionKey]) && !empty($_SESSION[$this->sessionKey]);
    }

    public function requireLogin() {
        if (!$this->isLoggedIn()) {
            redirect(APP_URL . '/?page=auth');
        }
    }

    public function refreshSession() {
        if (!isset($_SESSION['refresh_token'])) {
            return false;
        }

        $result = $this->firebaseService->refreshToken($_SESSION['refresh_token']);

        if ($result['success']) {
            $_SESSION['firebase_token'] = $result['id_token'];
            $_SESSION['refresh_token'] = $result['refresh_token'];
            $this->firebaseService->setIdToken($result['id_token']);
            return true;
        }

        return false;
    }

    public function getFirebaseService() {
        return $this->firebaseService;
    }

    public function getCaregiverUid() {
        $user = $this->getCurrentUser();
        if (!$user) return null;

        if (isset($user['caregiverUid'])) {
            return $user['caregiverUid'];
        }

        return $user['uid'];
    }

    private function extractNameFromEmail($email) {
        $parts = explode('@', $email);
        return ucfirst($parts[0]);
    }
}