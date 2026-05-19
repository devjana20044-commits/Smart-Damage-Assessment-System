<?php

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://10.183.151.151:8000/api');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Origin: http://192.168.1.100',
]);
$response = curl_exec($ch);
$headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
$headers = substr($response, 0, $headerSize);
echo "=== GET /api with Origin header ===\n";
echo $headers;
curl_close($ch);

$ch2 = curl_init();
curl_setopt($ch2, CURLOPT_URL, 'http://10.183.151.151:8000/api/login');
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HEADER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'Origin: http://192.168.1.100',
    'Access-Control-Request-Method: POST',
    'Access-Control-Request-Headers: Content-Type, Authorization',
]);
curl_setopt($ch2, CURLOPT_CUSTOMREQUEST, 'OPTIONS');
$response2 = curl_exec($ch2);
$headerSize2 = curl_getinfo($ch2, CURLINFO_HEADER_SIZE);
$headers2 = substr($response2, 0, $headerSize2);
echo "\n=== OPTIONS /api/login (Preflight) ===\n";
echo $headers2;
curl_close($ch2);
