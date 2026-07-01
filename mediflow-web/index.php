<?php

/**
 * MediFlow Web Dashboard - Main Entry Point
 *
 * This file forwards all requests to the public/index.php which handles all routing
 */

// Get the query string and pass it to public/index.php
$path = dirname(__FILE__) . '/public/index.php';
$queryString = $_SERVER['QUERY_STRING'] ?? '';

// Include the public index with the query string
if (!empty($queryString)) {
    parse_str($queryString, $queryParams);
    $_GET = array_merge($_GET, $queryParams);
}

require $path;