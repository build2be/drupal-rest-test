#!/usr/bin/env bash

source ./rest.config

# Enable command echo
# set -x

HAL_HEADER="Accept: application/hal+json"
JSON_HEADER="Accept: application/json"

# defaults according to /core/modules/rest/config/install
ACCEPT_HEADER=$HAL_HEADER

CURL_USER="admin:admin"

# resources
RESOURCE_node=node/1
RESOURCE_user=user/1
RESOURCE_comment=comment/1
RESOURCE_taxonomy_vocabulary=entity/taxonomy_vocabulary/tags
# TODO: add resources for
# taxonomy=taxonomy/term/1

# Only show help when no arguments found
ARGS=$#

if [ "$1" == "install-modules" ]; then
  # install helpers
  drush @$DRUSH_ALIAS --yes dl devel --package-handler=git_drupalorg
  # Make sure not to grab a version like 1.8
  drush @$DRUSH_ALIAS --yes dl restui-1.x --package-handler=git_drupalorg
  shift
fi

if [ "$1" == "install" ]; then
  drush @$DRUSH_ALIAS --yes site-install
  drush @$DRUSH_ALIAS user-password admin --password=admin

  # defaults according to /core/modules/rest/config/install
  drush @$DRUSH_ALIAS --yes pm-enable rest hal basic_auth

  # enable helpers
  drush @$DRUSH_ALIAS --yes pm-enable restui devel_generate

  drush @$DRUSH_ALIAS generate-users 3

  # Generate a node + comment
  drush @$DRUSH_ALIAS generate-content --types=article 2 3

  cp ./rest.yml.dist ./rest.yml
  cp ./hal.yml.dist ./hal.yml
  [ -d ./data ] || mkdir ./data

  shift
fi

if [ "$1" == "rest-set" ]; then
  drush @$DRUSH_ALIAS --yes pm-enable rest
  drush @$DRUSH_ALIAS --yes pm-uninstall hal

  cat ./rest.yml | drush @$DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -
  drush @$DRUSH_ALIAS cache-rebuild

  shift
fi

if [ "$1" == "rest" ]; then
  ACCEPT_HEADER=$JSON_HEADER
  shift
fi

if [ "$1" == "hal-set" ]; then
  drush @$DRUSH_ALIAS --yes pm-enable hal

  cat ./hal.yml | drush @$DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -
  drush @$DRUSH_ALIAS cache-rebuild

  shift
fi

if [ "$1" == "hal" ]; then
  ACCEPT_HEADER=$HAL_HEADER
  shift
fi

if [ "$1" == "perms" ]; then
  echo "--------------------------------------"
  echo "Setting permissions"

  for role in "anonymous" "administrator"; do

    for perm in "create article content" "edit any article content" "delete any article content"; do
      drush @$DRUSH_ALIAS role-add-perm "$role" "$perm"
    done

    for entity in "node" "comment" "user" "taxonomy_vocabulary"; do
      for perm in "restful get entity:$entity" "restful post entity:$entity" "restful delete entity:$entity" "restful patch entity:$entity"; do
        drush @$DRUSH_ALIAS role-add-perm "$role" "$perm"
      done
    done
  done

  shift
fi

if [ "$1" == "config" ]; then
  echo "--------------------------------------"
  echo "Settings:"
  echo
  echo "- alias   : @$DRUSH_ALIAS"
  echo "- accept  : $ACCEPT_HEADER"
  echo "- node    : $RESOURCE_node"
  echo "- comment : $RESOURCE_comment"
  echo "- user    : $RESOURCE_user"
  echo
  echo "--------------------------------------"
  echo "rest.settings:"
  echo
  drush @$DRUSH_ALIAS config-get rest.settings

  echo "--------------------------------------"
  echo "Database 'rest.entity.' config:"
  echo
  drush @$DRUSH_ALIAS sql-query "SELECT name, path FROM router WHERE name LIKE 'rest.entity.%';"

  echo "--------------------------------------"
  echo "# Verify config manually"
  drush @$DRUSH_ALIAS user-login admin admin/config/services/rest

  shift
fi

if [ "$1" == "web" ]; then
  drush @$DRUSH_ALIAS user-login admin admin/config/services/rest
  shift
fi

if [ "$1" == "anon" ]; then
  CURL_USER="anonymous:"
  shift
fi

# When adding new entity make sure to add it's RESOURCE_ above
for entity in "node" "comment" "user" "taxonomy_vocabulary"; do
  if [ "$1" == "$entity" ]; then
    echo "========================"
    NAME="RESOURCE_$1"
    RESOURCE=${!NAME}
    echo "curl --user $CURL_USER --header "\"$ACCEPT_HEADER\"" --request GET $URL/$RESOURCE"
    curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE > ./data/$1.json
    cat ./data/$1.json
    echo
    shift
  fi
done

echo

if [ $ARGS -eq 0 ]; then
  echo "Run with one of the following argument(s):"
  echo
  echo "- install config                : Run once to install Drupal and prepares config *-dist.yml"
  echo "- rest-set config               : Switch to rest context"
  echo "- rest config node comment user : Call with $JSON_HEADER"
  echo "- hal-set config                : Switch to hal context"
  echo "- hal config node comment user  : Call with $JSON_HEADER"
  echo "- check the order of your arguments or just run $0 for help"
  echo "- the order of commands is"
  echo "  - install-modules"
  echo "  - install"
  echo "  - rest-set"
  echo "  - rest"
  echo "  - hal-set"
  echo "  - hal"
  echo "  - perms"
  echo "  - config"
  echo "  - web"
  echo "  - anon"
  echo "  - node"
  echo "  - comment"
  echo "  - user"
  echo "  - taxonomy_vocabulary"
  echo
fi

if [ "$#" -ne 0 ]; then
  echo "Failed to process arguments starting from: $1"
  $0
fi
