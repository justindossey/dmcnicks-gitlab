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

class gitlab (
  $download_url,
  $api_password,
  $installer_dir = $gitlab::params::installer_dir,
  $installer_file = $gitlab::params::installer_file,
  $installer_cmd = $gitlab::params::installer_cmd,
  $default_password = $gitlab::params::default_password,
  $api_login = $gitlab::params::api_login,
  $api_url = $gitlab::params::api_url
) inherits gitlab::params {
  
  # Install Gitlab.

  $installer_path = "${installer_dir}/${installer_file}"

  class { 'gitlab::install':
    download_url   => $download_url,
    installer_path => $installer_path,
    installer_cmd  => $installer_cmd
  } ->

  # Configure Gitlab.

  class { 'gitlab::config':
    default_password => $default_password,
    api_login        => $api_login,
    api_password     => $api_password,
    api_url          => $api_url
  }
}
