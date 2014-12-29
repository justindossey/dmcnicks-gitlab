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

class gitlab (
  $download_url,
  $api_password,
  $installer_dir = $gitlab::params::installer_dir,
  $installer_file = $gitlab::params::installer_file,
  $installer_cmd = $gitlab::params::installer_cmd,
  $ssl = $gitlab::params::ssl,
  $worker_processes = $gitlab::params::worker_processes,
  $default_password = $gitlab::params::default_password,
  $api_login = $gitlab::params::api_login
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
  } ->

  # Configure Gitlab.

  class { 'gitlab::config':
    gitlab_url       => $gitlab_url,
    default_password => $default_password,
    api_login        => $api_login,
    api_password     => $api_password
  }
}
