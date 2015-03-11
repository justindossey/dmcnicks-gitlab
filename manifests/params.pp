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

  $installer_file = $::operatingsystem ? {
    'Debian' => "gitlab-debian${::operatingsystemmajrelease}.deb",
    'Ubuntu' => "gitlab-ubuntu${::operatingsystemmajrelease}.deb",
    'CentOS' => "gitlab-centos${::operatingsystemmajrelease}.rpm",
    'RedHat' => "gitlab-centos${::operatingsystemmajrelease}.rpm"
  }

  $installer_cmd = $::osfamily ? {
    'Debian' => 'dpkg -i',
    'RedHat' => 'rpm -ihv'
  }

  $base = 'https://downloads-packages.s3.amazonaws.com'
  $major = '7.6.2'
  $minor = 'omnibus.5.3.0.ci.1-1'

  $download_url = $::osfamily ? {
    'Debian' => $::operatingsystem ? {
      'Debian' => $::lsbmajdistrelease ? {
        '7' => "${base}/debian-7.7/gitlab_${major}-${minor}_amd64.deb"
      },
      'Ubuntu' => $::lsbmajdistrelease ? {
        '12' => "${base}/ubuntu-12.04/gitlab_${major}-${minor}_amd64.deb",
        '14' => "${base}/ubuntu-14.04/gitlab_${major}-${minor}_amd64.deb"
      }
    },
    'RedHat' => $::operatingsystemmajrelease ? {
      '6' => "${base}/centos-6.6/gitlab-${major}_${minor}.el6.x86_64.rpm",
      '7' => "${base}/centos-7.0.1406/gitlab-${major}_${minor}.el7.x86_64.rpm"
    }
  }
}
