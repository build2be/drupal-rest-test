<?php

require_once('vendor/autoload.php');

use Build2be\Drupal\Rest\DrupalConnector;
use Build2be\Drupal\Rest\Utility\TwigToJson;

$config = @parse_ini_file('rest.ini', false, INI_SCANNER_RAW);

if (isset($_SERVER['XDEBUG_CONFIG'])) {
    $argv[1] = end(explode('=', $_SERVER['XDEBUG_CONFIG']));
}

$url = $config['URL'];

$c = new DrupalConnector();
$c->setcontext(array(
    'username' => $config['USERNAME'],
    'password' => $config['PASSWORD'],
    'url' => $url,
));
$headers = array();
$path = 'node';
if ($argc == 2) {
    $c->setXDebug($argv[1]);
}

$t = new TwigToJson();

$values = array(
    'title' => 'Title: ' . $t->randomString(20),
    'body' => 'Body: ' . $t->randomString(64),
    'type' => 'node',
    'bundle' => 'article',
    'user' => 0,
    'url' => $config['URL'],
);

//$c->setDebug(2);
//$c->setContentType('application/json');
//$result = $c->post($path, $headers, $t->post($values));

$c->setDebug(2);

$c->setContentType('application/hal+json');

// Prepend 'entity/'
// @see Bug https://www.drupal.org/node/2293697
$result = $c->post('entity/' . $path, $headers, $t->post($values, 'hal'));

// PATCH
$location = '' . $result->getHeader('location');
echo "Location: $location" . PHP_EOL;

// Scrub of entity/
// @see Bug https://www.drupal.org/node/2293697
$path = str_replace($url . '/entity/', '', $location);
echo "Path: $path" . PHP_EOL;

$values['title'] = 'Patched: ' . $t->randomString(20);
$c->patch($path, $headers, $t->post($values, 'hal'));

$c->delete($path, $headers, NULL);