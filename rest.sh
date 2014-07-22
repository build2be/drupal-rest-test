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
RESOURCE_node=node/2
RESOURCE_user=user/1
RESOURCE_comment=comment/1
RESOURCE_taxonomy_vocabulary=entity/taxonomy_vocabulary/tags
RESOURCE_nodes=api/rest/nodes

# TODO: add resources for
# taxonomy=taxonomy/term/1

# Only show help when no arguments found
ARGS=$#

if [ "$1" == "install-modules" ]; then
  # install helpers
  drush @$DRUSH_ALIAS --yes dl devel --package-handler=git_drupalorg

  # Make sure not to grab a version like 1.8
  drush @$DRUSH_ALIAS --yes dl --package-handler=git_drupalorg restui-1.x

  drush @$DRUSH_ALIAS --yes dl --package-handler=git_drupalorg oauth
  shift
fi

if [ "$1" == "install" ]; then
  drush @$DRUSH_ALIAS --yes site-install

  # TODO: split this into enable?
  drush @$DRUSH_ALIAS user-password admin --password=admin

  # defaults according to /core/modules/rest/config/install
  drush @$DRUSH_ALIAS --yes pm-enable rest hal basic_auth

  # enable helpers
  drush @$DRUSH_ALIAS --yes pm-enable restui devel_generate

  cp ./rest.yml.dist ./rest.yml
  cp ./hal.yml.dist ./hal.yml
  cp ./views.view.rest_nodes.yml.dist ./views.view.rest_nodes.yml

  [ -d ./data ] || mkdir ./data

  shift
fi

if [ "$1" == "views" ]; then
  echo "FIXME: $1"
  echo "Please load the view(s) manually."
  # TODO: somehow this is not loaded
  cat ./views.view.rest_nodes.yml | drush @$DRUSH_ALIAS config-set --yes --format=yaml views.view rest_nodes -

  drush @$DRUSH_ALIAS cache-rebuild

  # TODO: remove comment to make processing work again.
  # shift
fi

if [ "$1" == "content" ]; then

  drush @$DRUSH_ALIAS generate-users 3

  # Generate a node + comment
  drush @$DRUSH_ALIAS generate-content --types=article 2 3

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
  MODULE_NAME="rest"
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
  MODULE_NAME="hal"
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
for entity in "nodes" "node" "comment" "user" "taxonomy_vocabulary"; do
  if [ "$1" == "$entity" ]; then
    echo "========================"
    NAME="RESOURCE_$1"
    RESOURCE=${!NAME}
    FILE_NAME=./data/${MODULE_NAME}-$1.json
    echo "curl --user $CURL_USER --header "\"$ACCEPT_HEADER\"" --request GET $URL/$RESOURCE"
    curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE > $FILE_NAME
    echo ==========   RESPONSE   ==========
    cat $FILE_NAME
    echo ""
    echo =========== END RESPONSE =========
    echo
    shift
  fi
done

echo

if [ $ARGS -eq 0 ]; then
  echo "Run with one of the following argument(s):"
  echo
  echo "- install-modules install config : Run once to install Drupal and prepares config *-dist.yml"
  echo "- content                        : Generate node/1 user/1 comment/1 etc."
  echo "- rest-set config                : Switch to rest context"
  echo "- rest config node comment user  : Call with '$JSON_HEADER'"
  echo "- hal-set config                 : Switch to hal context"
  echo "- hal config node comment user   : Call with '$HAL_HEADER'"
  echo ""
  echo "- check the order of your arguments or just run $0 for help"
  echo "- the order of commands is"
  echo "  - install-modules              : installs latest devel and restui contrib modules"
  echo "  - install                      : installs drupal and enable appropriate modules"
  echo "  - views                        : installs views FIXME"
  echo "  - content                      : devel generate content"
  echo "  - rest-set                     : makes sure rest is configured correctly"
  echo "  - rest                         : set context to rest"
  echo "  - hal-set                      : makes sure hal is configured correctly"
  echo "  - hal                          : set context to hal"
  echo "  - perms                        : set all permissions"
  echo "  - config                       : list current congig"
  echo "  - web                          : alias to drush user-login"
  echo "  - anon                         : run REST/hal calls as anonymous user"
  echo "  - node                         : operate on -"
  echo "  - comment                      : operate on -"
  echo "  - user                         : operate on -"
  echo "  - taxonomy_vocabulary          : operate on -"
  echo
fi

if [ "$#" -ne 0 ]; then
  echo "Failed to process arguments starting from: $1"
  $0
fi
