#!/usr/bin/env bash

source ./rest.ini

# Enable command echo
# set -x

HAL_HEADER="Accept: application/hal+json"
JSON_HEADER="Accept: application/json"

# defaults according to /core/modules/rest/config/install
ACCEPT_HEADER=$HAL_HEADER

USER_1_NAME=`echo $USER_1 | cut -d: -f1`
USER_1_PASS=`echo $USER_1 | cut -d: -f2`

CURL_USERNAME=`echo $CURL_USER | cut -d: -f1`
CURL_PASSWORD=`echo $CURL_USER | cut -d: -f2`

# resources
RESOURCE_node=node/1
RESOURCE_user=user/1
RESOURCE_comment=comment/1

# depends on https://www.drupal.org/node/2100637
# Needs a rest views display on /node
RESOURCE_nodes=nodes

# TODO: add resources for
# taxonomy=taxonomy/term/1

# Only show help when no arguments found
ARGS=$#

# Define some macros

## ALIAS ##  - install-hal : Quickly installs and configures an empty site for HAL and query for content
if [ "$1" == "install-hal" ]; then
  $0 install install-modules content hal-set perms
  $0 hal-content
  $0 hal-content-anon
  exit;
fi

## ALIAS ##  - hal-content : Query as admin for all hal configured content
if [ "$1" == "hal-content" ]; then
  $0 hal nodes node comment user
  exit;
fi

## ALIAS ##  - hal-content-anon : Query as anonymous for all configured content
if [ "$1" == "hal-content-anon" ]; then
  $0 hal anon nodes node comment user
  exit;
fi

## ALIAS ##  - hal-9000 : Generate 42 nodes
if [ "$1" == "hal-9000" ]; then
  echo "I can't let you do that, $USER."
  exit;
fi

## ALIAS ##  - rest-content : Query as $CURL_USERNAME for all hal configured content
if [ "$1" == "rest-content" ]; then
  $0 rest nodes node comment user
  exit;
fi

## ALIAS ##  - rest-content-anon : Query as anonymous for all configured content
if [ "$1" == "rest-content-anon" ]; then
  $0 rest anon nodes node comment user
  exit;
fi

##  - install : reinstalls drupal enable modules and setup config
if [ "$1" == "install" ]; then
  drush $DRUSH_ALIAS --yes site-install

  # TODO: split this into enable?
  drush $DRUSH_ALIAS user-password $USER_1_NAME --password=$USER_1_PASS

  shift
fi

##  - install-modules : install contrib modules: devel rest_ui oauth
if [ "$1" == "install-modules" ]; then
  # install helpers
  drush $DRUSH_ALIAS --yes dl $PACKAGE_HANDLER devel

  # Make sure not to grab a version like 1.8
  drush $DRUSH_ALIAS --yes dl $PACKAGE_HANDLER restui-1.x

  drush $DRUSH_ALIAS --yes dl $PACKAGE_HANDLER oauth

  # defaults according to /core/modules/rest/config/install
  drush $DRUSH_ALIAS --yes pm-enable rest hal basic_auth

  # enable helpers
  drush $DRUSH_ALIAS --yes pm-enable devel_generate

  # broken: https://www.drupal.org/node/2316445
  # drush $DRUSH_ALIAS --yes restui

  shift
fi

##  - install-config : copies the .dist files
if [ "$1" == "install-config" ]; then
  [ -f ./rest.yml ] || cp ./rest.yml.dist ./rest.yml
  [ -f ./hal.yml ] || cp ./hal.yml.dist ./hal.yml
  [ -f ./views.view.rest_nodes.yml ] || cp ./views.view.rest_nodes.yml.dist ./views.view.rest_nodes.yml

  [ -d ./data ] || mkdir ./data
  shift
fi

##  - views : tries to install a view for the 'nodes' FIXME
if [ "$1" == "views" ]; then
  echo "FIXME: $1"
  echo "Please load the view(s) manually."
  # TODO: somehow this is not loaded
  cat ./views.view.rest_nodes.yml | drush $DRUSH_ALIAS config-set --yes --format=yaml views.view rest_nodes -

  drush $DRUSH_ALIAS cache-rebuild

  # TODO: remove comment to make processing work again.
  shift
fi

##  - content : generated the needed data: users nodes comment
if [ "$1" == "content" ]; then

  drush $DRUSH_ALIAS generate-users 3

  # Generate a node + comment
  drush $DRUSH_ALIAS generate-content --types=article 2 3

  shift
fi

