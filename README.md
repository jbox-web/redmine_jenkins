## ![logo](https://raw.github.com/jbox-web/redmine_jenkins/gh-pages/images/jenkins_logo.png) Redmine Jenkins Plugin

[![GitHub license](https://img.shields.io/github/license/jbox-web/redmine_jenkins.svg)](https://github.com/jbox-web/redmine_jenkins/blob/devel/LICENSE)
[![GitHub release](https://img.shields.io/github/release/jbox-web/redmine_jenkins.svg)](https://github.com/jbox-web/redmine_jenkins/releases/latest)
[![Code Climate](https://codeclimate.com/github/jbox-web/redmine_jenkins.png)](https://codeclimate.com/github/jbox-web/redmine_jenkins)
[![Build Status](https://travis-ci.org/jbox-web/redmine_jenkins.svg?branch=devel)](https://travis-ci.org/jbox-web/redmine_jenkins)
[![Dependency Status](https://gemnasium.com/jbox-web/redmine_jenkins.svg)](https://gemnasium.com/jbox-web/redmine_jenkins)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jbox-web/redmine_jenkins?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

### A Redmine plugin which makes building your Jenkins projects easy ;)

This plugin allows straightforward management of Jenkins projects within Redmine.

## Installation

Assuming that you have Redmine installed :

```sh
## Before install the plugin, stop Redmine!

# Switch user
root# su - redmine

# First git clone Bootstrap Kit
redmine$ cd REDMINE_ROOT/plugins
redmine$ git clone https://github.com/jbox-web/redmine_bootstrap_kit.git
redmine$ cd redmine_bootstrap_kit/
redmine$ git checkout 0.2.3

# Then Redmine Jenkins plugin
redmine$ cd REDMINE_ROOT/plugins
redmine$ git clone https://github.com/jbox-web/redmine_jenkins.git
redmine$ cd redmine_jenkins/
redmine$ git checkout 1.0.1

# Install gems and migrate database
redmine$ cd REDMINE_ROOT/
redmine$ bundle install --without development test
redmine$ bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_jenkins

## After install the plugin, start Redmine!
```

## Troubleshooting

> I got a problem, when using apache2, passenger and git-gems, like this: http://stackoverflow.com/questions/6648870/is-not-checked-out-bundle-install-does-not-fix-help

```sh
# in case you are running apache2 with passenger, try this:
redmine$ bundle install --deployment
```

## Contribute

You can contribute to this plugin in many ways such as :
* Helping with documentation
* Contributing code (features or bugfixes)
* Reporting a bug
* Submitting translations
