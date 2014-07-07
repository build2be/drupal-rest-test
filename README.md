# drupal-rest-test

Test some rest functionalities against Drupal 8 REST and HAL server

- Checkout this REPO
- Edit the drush alias
- Edit the URL

## Install Drupal

The script installs Rest UI and Devel modules

Install Drupal on given alias and URL. Configures Drupal according to the 'default' intended settings. Next shows the config from Rest UI.

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
