# Drupal 8 drush alias
DRUSH_ALIAS=drupal.d8

# Rest server
URL=http://drupal.d8

HAL_HEADER="Accept: application/hal+json"
JSON_HEADER="Accept: application/json"

# defaults according to /core/modules/rest/config/install
ACCEPT_HEADER=$HAL_HEADER

CURL_USER="admin:admin"

# resources
RESOURCE_node=node/1
RESOURCE_user=user/1
RESOURCE_comment=comment/1

# Only show help when no arguments found
ARGS=$#

if [ "$1" == "install" ]; then
  drush @$DRUSH_ALIAS --yes site-install
  drush @$DRUSH_ALIAS user-password admin --password=admin

  # defaults according to /core/modules/rest/config/install
  drush @$DRUSH_ALIAS --yes pm-enable rest hal basic_auth

  # install helpers
  drush @$DRUSH_ALIAS --yes pm-enable restui devel_generate

  drush @$DRUSH_ALIAS --yes generate-content 1 2
  echo "  ERROR? : checkout https://www.drupal.org/node/2293781"

  cp ./rest-dist.yml ./rest.yml
  cp ./hal-dist.yml ./hal.yml

  shift
fi

if [ "$1" == "rest-set" ]; then
  ACCEPT_HEADER=$JSON_HEADER

  drush @$DRUSH_ALIAS --yes pm-enable rest
  drush @$DRUSH_ALIAS --yes pm-uninstall hal

  cat ./rest.yml | drush @$DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -

  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:node"
  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:comment"
  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:user"

  shift
fi

if [ "$1" == "rest" ]; then
  ACCEPT_HEADER=$JSON_HEADER
  shift
fi

if [ "$1" == "hal-set" ]; then
  ACCEPT_HEADER=$HAL_HEADER

  drush @$DRUSH_ALIAS --yes pm-enable hal

  cat ./hal.yml | drush @$DRUSH_ALIAS config-set --yes --format=yaml rest.settings resources.entity -

  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:node"
  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:user"
  drush @$DRUSH_ALIAS role-add-perm anonymous "restful get entity:comment"

  shift
fi

if [ "$1" == "hal" ]; then
  ACCEPT_HEADER=$HAL_HEADER
  shift
fi

if [ "$1" == "config" ]; then
  echo Settings:
  echo
  echo - alias   : @$DRUSH_ALIAS
  echo - accept  : $ACCEPT_HEADER
  echo - node    : $RESOURCE_NODE
  echo - comment : $RESOURCE_COMMENT
  echo - user    : $RESOURCE_USER
  echo
  echo rest.settings:
  echo
  drush @$DRUSH_ALIAS config-get rest.settings
  echo
  drush @$DRUSH_ALIAS sql-query "SELECT name, path FROM router WHERE name LIKE 'rest.entity.%';"

  echo "# Verify config manually"
  drush @$DRUSH_ALIAS user-login admin admin/config/services/rest

  shift
fi

if [ "$1" == "web" ]; then
  drush @$DRUSH_ALIAS user-login admin admin/config/services/rest
  shift
fi

for entity in "node" "comment" "user"; do
  if [ "$1" == "$entity" ]; then
    echo "========================"
    NAME="RESOURCE_$1"
    RESOURCE=${!NAME}
    echo "curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE"
    curl --user $CURL_USER --header "$ACCEPT_HEADER" --request GET $URL/$RESOURCE
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
  echo
fi

if [ "$#" -ne 0 ]; then
  echo "Failed to proces argumetns starting from: $1"
  echo "- check the order of your arguments or just run $0 for help"
fi
