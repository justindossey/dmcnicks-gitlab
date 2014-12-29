# == Class: gitlab::params
#
# Parameters for gitlab module.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#
# === Copyright
#
# Copyright 2014 David McNicol
#

class gitlab::params () {

  $default_password = '5iveL!fe'
  $api_login = 'root'
  $api_url = "http://${::fqdn}/api/v3"

  $installer_file = $::operatingsystem ? {
    'Debian' => "/tmp/gitlab-debian${::operatingsystemmajrelease}.deb",
    'Ubuntu' => "/tmp/gitlab-ubuntu${::operatingsystemmajrelease}.deb",
    'CentOS' => "/tmp/gitlab-centos${::operatingsystemmajrelease}.rpm"
  }

  $installer_cmd = $::osfamily ? {
    'Debian' => 'dpkg -i',
    'RedHat' => 'rpm -ihv'
  }
}
