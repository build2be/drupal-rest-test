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

How to install
=======

* Checkout this REPO
* Copy the rest.config.dist to rest.config
* Edit rest.config and set DRUSH_ALIAS and URL to your system config.

One liner
=========

Only run this on a empty drupal and at your own risk.

::

    ./rest.sh install-hal


Step by step
============

Install Drupal
--------------

The script installs Rest UI and Devel modules:

* Install Drupal on given alias and URL.
* Configures Drupal according to the 'default' intended settings.
* Next shows the config from Rest UI::

    ./rest.sh install-modules install config

Set permissions
---------------

Settings permissions depends on your command order. Make sure you have enabled either REST or HAL once.
Permissions depends on the the `rest.yml` and `hal.yml` files. So check when in doubt.

::

    ./rest.sh rest-set perms
    ./rest.sh hal-set perms


Content
-------

Make sure to have content posted through devel.

::

    ./rest.sh content


Switch to REST server mode
--------------------------

::

    ./rest.sh rest-set rest config


Run available tests
-------------------

::

    ./rest.sh rest config node comment user


Switch to HAL server mode
-------------------------

::

    ./rest.sh hal-set hal config


Run available tests
-------------------

::

    ./rest.sh hal config node comment user


Test POST using HAL
-------------------

Create a clear install with supporting modules::

    ./rest.sh install-modules install
    ./rest.sh hal-set hal config
    ./rest.sh hal node comment user # writes node/1 comment/1 and user/1 into /data dir
    php ./post.php # tries to post new node, comment, user
