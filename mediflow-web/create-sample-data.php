<?php
session_start();
require_once __DIR__ . '/config/firebase.php';

$firebase = new FirebaseService();

if (!isset($_SESSION['firebase_token'])) {
    die("Please login first at http://localhost:8000");
}

$firebase->setIdToken($_SESSION['firebase_token']);
$uid = $_SESSION['mediflow_user']['uid'] ?? null;

if (!$uid) {
    die("No user UID found");
}

echo "Creating sample data for user: $uid\n\n";

// Create caregiver profile
$profileData = [
    'fields' => [
        'profile' => ['mapValue' => ['fields' => [
            'name' => ['stringValue' => $_SESSION['mediflow_user']['name'] ?? 'Test User'],
            'email' => ['stringValue' => $_SESSION['mediflow_user']['email']],
            'role' => ['stringValue' => 'caregiver']
        ]]],
        'inviteCode' => ['stringValue' => 'TEST01'],
        'patientName' => ['stringValue' => 'Test Patient']
    ]
];

$url = FIRESTORE_URL . '/caregivers/' . $uid;
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($profileData));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Authorization: Bearer ' . $_SESSION['firebase_token'],
    'Content-Type: application/json'
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Profile creation: HTTP $httpCode\n";

// Add sample medicines
$medicines = [
    ['id' => 'med1', 'verifiedName' => 'Aspirin', 'brandName' => 'Bayer', 'strength' => '100mg', 'form' => 'Tablet'],
    ['id' => 'med2', 'verifiedName' => 'Metformin', 'brandName' => 'Glucophage', 'strength' => '500mg', 'form' => 'Tablet'],
    ['id' => 'med3', 'verifiedName' => 'Lisinopril', 'brandName' => 'Zestril', 'strength' => '10mg', 'form' => 'Tablet'],
];

foreach ($medicines as $med) {
    $url = FIRESTORE_URL . '/caregivers/' . $uid . '/medicines/' . $med['id'];
    $data = ['fields' => [
        'verifiedName' => ['stringValue' => $med['verifiedName']],
        'brandName' => ['stringValue' => $med['brandName']],
        'strength' => ['stringValue' => $med['strength']],
        'form' => ['stringValue' => $med['form']],
        'quantity' => ['integerValue' => 30],
        'isActive' => ['booleanValue' => true]
    ]];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $_SESSION['firebase_token'],
        'Content-Type: application/json'
    ]);
    $resp = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "Medicine " . $med['verifiedName'] . ": HTTP $code\n";
}

// Add sample history
$historyEntries = [
    ['status' => 'taken', 'medicineName' => 'Aspirin', 'timestamp' => time()],
    ['status' => 'taken', 'medicineName' => 'Metformin', 'timestamp' => time() - 3600],
    ['status' => 'skipped', 'medicineName' => 'Lisinopril', 'timestamp' => time() - 7200],
];

foreach ($historyEntries as $i => $entry) {
    $url = FIRESTORE_URL . '/caregivers/' . $uid . '/history/hist' . $i;
    $data = ['fields' => [
        'status' => ['stringValue' => $entry['status']],
        'medicineName' => ['stringValue' => $entry['medicineName']],
        'medicineId' => ['stringValue' => 'med' . ($i + 1)],
        'timestamp' => ['timestampValue' => date('c', $entry['timestamp'])]
    ]];
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $_SESSION['firebase_token'],
        'Content-Type: application/json'
    ]);
    $resp = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    echo "History " . $entry['medicineName'] . ": HTTP $code\n";
}

echo "\n✅ Sample data created! Refresh your dashboard to see real data.\n";