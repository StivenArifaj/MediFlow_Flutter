<?php

/**
 * MediFlow Web Dashboard - Main Entry Point
 *
 * This file forwards all requests to the public/index.php which handles all routing
 */

$query = $_SERVER['QUERY_STRING'] ? '?' . $_SERVER['QUERY_STRING'] : '';
$path = dirname(__FILE__) . '/public/index.php';

require $path;