##  - rest-set : enable the rest module disable the hal module and load config
if [ "$1" == "rest-set" ]; then
  drush $DRUSH_ALIAS --yes pm-enable rest
  drush $DRUSH_ALIAS --yes pm-uninstall hal

  cat ./rest.yml | drush $DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -
  drush $DRUSH_ALIAS cache-rebuild

  shift
fi

##  - rest : set the accept header
if [ "$1" == "rest" ]; then
  ACCEPT_HEADER=$JSON_HEADER
  MODULE_NAME="rest"
  shift
fi

##  - hal-set : enable the hal module and load config
if [ "$1" == "hal-set" ]; then
  drush $DRUSH_ALIAS --yes pm-enable hal

  cat ./hal.yml | drush $DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -
  drush $DRUSH_ALIAS cache-rebuild

  shift
fi

##  - hal : set the accept header
if [ "$1" == "hal" ]; then
  ACCEPT_HEADER=$HAL_HEADER
  MODULE_NAME="hal"
  shift
fi

##  - perms : sets the known permissions for the exposed rest resources
if [ "$1" == "perms" ]; then
  echo "--------------------------------------"
  echo "Setting permissions"

  for role in "anonymous" "administrator"; do

    # Waiting for https://github.com/drush-ops/drush/pull/740
    # drush $DRUSH_ALIAS role-add-perm "$role" "create article content" "edit any article content" "delete any article content"

    for perm in "create article content" "edit any article content" "delete any article content"; do
      drush $DRUSH_ALIAS role-add-perm "$role" "$perm"
    done

    for entity in "node" "comment" "user"; do
      # Waiting for https://github.com/drush-ops/drush/pull/740
      # drush $DRUSH_ALIAS role-add-perm "$role" "restful get entity:$entity" "restful post entity:$entity" "restful delete entity:$entity" "restful patch entity:$entity"

      for perm in "restful get entity:$entity" "restful post entity:$entity" "restful delete entity:$entity" "restful patch entity:$entity"; do
        drush $DRUSH_ALIAS role-add-perm "$role" "$perm"
      done
    done
  done

  shift
fi

# config : shows the config and provides login URL
if [ "$1" == "config" ]; then
  echo "--------------------------------------"
  echo "Settings:"
  echo
  echo "- drush   : $DRUSH_ALIAS"
  echo "- accept  : $ACCEPT_HEADER"
  echo "- node    : $RESOURCE_node"
  echo "- comment : $RESOURCE_comment"
  echo "- user    : $RESOURCE_user"
  echo
  echo "--------------------------------------"
  echo "rest.settings:"
  echo
  drush $DRUSH_ALIAS config-get rest.settings

  echo "--------------------------------------"
  echo "Database 'rest.entity.' config:"
  echo
  drush $DRUSH_ALIAS sql-query "SELECT name, path FROM router WHERE name LIKE 'rest.entity.%';"

  echo "--------------------------------------"
  echo "# Verify config manually"
  drush $DRUSH_ALIAS user-login admin admin/config/services/rest

  shift
fi

##  - web : alias for drush user-login
if [ "$1" == "web" ]; then
  drush $DRUSH_ALIAS user-login admin admin/config/services/rest
  shift
fi

##  - anon : swith to anonymous user which may not view profile
if [ "$1" == "anon" ]; then
  CURL_USER="anonymous:"
  shift
fi

# When adding new entity make sure to add it's RESOURCE_ above
##  - nodes : query the configured views is successful. FIXME
##  - node : query for a node resource
##  - comment : query for a comment resource
##  - user : query for a user resource
for entity in "nodes" "node" "comment" "user"; do
  if [ "$1" == "$entity" ]; then
    echo "========================"
    NAME="RESOURCE_$1"
    RESOURCE=${!NAME}
    FILE_NAME=./data/${MODULE_NAME}-$1.json
    echo "curl --user $CURL_USER --header "\"$ACCEPT_HEADER\"" --request GET $URL/$RESOURCE"
    curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE > $FILE_NAME
    echo ============ RESPONSE : $RESOURCE ============
    cat $FILE_NAME
    echo ""
    echo =========== END RESPONSE : $RESOURCE =========
    echo
    shift
  fi
done

echo

if [ $ARGS -eq 0 ]; then
  echo "Run with one or more of the following argument(s) in order of appearance:"
  echo ""
  echo "Quick start argument sets are:"
  echo ""
  grep "\#\#" $0 | grep "ALIAS" | cut -c 12-
  echo ""
  echo "Step by step arguments are:"
  echo ""
  grep "\#\#" $0 | grep -v "ALIAS" | cut -c 3-
  echo
fi

if [ "$#" -ne 0 ]; then
  echo "Failed to process arguments starting from: $1"
  $0
fi
