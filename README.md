# drupal-rest-test

Test some rest functionalities against Drupal 8 REST and HAL server

## Requirements

1. You should have a running [Drupal 8](https://www.drupal.org/node/3060/git-instructions/8.x) install
1. You must have installed [Drush](https://github.com/drush-ops/drush)
1. You need to know how to write [Drush aliases](http://drush.ws/examples/example.aliases.drushrc.php)
  1. `$ vi ~/.drush/drupal.aliases.drushrc.php`  

## Install

- Checkout this REPO
- Copy the rest.config.dist to rest.config
- Edit rest.config and set DRUSH_ALIAS and URL to your system config.

## Install Drupal

The script installs Rest UI and Devel modules:

- Install Drupal on given alias and URL.
- Configures Drupal according to the 'default' intended settings.
- Next shows the config from Rest UI.

```bash
./rest.sh install config
```

## Switch to REST server mode

```bash
./rest.sh rest-set rest config
```

### Run available tests

```bash
./rest.sh rest config node comment user
```

## Switch to HAL server mode

```bash
./rest.sh hal-set hal config
```

### Run available tests

```bash
./rest.sh hal config node comment user
```
