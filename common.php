<?php
require_once 'vendor/autoload.php';

use Guzzle\Http\Client;

function post($url, $headers, $payload)
{
    return http('POST', $url, $headers, $payload);
}

function patch($url, $headers, $payload)
{
    return http('PATCH', $url, $headers, $payload);
}

function delete($url, $headers, $payload)
{
    return http('DELETE', $url, $headers, $payload);
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

function randomString($length)
{
    return join('', array_map(function () {
        return substr('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ   ', rand(0, 64), 1);
    }, range(1, $length)));
}
