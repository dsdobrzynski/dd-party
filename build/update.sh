#!/usr/bin/env bash

set -e
path="$(dirname "$0")"
source "$path/common.sh"

# Change to the Drupal Directory Just In Case
pushd "$drupal_base"

# This was added because of upgrades like Rules 2.8 to 2.9 and Feeds alpha-9 to beta-1 where
# new code and database tables are added and running other code will cause white screen until
# the updates are run.
echo "Initial Update so updated modules can work.";
$drush updb -y;
# Rebuild cache so recently added modules are found.
echo "Clearing cache.";
$drush cr
echo "Enabling modules.";
$drush en $(echo $DROPSHIP_SEEDS | tr ':' ' ') -y
echo "Enabling themes.";
$drush en $DEFAULT_THEME $ADMIN_THEME -y
echo "Clearing drush cache."
$drush cr drush
echo "Reverting configuration."
$drush cim sync --partial -y
$drush cim overrides --partial -y
if [ "$SITE_ENVIRONMENT" = "dev" ]; then
  echo "Importing dev configuration."
  $drush cim dev --partial -y
fi
echo "Importing Features"
$drush fia -y
echo "Clearing caches one last time.";
$drush cr

chmod -R +w "$base/cnf"
chmod -R +w "$base/html/sites/default"
