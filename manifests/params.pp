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
  $api_url = "https://${::fqdn}/api/v3"

  $installer_file = $::osfamily ? {
    'Debian' => '/tmp/gitlab.deb',
    'RedHat' => '/tmp/gitlab.rpm'
  }

  $installer_cmd = $::osfamily ? {
    'Debian' => 'dpkg -i',
    'RedHat' => 'rpm -ihv'
  }
}
