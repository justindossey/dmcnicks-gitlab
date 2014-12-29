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

  $ssl = false

  $worker_processes = 2

  $api_login = 'root'
  $default_password = '5iveL!fe'

  $installer_dir = '/srv'

  $installer_file = $::operatingsystem ? {
    'Debian' => "gitlab-debian${::operatingsystemmajrelease}.deb",
    'Ubuntu' => "gitlab-ubuntu${::operatingsystemmajrelease}.deb",
    'CentOS' => "gitlab-centos${::operatingsystemmajrelease}.rpm"
  }

  $installer_cmd = $::osfamily ? {
    'Debian' => 'dpkg -i',
    'RedHat' => 'rpm -ihv'
  }
}
