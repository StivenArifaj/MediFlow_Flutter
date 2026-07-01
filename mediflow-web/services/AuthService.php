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
            $uid = $result['localId'];
            $idToken = $result['idToken'];

            // Set token so authenticated Firestore requests work
            $this->firebaseService->setIdToken($idToken);

            // Fetch user profile from Firestore to get name and role
            $userProfile = $this->firebaseService->getDocument('users', $uid);
            $userRole = $userProfile['role'] ?? 'patient';
            $userName = $userProfile['name'] ?? $this->extractNameFromEmail($email);

            $user = [
                'uid'          => $uid,
                'email'        => $result['email'],
                'idToken'      => $idToken,
                'refreshToken' => $result['refreshToken'],
                'name'         => $userName,
                'role'         => $userRole,
                'login_time'   => time(),
            ];

            $_SESSION[$this->sessionKey]  = $user;
            $_SESSION['firebase_token']   = $idToken;
            $_SESSION['refresh_token']    = $result['refreshToken'];

            return $user;
        }

        return false;
    }

    public function register($email, $password, $name = null, $role = 'patient') {
        $result = $this->firebaseService->signUp($email, $password);

        if (isset($result['success']) && $result['success']) {
            $user = [
                'uid'          => $result['localId'],
                'email'        => $result['email'],
                'idToken'      => $result['idToken'],
                'refreshToken' => $result['refreshToken'],
                'name'         => $name ?? $this->extractNameFromEmail($email),
                'role'         => $role,
                'login_time'   => time(),
            ];

            $_SESSION[$this->sessionKey] = $user;
            $_SESSION['firebase_token']  = $result['idToken'];
            $_SESSION['refresh_token']   = $result['refreshToken'];

            return ['success' => true, 'user' => $user];
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

    // Refresh the Firebase idToken using the stored refresh token.
    // Call this at the top of any page that reads from Firestore.
    public function refreshTokenIfNeeded() {
        if (!isset($_SESSION['firebase_token']) || !isset($_SESSION['refresh_token'])) {
            return false;
        }

        $loginTime = $_SESSION[$this->sessionKey]['login_time'] ?? 0;
        $tokenAge  = time() - $loginTime;

        // Refresh if token is older than 55 minutes (expires at 60)
        if ($tokenAge < 3300) {
            return true;
        }

        return $this->refreshSession();
    }

    public function refreshSession() {
        if (!isset($_SESSION['refresh_token'])) {
            return false;
        }

        $result = $this->firebaseService->refreshToken($_SESSION['refresh_token']);

        if ($result['success']) {
            $_SESSION['firebase_token'] = $result['id_token'];
            $_SESSION['refresh_token']  = $result['refresh_token'];
            // Update login_time so we don't refresh every request
            $_SESSION[$this->sessionKey]['login_time'] = time();
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
