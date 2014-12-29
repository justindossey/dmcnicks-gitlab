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
# [*installer_file*]
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
  $installer_file,
  $installer_cmd
) {

  file { $installer_file:
    ensure => 'present',
    source => $download_url
  } ~>

  exec { 'gitlab-install':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "$installer_cmd $installer_file",
  } ~>

  exec { 'gitlab-postinstall':
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
    command => "gitlab-ctl reconfigure"
  }
}
