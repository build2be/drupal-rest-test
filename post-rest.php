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
        'type' => array(
          array(
            'value' => 'article',
          ),
        ),
      ),
      'endpoint' => 'entity/node',
    ),
    'comment' => array(
      'fields' => array(
        'entity_type' => 'node',
        'field_name' => 'comment',
        'entity_id' => array(
          array(
            'target_id' => 1,
          ),
        ),
        'comment_body' => array(
          array(
            'value' => 'Example comment message.',
          ),
        ),
      ),
      'endpoint' => 'entity/comment',
    )
  )
);

foreach ($config['post'] as $taskname => $task) {
    $payload = json_encode($config['post'][$taskname]['fields']);
    $headers = array();
    $headers['Content-type'] = 'application/json';
    $url = $task['endpoint'];
    if ($argc == 2) {
        $url .= '?XDEBUG_SESSION_START=' . $argv[1];
    }
    post($url, $headers, $payload);
}
