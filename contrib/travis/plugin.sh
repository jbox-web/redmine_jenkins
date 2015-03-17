#!/bin/bash

GITHUB_USER=${GITHUB_USER:-jbox-web}
GITHUB_PROJECT=${GITHUB_PROJECT:-redmine_jenkins}

function install_plugin_packages() {
  log_title "INSTALL ADDITIONAL PACKAGES"
  echo "No package to install"
}

function install_plugin_dependencies() {
  git_clone 'redmine_bootstrap_kit' 'https://github.com/jbox-web/redmine_bootstrap_kit.git'
}
