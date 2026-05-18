<?php

require_once __DIR__ . '/functions.php';

class FirebaseService {
    private $projectId;
    private $apiKey;
    private $authUrl;
    private $firestoreUrl;
    private $idToken;
    private $localId;

    public function __construct() {
        $this->projectId = FIREBASE_PROJECT_ID;
        $this->apiKey = FIREBASE_API_KEY;
        $this->authUrl = FIREBASE_AUTH_URL;
        $this->firestoreUrl = FIRESTORE_URL;
    }

    public function setIdToken($token) {
        $this->idToken = $token;
    }

    public function setLocalId($localId) {
        $this->localId = $localId;
    }

    private function makeRequest($url, $method = 'GET', $data = null, $auth = false) {
        $headers = ['Content-Type: application/json'];
        if ($auth && $this->idToken) {
            $headers[] = 'Authorization: Bearer ' . $this->idToken;
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);

        if ($method === 'POST') {
            curl_setopt($ch, CURLOPT_POST, true);
            if ($data) {
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            }
        } elseif ($method === 'DELETE') {
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
        }

        $response = curl_exec($ch);
        $errno = curl_errno($ch);
        $error = curl_error($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        $result = [
            'code' => $httpCode,
            'data' => json_decode($response, true)
        ];

        if ($errno) {
            error_log("cURL Error ($errno): $error");
        }

        return $result;
    }

    public function signIn($email, $password) {
        $url = FIREBASE_TOKEN_URL . '?key=' . $this->apiKey;
        $data = [
            'email' => $email,
            'password' => $password,
            'returnSecureToken' => true
        ];

        $result = $this->makeRequest($url, 'POST', $data);

        if ($result['code'] === 200 && isset($result['data']['idToken'])) {
            return [
                'success' => true,
                'idToken' => $result['data']['idToken'],
                'localId' => $result['data']['localId'],
                'email' => $result['data']['email'],
                'refreshToken' => $result['data']['refreshToken'],
                'expiresIn' => $result['data']['expiresIn']
            ];
        }

        return [
            'success' => false,
            'error' => $result['data']['error']['message'] ?? 'Authentication failed',
            'debug' => $result['data'] ?? null
        ];
    }

    public function signUp($email, $password) {
        $url = FIREBASE_SIGNUP_URL . '?key=' . $this->apiKey;
        $data = [
            'email' => $email,
            'password' => $password,
            'returnSecureToken' => true
        ];

        error_log("Firebase SignUp URL: " . $url);
        error_log("Firebase SignUp Data: " . json_encode($data));

        $result = $this->makeRequest($url, 'POST', $data);
        
        error_log("Firebase SignUp Response: " . json_encode($result));

        if ($result['code'] === 200 && isset($result['data']['idToken'])) {
            return [
                'success' => true,
                'idToken' => $result['data']['idToken'],
                'localId' => $result['data']['localId'],
                'email' => $result['data']['email'],
                'refreshToken' => $result['data']['refreshToken'],
                'expiresIn' => $result['data']['expiresIn']
            ];
        }

        return [
            'success' => false,
            'error' => $result['data']['error']['message'] ?? 'Registration failed',
            'http_code' => $result['code'],
            'raw_response' => $result['data']
        ];
    }

    public function refreshToken($refreshToken) {
        $url = 'https://securetoken.googleapis.com/v1/token?key=' . $this->apiKey;
        $data = [
            'grant_type' => 'refresh_token',
            'refresh_token' => $refreshToken
        ];

        $result = $this->makeRequest($url, 'POST', $data);

        if ($result['code'] === 200) {
            return [
                'success' => true,
                'id_token' => $result['data']['id_token'],
                'refresh_token' => $result['data']['refresh_token']
            ];
        }

        return ['success' => false];
    }

    public function verifyIdToken($idToken) {
        $url = FIREBASE_AUTH_URL . '/accounts:lookup?key=' . $this->apiKey;
        $data = ['idToken' => $idToken];

        $result = $this->makeRequest($url, 'POST', $data);

        if ($result['code'] === 200 && !empty($result['data']['users'])) {
            return [
                'success' => true,
                'user' => $result['data']['users'][0]
            ];
        }

        return ['success' => false];
    }

    public function getCaregiverProfile($caregiverUid) {
        $url = $this->firestoreUrl . '/caregivers/' . $caregiverUid;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['fields'])) {
            return $this->parseFirestoreDocument($result['data']);
        }

