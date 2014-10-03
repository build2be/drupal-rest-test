<?php
require_once 'vendor/autoload.php';

use Guzzle\Http\Client;

function post($url, $headers, $payload)
{
    global $config;
    $client = new Client($config['url']);

    echo '--------------------' . PHP_EOL;
    echo 'POST /' . $url . PHP_EOL;
    foreach ($headers as $key => $value) {
        echo $key . ': ' . $value . PHP_EOL;
    }
    echo PHP_EOL;
    echo json_encode(json_decode($payload, true), JSON_PRETTY_PRINT) . PHP_EOL;
    echo '--------------------' . PHP_EOL;
    try {
        $response = $client->post($url, $headers, $payload)
          ->setAuth($config['username'], $config['password'])
          ->send();
    } catch (\Guzzle\Http\Exception\ClientErrorResponseException $e) {
        $response = $e->getResponse();
    }
    echo 'Status Code: ' . $response->getStatusCode() . PHP_EOL;
    foreach ($response->getHeaders() as $key => $value) {
        echo $key . ': ' . $value . PHP_EOL;
    }
    echo PHP_EOL;
    $contentType = $response->getContentType();
    if (strpos($contentType, 'json') !== false) {
        echo json_encode(json_decode($response->getBody(true), true), JSON_PRETTY_PRINT) . PHP_EOL;
    } else {
        echo $response->getBody(true);
    }
    return $response;
}