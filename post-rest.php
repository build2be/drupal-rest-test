<?php

require 'vendor/autoload.php';

use Guzzle\Http\Client;

$iniConfig = parse_ini_file(__DIR__ . '/rest.ini', false, INI_SCANNER_RAW);


$config = array(
    'url' => $iniConfig['URL'],
    'username' => "admin",
    'password' => "admin",
    'post' => array(
        'node' => array(
            'fields' => array(
                'title' => 'test',
            ),
            'type' => '/rest/type/node/article'
        )
    )
);

function buildPayload($config, $task)
{
    $payload = array();
    $payload['_links']['type']['href'] = $config['url'] . $config['post'][$task]['type'];
    foreach ($config['post'][$task]['fields'] as $key => $value) {
        $payload[$key] = array($value);
    }
    return json_encode($payload);
}

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
    echo json_encode(json_decode($payload, true), JSON_PRETTY_PRINT).PHP_EOL;
    echo '--------------------' . PHP_EOL;

    $response = $client->post($url, $headers, $payload)
        ->setAuth($config['username'], $config['password'])
        ->send();
    return $response;
}


foreach ($config['post'] as $taskname => $task) {
    $payload = buildPayload($config, $taskname);
    $headers = array();
    $headers['Content-type'] = 'application/json';
    $response = post('' . $taskname, $headers, $payload);

    echo 'created ' . $taskname . PHP_EOL;
    echo 'Response status: ' . $response->getStatusCode() . PHP_EOL;
    if ($response->getStatusCode() > 299 || $response->getStatusCode() < 200) {
        echo 'Response: ' . PHP_EOL;
        try {
            echo "Success:" . PHP_EOL;
            $body = json_decode($response->getBody(), true);
            $body = print_r($body, true);
            echo $body;
        } catch (Exception $e) {
            echo "Failure:" . PHP_EOL;
            echo $response->getBody();
        }
    }
}
