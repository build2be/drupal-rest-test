<?php

require 'vendor/autoload.php';

use Guzzle\Http\Client;

$config = array(
  'url' => "http://d8.dev",
  'username' => "admin",
  'password' => "admin",
  'patch' => array(
    'node' => array(
      'url' => 'node/1',
      'field' => 'title',
      'value' => 'test',
      'type' => '/rest/type/node/article'
    )
  )
);

$ini = parse_ini_file("rest.ini", true);
$patch = parse_ini_file("patch.ini", true);


$ini['patch']['users'] = explode(":",$ini['patch']['users']);

$config['url'] = $ini['URL'];
$config['username'] = $ini['patch']['user'];

var_dump($ini);
echo json_encode($config);
return;

function buildPayload($config, $task)
{
    $payload = array();
    $payload['_links']['type']['href'] = $config['url'] . $config['patch'][$task]['type'];
    $payload[$config['patch'][$task]['field']] = array($config['patch'][$task]['value']);
    return json_encode($payload);
}

$client = new Client($config['url']);
foreach ($config['patch'] as $taskname => $task) {
    $payload = buildPayload($config, $taskname);
    $headers = array();
    $headers['Content-type'] = 'application/hal+json';
    $response = $client->patch($task['url'], $headers, $payload)
      ->setAuth($config['username'], $config['password'])
      ->send();

    echo 'Patched ' . $taskname . PHP_EOL;
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