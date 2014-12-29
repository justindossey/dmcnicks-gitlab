# == Class: gitlab::install
#
# Install Gitlab.
#
# === Parameters
#
# [*download_url*]
#   The download URL for Gitlab omnibus edition. Get the latest from
#   https://about.gitlab.com/downloads/.
#
# [*installer_path*]
#   The local path of the Gitlab omnibus install package file.
#
# [*installer_cmd*]
#   The package command to use to install Gitlab.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#
# === Copyright
#
# Copyright 2014 David McNicol
#

class gitlab::install (
  $download_url,
  $installer_path,
  $installer_cmd
) {

  # Download the installer file if it does not exist on the file system
  # already. This may take some time so timeout has been increased to 
  # 15 minutes.

  exec { 'gitlab-download':
    path    => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "wget ${download_url} -O ${installer_path}",
    timeout => '900',
    creates => $installer_path
  } ~>

  # Run the installer if the contents of the installer file have changed.

  exec { 'gitlab-install':
    path        => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command     => "$installer_cmd $installer_path",
    refreshonly => true
  } ~>

  # Run the post-install configuration if the installer has been run.

  exec { 'gitlab-postinstall':
    path        => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command     => "gitlab-ctl reconfigure",
    refreshonly => true
  }
}
