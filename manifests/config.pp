# == Class: gitlab::config
#
# Configures Gitlab.
#
# === Parameters
#
# [*gitlab_url*]
#   The URL of Gitlab.
#
# [*admin_password*]
#   The new API password to set for the Gitlab root user.
#
# [*api_login*]
#   The admin user used to access the Gitlab API.
#
# [*api_default_password*]
#   The default password for hte Gitlab root user that Gitlab ships with.
#
# [*add_root_pubkey*]
#   If true, the SSH public key for the root user will be associated with the
#   root user in Gitlab. If the root user does not have an SSH keypair, one
#   will be generated.
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
  $admin_password,
  $api_login,
  $api_default_password,
  $add_root_pubkey
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

  # Login to the Gitlab API and change the password if it has been specified.

  gitlab_session { 'initial-gitlab-config':
    url          => $gitlab_url,
    login        => $api_login,
    password     => $api_default_password,
    new_password => $admin_password
  }

  if str2bool($add_root_pubkey) {

    # Generate a public key for the root user if necessary. Note that if the
    # key has to be generated it will not be available to puppet through the
    # gitlab_root_rsapubkey fact until the next Puppet agent run.

    gitlab::keygen { 'root':
      homedir => '/root'
    }

    # If a root public key is available on the node, add it to the root Gitlab
    # user.

    if $::gitlab_root_rsapubkey {

      gitlab_user_key { "root-${::fqdn}":
        ensure   => 'present',
        session  => 'initial-gitlab-config',
        username => 'root',
        key      => $::gitlab_root_rsapubkey
      }
    }
  }
}
