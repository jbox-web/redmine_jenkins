#!/bin/bash

REDMINE_SOURCE_URL="http://www.redmine.org/releases"

REDMINE_NAME="redmine-${REDMINE_VERSION}"
REDMINE_PACKAGE="${REDMINE_NAME}.tar.gz"
REDMINE_URL="${REDMINE_SOURCE_URL}/${REDMINE_PACKAGE}"

GITHUB_USER=${GITHUB_USER:-jbox-web}
GITHUB_PROJECT=${GITHUB_PROJECT:-redmine_jenkins}
GITHUB_SOURCE="${GITHUB_USER}/${GITHUB_PROJECT}"

PLUGIN_PATH=${PLUGIN_PATH:-$GITHUB_SOURCE}
PLUGIN_NAME=${PLUGIN_NAME:-$GITHUB_PROJECT}

CURRENT_DIR=$(pwd)

echo ""
echo "######################"
echo "REDMINE INSTALLATION SCRIPT"
echo ""
echo "REDMINE_VERSION : ${REDMINE_VERSION}"
echo "REDMINE_URL     : ${REDMINE_URL}"
echo "CURRENT_DIR     : ${CURRENT_DIR}"
echo "GITHUB_SOURCE   : ${GITHUB_SOURCE}"
echo "PLUGIN_PATH     : ${PLUGIN_PATH}"
echo ""

echo "#### GET TARBALL"
wget "${REDMINE_URL}"
echo "Done !"
echo ""

echo "#### EXTRACT IT"
tar xf "${REDMINE_PACKAGE}"
echo "Done !"
echo ""

echo "#### MOVE PLUGIN"
mv "${PLUGIN_PATH}" "${REDMINE_NAME}/plugins"
rmdir "${PLUGIN_PATH}"
echo "Done !"
echo ""

echo "#### CREATE SYMLINK"
ln -s "${REDMINE_NAME}" "redmine"
echo "Done !"
echo ""

echo "#### INSTALL DATABASE FILE"
if [ "$DATABASE_ADAPTER" == "mysql" ] ; then
  echo "Type : mysql"
  cp "redmine/plugins/${PLUGIN_NAME}/spec/database_mysql.yml" "redmine/config/database.yml"
else
  echo "Type : postgres"
  cp "redmine/plugins/${PLUGIN_NAME}/spec/database_postgres.yml" "redmine/config/database.yml"
fi

echo "Done !"
echo ""

echo "#### INSTALL RSPEC FILE"
mkdir -p "redmine/spec"
cp "redmine/plugins/${PLUGIN_NAME}/spec/root_spec_helper.rb" "redmine/spec/spec_helper.rb"
echo "Done !"
echo ""

echo "#### UPDATE GEMFILE"
echo "Update shoulda to 3.5.0"
sed -i 's/gem "shoulda", "~> 3.3.2"/gem "shoulda", "~> 3.5.0"/' "redmine/Gemfile"
echo "Done !"
echo ""

echo "Update capybara to 2.2.0"
sed -i 's/gem "capybara", "~> 2.1.0"/gem "capybara", "~> 2.2.0"/' "redmine/Gemfile"
echo "Done !"
echo ""

echo "######################"
echo "CURRENT DIRECTORY LISTING"
echo ""

ls -l "${CURRENT_DIR}"
echo ""

echo "######################"
echo "REDMINE PLUGIN DIRECTORY LISTING"
echo ""

ls -l "${REDMINE_NAME}/plugins"
echo ""
