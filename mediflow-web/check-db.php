<?php
require_once __DIR__ . '/config/firebase.php';

$projectId = 'mediflow-1b572';

// Try to get project info
$url = "https://datastore.googleapis.com/v1/projects/$projectId";
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);
echo "Response:\n";
echo $response;