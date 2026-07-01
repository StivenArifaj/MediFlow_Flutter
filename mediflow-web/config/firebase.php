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
        $this->projectId    = FIREBASE_PROJECT_ID;
        $this->apiKey       = FIREBASE_API_KEY;
        $this->authUrl      = FIREBASE_AUTH_URL;
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
        $errno    = curl_errno($ch);
        $error    = curl_error($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($errno) {
            error_log("cURL Error ($errno): $error");
        }

        return [
            'code' => $httpCode,
            'data' => json_decode($response, true),
        ];
    }

    // ── Auth ──────────────────────────────────────────────────────────────────

    public function signIn($email, $password) {
        $url    = FIREBASE_TOKEN_URL . '?key=' . $this->apiKey;
        $result = $this->makeRequest($url, 'POST', [
            'email'             => $email,
            'password'          => $password,
            'returnSecureToken' => true,
        ]);

        if ($result['code'] === 200 && isset($result['data']['idToken'])) {
            return [
                'success'      => true,
                'idToken'      => $result['data']['idToken'],
                'localId'      => $result['data']['localId'],
                'email'        => $result['data']['email'],
                'refreshToken' => $result['data']['refreshToken'],
                'expiresIn'    => $result['data']['expiresIn'],
            ];
        }

        return [
            'success' => false,
            'error'   => $result['data']['error']['message'] ?? 'Authentication failed',
        ];
    }

    public function signUp($email, $password) {
        $url    = FIREBASE_SIGNUP_URL . '?key=' . $this->apiKey;
        $result = $this->makeRequest($url, 'POST', [
            'email'             => $email,
            'password'          => $password,
            'returnSecureToken' => true,
        ]);

        if ($result['code'] === 200 && isset($result['data']['idToken'])) {
            return [
                'success'      => true,
                'idToken'      => $result['data']['idToken'],
                'localId'      => $result['data']['localId'],
                'email'        => $result['data']['email'],
                'refreshToken' => $result['data']['refreshToken'],
                'expiresIn'    => $result['data']['expiresIn'],
            ];
        }

        return [
            'success'      => false,
            'error'        => $result['data']['error']['message'] ?? 'Registration failed',
            'http_code'    => $result['code'],
            'raw_response' => $result['data'],
        ];
    }

    public function refreshToken($refreshToken) {
        $url    = 'https://securetoken.googleapis.com/v1/token?key=' . $this->apiKey;
        $result = $this->makeRequest($url, 'POST', [
            'grant_type'    => 'refresh_token',
            'refresh_token' => $refreshToken,
        ]);

        if ($result['code'] === 200) {
            return [
                'success'       => true,
                'id_token'      => $result['data']['id_token'],
                'refresh_token' => $result['data']['refresh_token'],
            ];
        }

        return ['success' => false];
    }

    public function getUserByEmail($email) {
        $url    = FIREBASE_AUTH_URL . '/accounts:lookup?key=' . $this->apiKey;
        $result = $this->makeRequest($url, 'POST', ['email' => [$email]]);

        if ($result['code'] === 200 && !empty($result['data']['users'])) {
            return $result['data']['users'][0];
        }

        return null;
    }

    // ── Firestore ─────────────────────────────────────────────────────────────

    public function getDocument($collection, $docId) {
        $url    = $this->firestoreUrl . '/' . $collection . '/' . $docId;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['fields'])) {
            return $this->parseFirestoreDocument($result['data']);
        }

        if ($result['code'] !== 200 && $result['code'] !== 404) {
            error_log("Firestore getDocument HTTP {$result['code']} — $collection/$docId — " . json_encode($result['data']));
        }

        return null;
    }

    public function getCollectionDocuments($collection, $docId, $subcollection, $limit = 100) {
        $url    = $this->firestoreUrl . '/' . $collection . '/' . $docId . '/' . $subcollection . '?pageSize=' . $limit;
        $result = $this->makeRequest($url, 'GET', null, true);

        if ($result['code'] === 200 && isset($result['data']['documents'])) {
            $docs = [];
            foreach ($result['data']['documents'] as $doc) {
                $docs[] = $this->parseFirestoreDocument($doc);
            }
            return $docs;
        }

        if ($result['code'] !== 200) {
            error_log("Firestore getCollectionDocuments HTTP {$result['code']} — $collection/$docId/$subcollection — " . json_encode($result['data']));
        }

        return [];
    }

    // Look up a user by email via Firebase Auth, then fetch their Firestore profile.
    public function findUserByEmail($email) {
        $authUser = $this->getUserByEmail($email);
        if ($authUser && isset($authUser['localId'])) {
            $uid     = $authUser['localId'];
            $profile = $this->getDocument('users', $uid);
            return [
                'uid'  => $uid,
                'data' => $profile ?? [],
            ];
        }
        return null;
    }

    // ── Firestore document parsing ────────────────────────────────────────────

    private function parseFirestoreDocument($doc) {
        $result = [];

        if (isset($doc['name'])) {
            $parts         = explode('/', $doc['name']);
            $result['id']  = end($parts);
        }

        if (isset($doc['fields'])) {
            foreach ($doc['fields'] as $key => $field) {
                $result[$key] = $this->parseFirestoreField($field);
            }
        }

        return $result;
    }

    private function parseFirestoreField($field) {
        if (isset($field['stringValue']))    return $field['stringValue'];
        if (isset($field['integerValue']))   return (int)$field['integerValue'];
        if (isset($field['doubleValue']))    return (float)$field['doubleValue'];
        if (isset($field['booleanValue']))   return $field['booleanValue'];
        if (isset($field['timestampValue'])) return $field['timestampValue'];

        if (isset($field['mapValue'])) {
            $map = [];
            foreach ($field['mapValue']['fields'] ?? [] as $k => $v) {
                $map[$k] = $this->parseFirestoreField($v);
            }
            return $map;
        }

        if (isset($field['arrayValue'])) {
            $arr = [];
            foreach ($field['arrayValue']['values'] ?? [] as $v) {
                $arr[] = $this->parseFirestoreField($v);
            }
            return $arr;
        }

        return null;
    }
}
