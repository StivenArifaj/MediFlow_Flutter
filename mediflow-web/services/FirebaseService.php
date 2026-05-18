<?php

require_once __DIR__ . '/../config/firebase.php';

class DataService {
    private $firebaseService;
    private $idToken;
    private $userUid;
    private $userRole;

    public function __construct($firebaseService = null, $userUid = null, $userRole = 'patient') {
        $this->firebaseService = $firebaseService ?? new FirebaseService();
        $this->userUid = $userUid;
        $this->userRole = $userRole;
    }

    public function setIdToken($token) {
        $this->idToken = $token;
        $this->firebaseService->setIdToken($token);
    }

    public function setUser($uid, $role) {
        $this->userUid = $uid;
        $this->userRole = $role;
    }

    private function getCollectionPrefix() {
        if ($this->userRole == 'caregiver') {
            return 'caregivers';
        }
        return 'patients';
    }

    public function getMedicines() {
        if (!$this->userUid) {
            return $this->getDemoMedicines();
        }

        $collection = $this->getCollectionPrefix();
        $medicines = $this->firebaseService->getCollectionDocuments($collection, $this->userUid, 'medicines');

        if (empty($medicines)) {
            return $this->getDemoMedicines();
        }

        return $medicines;
    }

    public function getReminders() {
        if (!$this->userUid) {
            return $this->getDemoReminders();
        }

        $collection = $this->getCollectionPrefix();
        $reminders = $this->firebaseService->getCollectionDocuments($collection, $this->userUid, 'reminders');

        if (empty($reminders)) {
            return $this->getDemoReminders();
        }

        return $reminders;
    }

    public function getHistory($limit = 100) {
        if (!$this->userUid) {
            return $this->getDemoHistory();
        }

        $collection = $this->getCollectionPrefix();
        $history = $this->firebaseService->getCollectionDocuments($collection, $this->userUid, 'history', $limit);

        if (empty($history)) {
            return $this->getDemoHistory();
        }

        return $history;
    }

    public function getTodayHistory() {
        $history = $this->getHistory();
        $today = date('Y-m-d');

        return array_filter($history, function($item) use ($today) {
            if (isset($item['timestamp'])) {
                $itemDate = date('Y-m-d', strtotime($item['timestamp']));
                return $itemDate === $today;
            }
            return false;
        });
    }

    public function getStats() {
        $history = $this->getHistory();

        $taken = count(array_filter($history, function($h) {
            return ($h['status'] ?? '') === 'taken';
        }));
        $skipped = count(array_filter($history, function($h) {
            return ($h['status'] ?? '') === 'skipped';
        }));
        $missed = count(array_filter($history, function($h) {
            return ($h['status'] ?? '') === 'missed';
        }));
        $total = count($history);
        $adherence = $total > 0 ? round(($taken / $total) * 100) : 0;

        return [
            'taken' => $taken,
            'skipped' => $skipped,
            'missed' => $missed,
            'total' => $total,
            'adherence' => $adherence
        ];
    }

    public function getUserProfile() {
        if (!$this->userUid) {
            return null;
        }

        $collection = $this->getCollectionPrefix();
        return $this->firebaseService->getDocument($collection, $this->userUid);
    }

    private function getDemoMedicines() {
        return [
            ['id' => '1', 'verifiedName' => 'Aspirin', 'brandName' => 'Bayer', 'strength' => '100mg', 'form' => 'Tablet', 'apiSource' => 'openFDA', 'quantity' => 30, 'isActive' => true],
            ['id' => '2', 'verifiedName' => 'Metformin', 'brandName' => 'Glucophage', 'strength' => '500mg', 'form' => 'Tablet', 'apiSource' => 'manual', 'quantity' => 45, 'isActive' => true],
            ['id' => '3', 'verifiedName' => 'Lisinopril', 'brandName' => 'Zestril', 'strength' => '10mg', 'form' => 'Tablet', 'apiSource' => 'manual', 'quantity' => 20, 'isActive' => true],
        ];
    }

    private function getDemoReminders() {
        return [
            ['id' => '1', 'medicineId' => '1', 'time' => '08:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '2', 'medicineId' => '2', 'time' => '08:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '3', 'medicineId' => '2', 'time' => '20:00', 'frequency' => 'daily', 'isActive' => true],
        ];
    }

    private function getDemoHistory() {
        $today = date('Y-m-d');
        $yesterday = date('Y-m-d', strtotime('-1 day'));

        return [
            ['id' => '1', 'medicineId' => '1', 'medicineName' => 'Aspirin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($today . ' 08:00'))],
            ['id' => '2', 'medicineId' => '2', 'medicineName' => 'Metformin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($today . ' 08:30'))],
            ['id' => '3', 'medicineId' => '2', 'medicineName' => 'Metformin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($today . ' 20:00'))],
            ['id' => '4', 'medicineId' => '3', 'medicineName' => 'Lisinopril', 'status' => 'skipped', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($today . ' 09:00'))],
            ['id' => '5', 'medicineId' => '1', 'medicineName' => 'Aspirin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($yesterday . ' 08:00'))],
            ['id' => '6', 'medicineId' => '2', 'medicineName' => 'Metformin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($yesterday . ' 08:30'))],
        ];
    }
}