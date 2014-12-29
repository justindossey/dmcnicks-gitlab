# == Class: gitlab::config
#
# Configures Gitlab.
#
# === Parameters
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
# [*api_url*]
#   The URL of the Gitlab API.
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
  $default_password,
  $api_login,
  $api_password,
  $api_url
) {

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

  # Change the default Gitlab password.

#  gitlab_user_password { $api_login:
#    password     => $api_password,
#    api_login    => $api_login,
#    api_password => $default_password,
#    api_url      => $api_url
#  } ->

  # Associate the root user public key with the Gitlab admin user.

  gitlab_user_key { $api_login:
    ensure       => 'present',
    username     => $api_login,
    userkey      => 'root',
    api_login    => $api_login,
    api_password => $default_password,
    api_url      => $api_url
  }
}
