<?php

require 'vendor/autoload.php';

use Guzzle\Http\Client;

class Runner {
  private $config;
  private $client;

  function init() {
    $this->config = array(
      'url' => "http://drupal.d8",
      'user' => "admin",
      'password' => "admin",
      'lookup' => array(
        'node' => resource('node/', 'entity/node'),
        'comment' => resource('comment/', 'entity/comment'),
      ),
    );

    $c = $this->getConfig();
    $this->client = new Client($c['url']);
    // If in a Drupal environment use the HTTP client service.
    // $client = \Drupal::httpClient()->setBaseUrl('http://drupal-8.localhost');
  }

  function getConfig() {
    return $this->config;
  }

  function getClient() {
    return $this->client;
  }

  function build($entity_type, $json) {
    if (!isset($json->_links)) {
      echo "No need to build node without {_links} value set.";
      return;
    }
    if (!isset($json->_links->type)) {
      echo "No need to build node without {_links: {type}} value set.";
      return;
    }
    if (!isset($json->_links->type->href)) {
      echo "No need to build node without {_links: {type: {href}}} value set.";
      return;
    }

    $c = $this->getConfig();

    $entity = array(
      '_links' => array(
        'type' => array(
          $json->_links->type,
        )
      ),
    );
    unset($json->_links->type->self);
    // As we are posting this IS a new thing
    unset($json->uuid);

    if ($entity_type == 'node') {
      $entity['title'] = $json->title;
      $entity['body'] = $json->body;
    }
    if ($entity_type == 'comment') {
      // For now we kick back the JSON: See https://www.drupal.org/node/2300827
      return $json;
      $entity['subject'] = $json->subject;
      $entity['comment_body'] = isset($json->comment_body) ? $json->comment_body : "Empty body by " . __FILE__;
      $entity['comment_type'] = $json->comment_type;
      $entity['entity_id'] = array('value' => 'node/1');
    }
    return $entity;
  }

  function postEntity($entity, $data) {
    $c = $this->getConfig();

    $data = json_encode($data);

    $response = $this->getClient()->post($c['lookup'][$entity]['hal'], array(
        'Content-type' => 'application/hal+json',
      ), $data)
      // Username and password for HTTP Basic Authentication.
      ->setAuth($c['user'], $c['password'])
      ->send();
    if ($response->getStatusCode() == 201) {
      echo $entity . ' creation successful!' . PHP_EOL;
    }
  }

}

$r = new Runner();
$r->init();
$c = $r->getConfig();

foreach ($c['lookup'] as $entity => $data) {
  $source = file_get_contents(__DIR__ . '/data/' . $entity . ".json");

  $json = json_decode($source);
  $post_entity = $r->build($entity, $json);
  file_put_contents(__DIR__ . '/data/' . $entity . "-post.json", json_encode($post_entity, TRUE));

  if ($post_entity) {
    $r->postEntity($entity, $post_entity);
  }
}

exit(0);



function resource($rest, $hal = NULL) {
  $hal ?: $rest;
  return array(
    'rest' => $rest,
    'hal' => $hal,
  );
}
