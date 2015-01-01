# == Class: gitlab
#
# Full description of class gitlab here.
#
# === Parameters
#
# [*download_url*]
#   The download URL for Gitlab omnibus edition. Get the latest from
#   https://about.gitlab.com/downloads/.
#
# [*installer_dir*]
#   The local path to the Gitlab omnibus install package file.
#
# [*installer_file*]
#   The name of the Gitlab omnibus install package file.
#
# [*installer_cmd*]
#   The package command to use to install Gitlab.
#
# [*worker_processes*]
#   The number of worker processes that Gitlab should run.
#
# [*ssl*]
#   True if SSL should be enabled.
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

class gitlab (
  $download_url = $gitlab::params::download_url,
  $installer_dir = $gitlab::params::installer_dir,
  $installer_file = $gitlab::params::installer_file,
  $installer_cmd = $gitlab::params::installer_cmd,
  $worker_processes = $gitlab::params::worker_processes,
  $ssl = $gitlab::params::ssl,
  $api_login = $gitlab::params::api_login,
  $api_password = $gitlab::params::api_password,
  $new_password = false,
  $add_root_pubkey = false,
) inherits gitlab::params {
  
  # Work out what the Gitlab URL will be.

  $http_scheme = str2bool($ssl) ? {
    true  => 'https',
    false => 'http'
  }

  $gitlab_url = "${http_scheme}://${::fqdn}"

  # Work out where the installer should be downloaded to.

  $installer_path = "${installer_dir}/${installer_file}"

  # Install Gitlab.

  class { 'gitlab::install':
    download_url     => $download_url,
    installer_path   => $installer_path,
    installer_cmd    => $installer_cmd,
    worker_processes => $worker_processes,
    gitlab_url       => $gitlab_url,
    ssl              => $ssl
  }

  # Configure Gitlab.

  class { 'gitlab::config':
    gitlab_url      => $gitlab_url,
    api_login       => $api_login,
    api_password    => $api_password,
    new_password    => $new_password,
    add_root_pubkey => $add_root_pubkey,
    require         => Class['gitlab::install']
  }
}
