<?php

require 'vendor/autoload.php';

use Guzzle\Http\Client;

$config = array(
  'url' => "http://d8.dev",
  'username' => "admin",
  'password' => "admin",
  'post' => array(
    'node' => array(
      'field' => 'title',
      'value' => 'test',
      'type' => '/rest/type/node/article'
    )
  )
);

function buildPayload($config, $task)
{
    $payload = array();
    $payload['_links']['type']['href'] = $config['url'] . $config['post'][$task]['type'];
    $payload[$config['post'][$task]['field']] = array($config['post'][$task]['value']);
    return json_encode($payload);
}

$client = new Client($config['url']);
foreach ($config['post'] as $taskname => $task) {
    $payload = buildPayload($config, $taskname);
    $headers = array();
    $headers['Content-type'] = 'application/hal+json';
    $response = $client->post('entity/' . $taskname, $headers, $payload)
      ->setAuth($config['username'], $config['password'])
      ->send();

    echo 'created ' . $taskname . PHP_EOL;
    echo 'Response status: ' . $response->getStatusCode() . PHP_EOL;
    if ($response->getStatusCode() > 299 || $response->getStatusCode() < 200) {
        echo 'Response body: ' . PHP_EOL;
        try {
            $body = json_decode($response->getBody(), true);
            $body = print_r($body, true);
            echo $body;
        } catch (Exception $e) {
            echo $response->getBody();
        }
    }
}