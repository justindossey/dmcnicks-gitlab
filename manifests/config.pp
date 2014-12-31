# == Class: gitlab::config
#
# Configures Gitlab.
#
# === Parameters
#
# [*gitlab_url*]
#   The URL of Gitlab.
#
# [*default_password*]
#   The default password for the admin user set by the installer.
#
# [*api_login*]
#   The admin user used to access the Gitlab API.
#
# [*api_password*]
#   The password for the admin user.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#
# === Copyright
#
# Copyright 2014 David McNicol
#

class gitlab::config (
  $gitlab_url,
  $default_password,
  $api_login,
  $api_password
) {

  # Work out the Gitlab API URL.

  $api_url = "${gitlab_url}/api/v3"

  # The Gitlab configuration providers require the Ruby rest-client gem. Note
  # that this package will be installed on the first puppet run. The providers
  # themselves are confined to only run once the rest-client package is
  # available. Since providers are autoloaded in the pluginsync stage this
  # means that they will not run during the first puppet run. The next time
  # the agent is calle,d the rest-client package will be available, the confine
  # will return true and the providers will run.

  package { 'rest-client':
    ensure   => 'present',
    provider => 'gem'
  }

  # Login to the Gitlab API.

  gitlab_session { 'config':
    api_url      => $api_url,
    api_login    => $api_login,
    api_password => $default_password
  }

  # Change the default Gitlab password.

  gitlab_user { 'root':
    ensure       => 'present',
    session      => 'config',
    password     => 'foobar22'
  }

  gitlab_project { 'My Project':
    ensure => 'present',
    session => 'config'
  }
}