        return null;
    }

    public function getCaregiverMedicines($caregiverUid) {
        $url = $this->firestoreUrl . '/caregivers/' . $caregiverUid . '/medicines';
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            $medicines = [];
            foreach ($result['data']['documents'] as $doc) {
                $medicines[] = $this->parseFirestoreDocument($doc);
            }
            return $medicines;
        }

        return [];
    }

    public function getCaregiverReminders($caregiverUid) {
        $url = $this->firestoreUrl . '/caregivers/' . $caregiverUid . '/reminders';
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            $reminders = [];
            foreach ($result['data']['documents'] as $doc) {
                $reminders[] = $this->parseFirestoreDocument($doc);
            }
            return $reminders;
        }

        return [];
    }

    public function getCaregiverHistory($caregiverUid, $limit = 100) {
        $url = $this->firestoreUrl . '/caregivers/' . $caregiverUid . '/history?orderBy=timestamp&limit=' . $limit;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            $history = [];
            foreach ($result['data']['documents'] as $doc) {
                $history[] = $this->parseFirestoreDocument($doc);
            }
            return $history;
        }

        return [];
    }

    public function getLinkedPatient($caregiverUid) {
        $url = $this->firestoreUrl . '/linkedPatients?where=caregiverUid';
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            foreach ($result['data']['documents'] as $doc) {
                $data = $this->parseFirestoreDocument($doc);
                if (isset($data['caregiverUid']) && $data['caregiverUid'] === $caregiverUid) {
                    return $data;
                }
            }
        }

        return null;
    }

    public function getUserByEmail($email) {
        $url = FIREBASE_AUTH_URL . '/accounts:lookup?key=' . $this->apiKey;
        $data = ['email' => [$email]];

        $result = $this->makeRequest($url, 'POST', $data);

        if ($result['code'] === 200 && !empty($result['data']['users'])) {
            return $result['data']['users'][0];
        }

        return null;
    }

    private function parseFirestoreDocument($doc) {
        $result = [];

        if (isset($doc['name'])) {
            $parts = explode('/', $doc['name']);
            $result['id'] = end($parts);
        }

        if (isset($doc['fields'])) {
            foreach ($doc['fields'] as $key => $field) {
                $result[$key] = $this->parseFirestoreField($field);
            }
        }

        return $result;
    }

    private function parseFirestoreField($field) {
        if (isset($field['stringValue'])) {
            return $field['stringValue'];
        }
        if (isset($field['integerValue'])) {
            return (int)$field['integerValue'];
        }
        if (isset($field['doubleValue'])) {
            return (float)$field['doubleValue'];
        }
        if (isset($field['booleanValue'])) {
            return $field['booleanValue'];
        }
        if (isset($field['timestampValue'])) {
            return $field['timestampValue'];
        }
        if (isset($field['mapValue'])) {
            $map = [];
            if (isset($field['mapValue']['fields'])) {
                foreach ($field['mapValue']['fields'] as $k => $v) {
                    $map[$k] = $this->parseFirestoreField($v);
                }
            }
            return $map;
        }
        if (isset($field['arrayValue'])) {
            $arr = [];
            if (isset($field['arrayValue']['values'])) {
                foreach ($field['arrayValue']['values'] as $v) {
                    $arr[] = $this->parseFirestoreField($v);
                }
            }
            return $arr;
        }

        return null;
    }

    // Generic methods for accessing any collection
    public function getCollectionDocuments($collection, $docId, $subcollection, $limit = 100) {
        $url = $this->firestoreUrl . '/' . $collection . '/' . $docId . '/' . $subcollection . '?limit=' . $limit;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            $docs = [];
            foreach ($result['data']['documents'] as $doc) {
                $docs[] = $this->parseFirestoreDocument($doc);
            }
            return $docs;
        }

        return [];
    }

    public function getDocument($collection, $docId) {
        $url = $this->firestoreUrl . '/' . $collection . '/' . $docId;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['fields'])) {
            return $this->parseFirestoreDocument($result['data']);
        }

        return null;
    }
}