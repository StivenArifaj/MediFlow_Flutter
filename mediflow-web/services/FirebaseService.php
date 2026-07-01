<?php

require_once __DIR__ . '/../config/firebase.php';

class DataService {
    private $firebaseService;
    private $idToken;
    private $userUid;
    private $userRole;

    public function __construct($firebaseService = null, $userUid = null, $userRole = 'patient') {
        $this->firebaseService = $firebaseService ?? new FirebaseService();
        $this->userUid         = $userUid;
        $this->userRole        = $userRole;
    }

    public function setIdToken($token) {
        $this->idToken = $token;
        $this->firebaseService->setIdToken($token);
    }

    public function setUser($uid, $role) {
        $this->userUid  = $uid;
        $this->userRole = $role;
    }

    public function setCaregiverUid($uid) {
        $this->userUid = $uid;
    }

    private function collectionForRole() {
        return ($this->userRole === 'caregiver') ? 'caregivers' : 'patients';
    }

    // ── Data accessors ────────────────────────────────────────────────────────

    public function getMedicines() {
        if (!$this->userUid) return [];
        return $this->firebaseService->getCollectionDocuments(
            $this->collectionForRole(), $this->userUid, 'medicines'
        ) ?? [];
    }

    public function getReminders() {
        if (!$this->userUid) return [];
        return $this->firebaseService->getCollectionDocuments(
            $this->collectionForRole(), $this->userUid, 'reminders'
        ) ?? [];
    }

    public function getHistory($limit = 100) {
        if (!$this->userUid) return [];
        return $this->firebaseService->getCollectionDocuments(
            $this->collectionForRole(), $this->userUid, 'history', $limit
        ) ?? [];
    }

    public function getTodayHistory() {
        $today = date('Y-m-d');
        return array_values(array_filter($this->getHistory(), function ($item) use ($today) {
            if (isset($item['timestamp'])) {
                // Handle both string timestamps and Firestore timestamp objects
                $ts = is_string($item['timestamp'])
                    ? $item['timestamp']
                    : ($item['timestamp']['_seconds'] ?? null);
                if ($ts) {
                    return date('Y-m-d', is_numeric($ts) ? (int)$ts : strtotime($ts)) === $today;
                }
            }
            return false;
        }));
    }

    public function getStats() {
        $history  = $this->getHistory();
        $taken    = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'taken'));
        $skipped  = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'skipped'));
        $missed   = count(array_filter($history, fn($h) => ($h['status'] ?? '') === 'missed'));
        $total    = count($history);
        $adherence = $total > 0 ? round(($taken / $total) * 100) : 0;

        return compact('taken', 'skipped', 'missed', 'total', 'adherence');
    }

    public function getUserProfile() {
        if (!$this->userUid) return null;
        return $this->firebaseService->getDocument($this->collectionForRole(), $this->userUid);
    }

    public function getUserProfileByUid($uid, $role = 'patient') {
        if (!$uid) return null;
        $collection = ($role === 'caregiver') ? 'caregivers' : 'patients';
        return $this->firebaseService->getDocument($collection, $uid);
    }

    public function getLinkedPatient() {
        return null; // Implement if needed
    }
}
