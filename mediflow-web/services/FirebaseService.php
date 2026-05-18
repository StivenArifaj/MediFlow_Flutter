<?php

require_once __DIR__ . '/../config/database.php';

class FirebaseService {
    private $idToken;
    private $projectId;
    private $apiKey;

    public function __construct() {
        $this->projectId = getenv('FIREBASE_PROJECT_ID') ?: 'mediflow-xxxxx';
        $this->apiKey = getenv('FIREBASE_API_KEY') ?: 'YOUR_API_KEY_HERE';
    }

    public function setIdToken($token) {
        $this->idToken = $token;
    }

    public function getCaregiverMedicines($caregiverUid) {
        return $this->getDemoData('medicines');
    }

    public function getCaregiverReminders($caregiverUid) {
        return $this->getDemoData('reminders');
    }

    public function getCaregiverHistory($caregiverUid) {
        return $this->getDemoData('history');
    }

    public function getCaregiverTodayHistory($caregiverUid) {
        return array_filter($this->getDemoData('history'), function($item) {
            return isset($item['date']) && strpos($item['date'], date('Y-m-d')) === 0;
        });
    }

    public function getLinkedPatientForCaregiver($caregiverUid) {
        return [
            'id' => 'patient-001',
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'age' => 45,
            'condition' => 'Diabetes'
        ];
    }

    private function getDemoData($type) {
        $data = [
            'medicines' => [
                ['id' => 1, 'name' => 'Aspirin', 'dosage' => '100mg', 'frequency' => 'Once daily', 'stock' => 30],
                ['id' => 2, 'name' => 'Metformin', 'dosage' => '500mg', 'frequency' => 'Twice daily', 'stock' => 45],
                ['id' => 3, 'name' => 'Lisinopril', 'dosage' => '10mg', 'frequency' => 'Once daily', 'stock' => 20],
            ],
            'reminders' => [
                ['id' => 1, 'medicine_id' => 1, 'time' => '08:00', 'enabled' => true],
                ['id' => 2, 'medicine_id' => 2, 'time' => '08:00', 'enabled' => true],
                ['id' => 3, 'medicine_id' => 2, 'time' => '20:00', 'enabled' => true],
                ['id' => 4, 'medicine_id' => 3, 'time' => '09:00', 'enabled' => true],
            ],
            'history' => [
                ['id' => 1, 'medicine' => 'Aspirin', 'time' => '08:00', 'status' => 'taken', 'date' => date('Y-m-d')],
                ['id' => 2, 'medicine' => 'Metformin', 'time' => '08:00', 'status' => 'taken', 'date' => date('Y-m-d')],
                ['id' => 3, 'medicine' => 'Metformin', 'time' => '20:00', 'status' => 'pending', 'date' => date('Y-m-d')],
                ['id' => 4, 'medicine' => 'Lisinopril', 'time' => '09:00', 'status' => 'taken', 'date' => date('Y-m-d')],
                ['id' => 5, 'medicine' => 'Aspirin', 'time' => '08:00', 'status' => 'taken', 'date' => date('Y-m-d', strtotime('-1 day'))],
                ['id' => 6, 'medicine' => 'Metformin', 'time' => '08:00', 'status' => 'taken', 'date' => date('Y-m-d', strtotime('-1 day'))],
            ]
        ];

        return $data[$type] ?? [];
    }
}