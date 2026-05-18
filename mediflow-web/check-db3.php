<?php
// Try with database ID "mediflow" instead of "(default)"
$projectId = 'mediflow-1b572';
$dbId = 'mediflow'; // or whatever you named it

$url = "https://firestore.googleapis.com/v1/projects/$projectId/databases/$dbId/documents";

echo "Trying database: $dbId\n";
echo "URL: $url\n\n";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Code: $httpCode\n";
echo "Response: $response\n";