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

  # Load the ruby REST client.

  package { 'rest-client':
    ensure      => 'present',
    provisioner => 'gem'
  }

  # Change the default Gitlab password.

#  gitlab_user_password { $api_login:
#    password     => $api_password,
#    api_login    => $api_login,
#    api_password => $default_password,
#    api_url      => $api_url
#  } ->

  # Generate an SSH keypair for the root user if one does not exist.

  gitlab::keygen { 'root': } ->

  # Associate the root user public key with the Gitlab admin user.

  gitlab_user_key { $api_login:
    ensure       => 'present',
    username     => $api_login,
    userkey      => 'root',
    api_login    => $api_login,
    api_password => $default_password,
    api_url      => $api_url,
    require      => Package['rest-client']
  }
}
