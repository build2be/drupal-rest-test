<?php
require_once 'vendor/autoload.php';
use Guzzle\Http\Client;

require 'common.php';

$iniConfig = @parse_ini_file(__DIR__ . '/rest.ini', false, INI_SCANNER_RAW);


$config = array(
  'url' => $iniConfig['URL'],
  'username' => "admin",
  'password' => "admin",
  'post' => array(
    'node' => array(
      'fields' => array(
        'title' => 'test',
      ),
      'type' => '/rest/type/node/article',
      'endpoint' => 'entity/node',
    ),
    'comment' => array(
      'relations' => array(
        'http://d8.dev/rest/relation/comment/comment/entity_id' => array(
          'href' => 'http://d8.dev/node/1',
          'fields' => array(
            'uuid' => 'af3710e7-fec3-4064-b500-b30d838236f5'
          ))
      ),
      'type' => '/rest/type/comment/comment',
      'fields' => array(
        'entity_type' => 'node',
        'comment_body' => 'test',
      ),
      'endpoint' => 'entity/comment',
    )
  )
);

function buildPayload($config, $task)
{
    $payload = array();
    foreach ($config['post'][$task]['fields'] as $key => $value) {
        $payload[$key] = array($value);
    }
    foreach ($config['post'][$task]['relations'] as $key => $value) {
        $payload['_links'][$key][]['href'] = $value['href'];
        $payload['_embedded'][$key] = array(
          $value['fields']
        );
    }
    $payload['_links']['type']['href'] = $config['url'] . $config['post'][$task]['type'];
    return json_encode($payload);
}

foreach ($config['post'] as $taskname => $task) {
    $payload = buildPayload($config, $taskname);
    $headers = array();
    $headers['Content-type'] = 'application/hal+json';
    $url = $task['endpoint'];
    if ($argc == 2) {
        $url .= '?XDEBUG_SESSION_START=' . $argv[1];
    }
    post($url, $headers, $payload);
}
