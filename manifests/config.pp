# == Class: gitlab::config
#
# Configures Gitlab.
#
# === Parameters
#
# [*gitlab_url*]
#   The URL of Gitlab.
#
# [*api_login*]
#   The admin user used to access the Gitlab API.
#
# [*api_password*]
#   The password for the admin user.
#
# [*new_password*]
#   The new password for the admin user, which will be set if specified.
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
  $api_login,
  $api_password,
  $new_password
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

  notice( "TEST2" )
  notice( "TEST ${gitlab_root_pubkey}" )

  # Login to the Gitlab API and change the password if it has been specified.

  gitlab_session { 'initial-gitlab-config':
    url          => $gitlab_url,
    login        => $api_login,
    password     => $api_password,
    new_password => $new_password
  }
}
