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

  $worker_processes = 1

  $api_login = 'root'
  $api_password = '5iveL!fe'

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

  # Make a guess at the download URL.

  $download_url = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Debian' => $::lsbmajdistrelease ? {
        '7' => 'https://downloads-packages.s3.amazonaws.com/debian-7.7/gitlab_7.6.1-omnibus.5.3.0.ci.1-1_amd64.deb'
      },
      'Ubuntu' => $::lsbmajdistrelease ? {
        '12' => 'https://downloads-packages.s3.amazonaws.com/ubuntu-12.04/gitlab_7.6.1-omnibus.5.3.0.ci.1-1_amd64.deb',
        '14' => 'https://downloads-packages.s3.amazonaws.com/ubuntu-14.04/gitlab_7.6.1-omnibus.5.3.0.ci.1-1_amd64.deb'
      }
    },
    'RedHat' => $::operatingsystemmajrelease ? {
      '6' => 'https://downloads-packages.s3.amazonaws.com/centos-6.6/gitlab-7.6.1_omnibus.5.3.0.ci.1-1.el6.x86_64.rpm',
      '7' => 'https://downloads-packages.s3.amazonaws.com/centos-7.0.1406/gitlab-7.6.1_omnibus.5.3.0.ci.1-1.el7.x86_64.rpm'
    }
  }
}
