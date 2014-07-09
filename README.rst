.. Drupal REST test documentation master file, created by
   sphinx-quickstart on Wed Jul  9 12:30:47 2014.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Requirements
============

#. You should have a running `Drupal 8 <https://www.drupal.org/node/3060/git-instructions/8.x>`_ install
#. You must have installed `Drush <https://github.com/drush-ops/drush>`_
#. You need to know how to write `Drush aliases <http://drush.ws/examples/example.aliases.drushrc.php>`_

    #. ``$ vi ~/.drush/drupal.aliases.drushrc.php``

Install
=======

* Checkout this REPO
* Copy the rest.config.dist to rest.config
* Edit rest.config and set DRUSH_ALIAS and URL to your system config.

Install Drupal
==============

The script installs Rest UI and Devel modules:

* Install Drupal on given alias and URL.
* Configures Drupal according to the 'default' intended settings.
* Next shows the config from Rest UI::

    ./rest.sh install-modules install config


Switch to REST server mode
=========================

::

    ./rest.sh rest-set rest config


Run available tests
-------------------

::

    ./rest.sh rest config node comment user


Switch to HAL server mode
=========================

::

    ./rest.sh hal-set hal config


Run available tests
-------------------

::

    ./rest.sh hal config node comment user

