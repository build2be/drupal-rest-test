<?php
require_once 'vendor/autoload.php';

use Guzzle\Http\Client;

function post($url, $headers, $payload)
{
    http('POST', $url, $headers, $payload);
}

function patch($url, $headers, $payload)
{
    http('PATCH', $url, $headers, $payload);
}

function http($method, $url, $headers, $payload)
{
    global $config;
    $client = new Client($config['url']);

    echo '--------------------' . PHP_EOL;
    echo $method . ' /' . $url . PHP_EOL;
    foreach ($headers as $key => $value) {
        echo $key . ': ' . $value . PHP_EOL;
    }
    echo PHP_EOL;
    echo json_encode(json_decode($payload, true), JSON_PRETTY_PRINT) . PHP_EOL;
    echo '--------------------' . PHP_EOL;
    try {
        $response = $client->createRequest($method, $url, $headers, $payload)
          ->setAuth($config['username'], $config['password'])
          ->send();
    } catch (\Guzzle\Http\Exception\ClientErrorResponseException $e) {
        $response = $e->getResponse();
    } catch (\Guzzle\Http\Exception\ServerErrorResponseException $e) {
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