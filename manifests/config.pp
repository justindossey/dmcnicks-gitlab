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

  gitlab_user { $api_login:
    ensure       => 'present',
    session      => 'config',
    fullname     => 'Joe Bloggs',
    require      => Gitlab_session['config']
  }

  # Generate an SSH keypair for the root user if one does not exist.

#  gitlab::keygen { 'root':
#    homedir => '/root'
#  }

  # Associate the root user public key with the Gitlab root user.

#  gitlab_user_key { 'root-key':
#    ensure       => 'present',
#    session      => 'config',
#    username     => 'root',
#    fromuser     => 'root',
#    require      => [
#      Gitlab::Keygen['root'],
#      Gitlab_session['config']
#    ]
#  }

}
