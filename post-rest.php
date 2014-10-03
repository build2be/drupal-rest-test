<?php
require_once 'vendor/autoload.php';
use Guzzle\Http\Client;

require 'common.php';

$iniConfig = @parse_ini_file(__DIR__ . '/rest.ini', false, INI_SCANNER_RAW);

if(isset($_SERVER['XDEBUG_CONFIG'])){
    $argv[1] = end(explode('=', $_SERVER['XDEBUG_CONFIG']));
}

$config = array(
  'url' => $iniConfig['URL'],
  'username' => "admin",
  'password' => "admin",
  'post' => array(
    'node' => array(
      'fields' => array(
        'title' => 'test',
        'type' => array('value' => 'article'),
      ),
      'endpoint' => 'entity/node',
    )
  )
);

function buildPayload($config, $task)
{
    $payload = array();
    foreach ($config['post'][$task]['fields'] as $key => $value) {
        $payload[$key] = array($value);
    }
    return json_encode($payload);
}

foreach ($config['post'] as $taskname => $task) {
    $payload = buildPayload($config, $taskname);
    $headers = array();
    $headers['Content-type'] = 'application/json';
    $url = $task['endpoint'];
    if ($argc == 2) {
        $url .= '?XDEBUG_SESSION_START=' . $argv[1];
    }
    post($url, $headers, $payload);
}
