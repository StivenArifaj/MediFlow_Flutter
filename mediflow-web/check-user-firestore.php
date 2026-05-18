<?php
session_start();
require_once __DIR__ . '/config/firebase.php';

$firebase = new FirebaseService();

if (isset($_SESSION['firebase_token'])) {
    $firebase->setIdToken($_SESSION['firebase_token']);
    
    // Try to get user's caregiver data
    $uid = $_SESSION['mediflow_user']['uid'] ?? 'test';
    echo "User UID: $uid\n\n";
    
    $url = FIRESTORE_URL . '/caregivers/' . $uid;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $_SESSION['firebase_token'],
        'Content-Type: application/json'
    ]);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "HTTP Code: $httpCode\n";
    echo "Response: $response\n";
} else {
    echo "No user logged in. Please login first at http://localhost:8000\n";
}