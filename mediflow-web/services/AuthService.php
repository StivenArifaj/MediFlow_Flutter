<?php

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/FirebaseService.php';

class AuthService {
    private $db;
    private $firebaseService;

    public function __construct($db = null) {
        $this->db = $db;
        $this->firebaseService = new FirebaseService();
    }

    // Since Flutter uses SQLite with SHA-256 hashed passwords,
    // we'll simulate login by accepting the same credentials
    // In production, you'd have a MySQL database synced with the Flutter data
    
    public function login($email, $password) {
        // Hash password the same way as Flutter app
        $passwordHash = $this->hashPassword($password);
        
        // For demo purposes, create a demo user session
        // In production, this would check against a database
        $user = $this->verifyCredentials($email, $passwordHash);
        
        if ($user) {
            $_SESSION['user'] = $user;
            $_SESSION['id_token'] = $user['firebase_token'] ?? null;
            $_SESSION['login_time'] = time();
            
            // Set up Firebase service with token
            if (isset($user['firebase_uid']) && $user['firebase_uid']) {
                $this->firebaseService->setIdToken($user['firebase_token'] ?? null);
            }
            
            return $user;
        }
        
        return false;
    }

    public function logout() {
        session_destroy();
        return true;
    }

    public function getCurrentUser() {
        if (!isset($_SESSION['user'])) {
            return null;
        }
        return $_SESSION['user'];
    }

    public function isLoggedIn() {
        return isset($_SESSION['user']) && !empty($_SESSION['user']);
    }

    public function requireLogin() {
        if (!$this->isLoggedIn()) {
            redirect(APP_URL . '/views/auth/login.php');
        }
    }

    // SHA-256 hash (same as Flutter app)
    private function hashPassword($password) {
        return hash('sha256', $password);
    }

    // Demo user database - in production, use MySQL
    private function getDemoUsers() {
        return [
            [
                'id' => 1,
                'email' => 'demo@mediflow.app',
                'password_hash' => $this->hashPassword('demo123'),
                'name' => 'Demo User',
                'role' => 'patient',
                'firebase_uid' => 'demo-caregiver-uid',
                'firebase_token' => null,
            ],
            [
                'id' => 2,
                'email' => 'caregiver@mediflow.app',
                'password_hash' => $this->hashPassword('caregiver123'),
                'name' => 'Dr. Smith',
                'role' => 'caregiver',
                'firebase_uid' => 'demo-caregiver-uid',
                'firebase_token' => null,
            ],
        ];
    }

    private function verifyCredentials($email, $passwordHash) {
        $users = $this->getDemoUsers();
        
        foreach ($users as $user) {
            if ($user['email'] === $email && $user['password_hash'] === $passwordHash) {
                return $user;
            }
        }
        
        return null;
    }

    public function register($name, $email, $password, $role = 'patient') {
        $passwordHash = $this->hashPassword($password);
        
        // In production, save to database
        // For demo, just return the user
        $user = [
            'id' => time(),
            'email' => $email,
            'name' => $name,
            'role' => $role,
            'firebase_uid' => null,
            'firebase_token' => null,
        ];
        
        $_SESSION['user'] = $user;
        return $user;
    }

    public function getFirebaseService() {
        return $this->firebaseService;
    }
}