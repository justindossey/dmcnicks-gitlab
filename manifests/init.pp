# == Class: gitlab
#
# Full description of class gitlab here.
#
# === Parameters
#
# [*admin_password*]
#   (Required) The new API password to set for the Gitlab root user.
#
# [*admin_email*]
#   (Required) The email address to set for the Gitlab root user.
#
# [*download_url*]
#   The download URL for Gitlab omnibus edition. Get the latest from
#   https://about.gitlab.com/downloads/.
#
# [*installer_file*]
#   The name of the Gitlab omnibus install package file.
#
# [*installer_cmd*]
#   The package command to use to install Gitlab.
#
# [*installer_dir*]
#   The local path to the Gitlab omnibus install package file.
#
# [*site*]
#   The name of the site that Gitlab will run on (defaults to $fqdn).
#
# [*port*]
#   The HTTP port that Gitlab will listen on (defaults to 80).
#
# [*ssl_port*]
#   The SSL port that Gitlab will listen on (defaults to 443).
#
# [*ssl*]
#   True if SSL should be enabled (defaults to true).
#
# [*worker_processes*]
#   The number of worker processes that Gitlab should run (defaults to 1).
#
# [*api_login*]
#   The admin user used to access the Gitlab API (defaults to root).
#
# [*api_default_password*]
#   The default password for hte Gitlab root user that Gitlab ships with.
#
# [*add_root_pubkey*]
#   If true, the SSH public key for the root user will be associated with the
#   root user in Gitlab. If the root user does not have an SSH keypair, one
#   will be generated (defaults to false).
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
  $admin_password,
  $admin_email,
  $download_url = $gitlab::params::download_url,
  $installer_file = $gitlab::params::installer_file,
  $installer_cmd = $gitlab::params::installer_cmd,
  $installer_dir = '/srv',
  $site = $::fqdn,
  $port = 80,
  $ssl_port = 443,
  $ssl = true,
  $worker_processes = 1,
  $api_login = 'root',
  $api_default_password = '5iveL!fe',
  $add_root_pubkey = false
) inherits gitlab::params {
  
  # Work out what the Gitlab URL will be.

  $http_scheme = str2bool($ssl) ? {
    true  => 'https',
    false => 'http'
  }

  $port_string = str2bool($ssl) ? {
    true => $ssl_port ? {
      "443"   => '',
      default => ":${ssl_port}"
    }
    false => $port ? {
      "80"    => '',
      default => ":${port}"
    }
  }

  $gitlab_url = "${http_scheme}://${site}${port_string}"

  # Work out where the installer should be downloaded to.

  $installer_path = "${installer_dir}/${installer_file}"

  # Install Gitlab.

  class { 'gitlab::install':
    download_url     => $download_url,
    installer_path   => $installer_path,
    installer_cmd    => $installer_cmd,
    worker_processes => $worker_processes,
    gitlab_url       => $gitlab_url,
    port             => $port,
    ssl_port         => $ssl_port,
    ssl              => $ssl,
  }

  # Configure Gitlab.

  class { 'gitlab::config':
    gitlab_url           => $gitlab_url,
    admin_password       => $admin_password,
    admin_email          => $admin_email,
    api_login            => $api_login,
    api_default_password => $api_default_password,
    add_root_pubkey      => $add_root_pubkey,
    require              => Class['gitlab::install']
  }
}
