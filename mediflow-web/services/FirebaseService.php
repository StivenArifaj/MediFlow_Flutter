<?php

require_once __DIR__ . '/../config/firebase.php';

class DataService {
    private $firebaseService;
    private $idToken;
    private $caregiverUid;

    public function __construct($firebaseService = null, $caregiverUid = null) {
        $this->firebaseService = $firebaseService ?? new FirebaseService();
        $this->caregiverUid = $caregiverUid;
    }

    public function setIdToken($token) {
        $this->idToken = $token;
        $this->firebaseService->setIdToken($token);
    }

    public function setCaregiverUid($uid) {
        $this->caregiverUid = $uid;
    }

    public function getMedicines() {
        if (!$this->caregiverUid) {
            return $this->getDemoMedicines();
        }

        $medicines = $this->firebaseService->getCaregiverMedicines($this->caregiverUid);

        if (empty($medicines)) {
            return $this->getDemoMedicines();
        }

        return $medicines;
    }

    public function getReminders() {
        if (!$this->caregiverUid) {
            return $this->getDemoReminders();
        }

        $reminders = $this->firebaseService->getCaregiverReminders($this->caregiverUid);

        if (empty($reminders)) {
            return $this->getDemoReminders();
        }

        return $reminders;
    }

    public function getHistory($limit = 100) {
        if (!$this->caregiverUid) {
            return $this->getDemoHistory();
        }

        $history = $this->firebaseService->getCaregiverHistory($this->caregiverUid, $limit);

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

    public function getLinkedPatient() {
        if (!$this->caregiverUid) {
            return null;
        }

        return $this->firebaseService->getLinkedPatient($this->caregiverUid);
    }

    public function getCaregiverProfile() {
        if (!$this->caregiverUid) {
            return null;
        }

        return $this->firebaseService->getCaregiverProfile($this->caregiverUid);
    }

    private function getDemoMedicines() {
        return [
            ['id' => '1', 'verifiedName' => 'Aspirin', 'brandName' => 'Bayer', 'strength' => '100mg', 'form' => 'Tablet', 'apiSource' => 'openFDA', 'quantity' => 30, 'isActive' => true],
            ['id' => '2', 'verifiedName' => 'Metformin', 'brandName' => 'Glucophage', 'strength' => '500mg', 'form' => 'Tablet', 'apiSource' => 'manual', 'quantity' => 45, 'isActive' => true],
            ['id' => '3', 'verifiedName' => 'Lisinopril', 'brandName' => 'Zestril', 'strength' => '10mg', 'form' => 'Tablet', 'apiSource' => 'manual', 'quantity' => 20, 'isActive' => true],
            ['id' => '4', 'verifiedName' => 'Atorvastatin', 'brandName' => 'Lipitor', 'strength' => '20mg', 'form' => 'Tablet', 'apiSource' => 'openFDA', 'quantity' => 15, 'isActive' => true],
            ['id' => '5', 'verifiedName' => 'Omeprazole', 'brandName' => 'Prilosec', 'strength' => '20mg', 'form' => 'Capsule', 'apiSource' => 'manual', 'quantity' => 25, 'isActive' => true]
        ];
    }

    private function getDemoReminders() {
        return [
            ['id' => '1', 'medicineId' => '1', 'time' => '08:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '2', 'medicineId' => '2', 'time' => '08:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '3', 'medicineId' => '2', 'time' => '20:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '4', 'medicineId' => '3', 'time' => '09:00', 'frequency' => 'daily', 'isActive' => true],
            ['id' => '5', 'medicineId' => '4', 'time' => '22:00', 'frequency' => 'daily', 'isActive' => true]
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
            ['id' => '5', 'medicineId' => '4', 'medicineName' => 'Atorvastatin', 'status' => 'missed', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($today . ' 22:00'))],
            ['id' => '6', 'medicineId' => '1', 'medicineName' => 'Aspirin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($yesterday . ' 08:00'))],
            ['id' => '7', 'medicineId' => '2', 'medicineName' => 'Metformin', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($yesterday . ' 08:30'))],
            ['id' => '8', 'medicineId' => '3', 'medicineName' => 'Lisinopril', 'status' => 'taken', 'timestamp' => date('Y-m-d\TH:i:s', strtotime($yesterday . ' 09:00'))]
        ];
    }
}