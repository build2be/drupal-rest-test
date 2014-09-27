.. Drupal REST test documentation master file, created by
   sphinx-quickstart on Wed Jul  9 12:30:47 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

About this project
==================

As setting up a test environment is cumbersome this project provides for a install and test script.

It has a POST script to try posting entities into Drupal 8

DIY HAL POST a node is https://www.drupal.org/node/2098511

Known issues:

- Config Entities are not available through both REST or HAL. `Support ConfigEntity via REST <https://www.drupal.org/node/2300677>`_
- REST errors are not informative `Serve REST errors as application/api-problem+json OR application/vnd.error+json) <https://www.drupal.org/node/1916302>`_
- Manually `How to POST a comment and other relational entities <https://www.drupal.org/node/2300827>`_

Requirements
============

#. You should have a running `Drupal 8 <https://www.drupal.org/node/3060/git-instructions/8.x>`_ install
#. You must have installed `Drush <https://github.com/drush-ops/drush>`_
#. You need to know how to write `Drush aliases <http://drush.ws/examples/example.aliases.drushrc.php>`_
     ``$ vi ~/.drush/drupal.aliases.drushrc.php``

Alias file content::

   $aliases['d8'] = array (
     'root' => '/Users/clemens/Sites/drupal/d8/www',
     'uri' => 'http://drupal.d8',
     'databases' =>
     array (
       'default' =>
       array (
         'default' =>
         array (
           'database' => 'drupal_d8',
           'username' => 'drupal_d8',
           'password' => 'drupal_d8',
           'host' => 'localhost',
           'port' => '',
           'driver' => 'mysql',
           'prefix' => '',
         ),
       ),
     ),
   );

How to install
=======

* Checkout this REPO
* Copy the rest.config.dist to rest.config
* Edit rest.config and set DRUSH_ALIAS and URL to your system config.

Install HAL browser
=======

To test HAL navigation install https://github.com/mikekelly/hal-browser

Command line options
====

Run ``$ ./rest.sh`` gives:

Run with one of the following argument(s) in order of appearance:

Quick start argument sets are:

  - install-hal : Quickly installs and configures an empty site for HAL and query for content
  - hal-content : Query as admin for all hal configured content
  - hal-content-anon : Query as anonymous for all configured content
  - hal-9000 : Generate 42 nodes
  - json-content : Query as admin for all hal configured content
  - json-content-anon : Query as anonymous for all configured content

Step by step arguments are:

  - install : reinstalls drupal enable modules and setup config
  - install-modules : install contrib modules: devel rest_ui oauth
  - install-config : copies the .dist files
  - views : tries to install a view for the 'nodes' FIXME
  - content : generated the needed data: users nodes comment
  - rest-set : enable the rest module disable the hal module and load config
  - rest : set the accept header
  - hal-set : enable the hal module and load config
  - hal : set the accept header
  - perms : sets the known permissions for the exposed rest resources
  - web : alias for drush user-login
  - anon : swith to anonymous user which may not view profile
  - nodes : query the configured views is successful. FIXME
  - node : query for a node resource
  - comment : query for a comment resource
  - user : query for a user resource

Test POST using HAL
-------------------

Create a clear install with supporting modules::

    ./rest.sh install-modules install
    ./rest.sh hal-set hal config
    ./rest.sh hal node comment user # writes node/1 comment/1 and user/1 into /data dir
    php ./post.php # tries to post new node, comment, user
