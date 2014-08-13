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

# depends on https://www.drupal.org/node/2100637
# Needs a rest views display on /node
RESOURCE_nodes=nodes

# TODO: add resources for
# taxonomy=taxonomy/term/1

# Only show help when no arguments found or unknown command
ARGS=$#

echo "Running: $1"

# Define some macros

## ALIAS ##  - full-install :      Quickly installs and configures an empty site for HAL and query for content
if [ "$1" == "full-install" ]; then
  $0 install install-modules generate-content rest-resources perms
  $0 hal-content
  $0 hal-content-anon
  exit;
fi

## ALIAS ##  - hal-content :       Query as admin for all HAL configured content
if [ "$1" == "hal-content" ]; then
  $0 hal nodes node comment user
  exit;
fi

## ALIAS ##  - hal-content-anon :  Query as anonymous for all HAL configured content
if [ "$1" == "hal-content-anon" ]; then
  $0 hal anon nodes node comment user
  exit;
fi

## ALIAS ##  - hal-9000 :          Generate 42 nodes
if [ "$1" == "hal-9000" ]; then
  echo "I can't let you do that, $USER."
  exit;
fi

## ALIAS ##  - rest-content :      Query as $CURL_USERNAME for all rest configured content
if [ "$1" == "rest-content" ]; then
  $0 rest nodes node comment user
  exit;
fi

## ALIAS ##  - rest-content-anon : Query as anonymous for all rest configured content
if [ "$1" == "rest-content-anon" ]; then
  $0 rest anon nodes node comment user
  exit;
fi

##  - install :           Reinstall drupal enable modules and setup config
if [ "$1" == "install" ]; then
  drush $DRUSH_ALIAS --yes site-install

  # TODO: split this into enable?
  drush $DRUSH_ALIAS user-password $USER_1_NAME --password=$USER_1_PASS

  shift
fi

##  - install-modules :   Install contrib modules: devel rest_ui oauth
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

##  - install-config :    Copies the .dist files
if [ "$1" == "install-config" ]; then
  [ -f ./rest.yml ] || cp ./rest.yml.dist ./rest.yml
  [ -f ./views.view.rest_nodes.yml ] || cp ./views.view.rest_nodes.yml.dist ./views.view.rest_nodes.yml

  [ -d ./data ] || mkdir ./data
  shift
fi

##  - views :             Tries to install a view for the 'nodes' FIXME
if [ "$1" == "views" ]; then
  echo "FIXME: $1"
  echo "Please load the view(s) manually."
  # TODO: somehow this is not loaded
  cat ./views.view.rest_nodes.yml | drush $DRUSH_ALIAS config-set --yes --format=yaml views.view rest_nodes -

  drush $DRUSH_ALIAS cache-rebuild

  # TODO: remove comment to make processing work again.
  shift
fi

##  - generate-content :  Generated the needed data: users nodes comment
if [ "$1" == "generate-content" ]; then

  drush $DRUSH_ALIAS generate-users 3

  # Add terms as they are entity references we could test against.
  drush $DRUSH_ALIAS generate-terms tags 4

  # Generate a node + comment
  drush $DRUSH_ALIAS generate-content --types=article 2 3

  shift
fi

##  - rest-resources :    Enable the modules and load config providing the ReST API's HAL and json.
if [ "$1" == "rest-resources" ]; then
  drush $DRUSH_ALIAS --yes pm-enable hal

  cat ./rest.yml | drush $DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -
  drush $DRUSH_ALIAS cache-rebuild

  shift
fi

##  - rest :              Set Accept-header to json.
if [ "$1" == "rest" ]; then
  ACCEPT_HEADER=$JSON_HEADER
  MODULE_NAME="rest"
  shift
fi

##  - hal :               Set Accept-header ti hal+json.
if [ "$1" == "hal" ]; then
  ACCEPT_HEADER=$HAL_HEADER
  MODULE_NAME="hal"
  shift
fi

##  - perms :             Set the known permissions for the exposed rest resources.
if [ "$1" == "perms" ]; then
  echo "--------------------------------------"
  echo "Setting permissions"

  for role in "anonymous" "administrator"; do

    ROLES="create article content,edit any article content,delete any article content"

    for entity in "node" "comment" "user" "taxonomy_term" ; do
      ROLES="$ROLES,restful get entity:$entity,restful post entity:$entity,restful delete entity:$entity,restful patch entity:$entity"
    done
    drush $DRUSH_ALIAS role-add-perm $role "$ROLES"
  done

  shift
fi

##  - config :            Show the config and provides login URL
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

##  - web :               Alias for drush user-login
if [ "$1" == "web" ]; then
  drush $DRUSH_ALIAS user-login admin admin/config/services/rest
  shift
fi

##  - anon :              Swith to anonymous user which may not view profile
if [ "$1" == "anon" ]; then
  CURL_USER="anonymous:"
  shift
fi

# When adding new entity make sure to add it's RESOURCE_ above
##  - nodes :             Query the configured views is successful. FIXME
##  - node :              Query for a node resource
##  - comment :           Query for a comment resource
##  - user :              Query for a user resource
for entity in "nodes" "node" "comment" "user" "file" ; do
  if [ "$1" == "$entity" ]; then
    echo "========================"
    NAME="RESOURCE_$1"
    RESOURCE=${!NAME}
    FILE_NAME=./data/${MODULE_NAME}-$1.json
    echo "curl --user $CURL_USER --header "\"$ACCEPT_HEADER\"" --request GET $URL/$RESOURCE"
    curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE > $FILE_NAME
    echo ============ RESPONSE : $RESOURCE ============
    cat $FILE_NAME | $JSON_PRETTY_PRINT
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
