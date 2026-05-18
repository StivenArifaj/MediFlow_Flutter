<?php
require_once __DIR__ . '/config/firebase.php';

$firebase = new FirebaseService();

// Get all caregivers
$url = FIRESTORE_URL . '/caregivers';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);
echo "Firestore caregivers count: " . (isset($data['documents']) ? count($data['documents']) : 0) . "\n";

if (isset($data['documents'])) {
    foreach ($data['documents'] as $doc) {
        echo "Document: " . $doc['name'] . "\n";
    }
} else {
    echo "No data in caregivers collection\n";
    echo "Response: " . substr($response, 0, 500) . "\n";
}