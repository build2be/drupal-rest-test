<?php

require_once('vendor/autoload.php');


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
$path = 'entity/node';
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
    'endpoint' => array(
        'post' => 'entity/node',
        'patch' => 'node',
        'delete' => 'node',
        'get' => 'node',
    ),
);

//$c->setDebug(2);
//$c->setContentType('application/json');
//$result = $c->post($path, $headers, $t->post($values));

$c->setDebug(2);

$c->setContentType('application/hal+json');
$result = $c->post($path, $headers, $t->post($values, 'hal'));

// PATCH
$location = '' . $result->getHeader('location');
echo "Location: $location" . PHP_EOL;
$patchPath = str_replace($url . '/entity/', '', $location);
echo "Path: $patchPath" . PHP_EOL;

$values['title'] = 'Patched: ' . $t->randomString(20);
$c->patch($patchPath, $headers, $t->post($values, 'hal'));
