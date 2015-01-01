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
# [*worker_processes*]
#   The number of worker processes that Gitlab should run.
#
# [*gitlab_url*]
#   The eventual URL of Gitlab.
#
# [*port*]
#   The HTTP port that Gitlab will listen on.
#
# [*ssl_port*]
#   The SSL port that Gitlab will listen on.
#
# [*ssl*]
#   True if SSL should be enabled.
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
  $installer_cmd,
  $worker_processes,
  $gitlab_url,
  $port,
  $ssl_port,
  $ssl
) {

  # Download the installer file if it does not exist on the file system
  # already. This may take some time so timeout has been increased to 
  # 15 minutes.

  exec { 'gitlab-download':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "wget ${download_url} -O ${installer_path}",
    timeout => '900',
    creates => $installer_path
  }

  # Run the installer if the contents of the installer file have changed.

  $gitlab_etc_dir = '/etc/gitlab'

  exec { 'gitlab-install':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "${installer_cmd} ${installer_path}",
    creates => $gitlab_etc_dir,
    require => Exec['gitlab-download']
  }

  # Create the gitlab.rb file.

  file { '/etc/gitlab/gitlab.rb':
    ensure  => 'present',
    content => template('gitlab/gitlab.rb.erb'),
    mode    => '0600',
    require => Exec['gitlab-install'],
    notify  => Exec['gitlab-postinstall']
  }

  # Create a certificate if SSL is enabled.

  if str2bool($ssl) {

    $gitlab_ssl_dir = "${gitlab_etc_dir}/ssl"

    file { $gitlab_ssl_dir:
      ensure  => 'directory',
      require => Exec['gitlab-install']
    }

    openssl::certificate::x509 { $::fqdn:
        ensure       => 'present',
        country      => 'UK',
        organization => 'Gitlab',
        commonname   => $::fqdn,
        days         => '3650',
        force        => false,
        cnf_tpl      => 'openssl/cert.cnf.erb',
        base_dir     => $gitlab_ssl_dir,
        require      => File[$gitlab_ssl_dir],
        notify       => Exec['gitlab-postinstall']
    }
  }
  # Run the post-install configuration if the installer has been run.

  exec { 'gitlab-postinstall':
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command     => 'gitlab-ctl reconfigure',
    refreshonly => true,
    require     => Exec['gitlab-install'],
    notify      => Exec['gitlab-restart']
  }

  # Restart after post-install. Sleep for a short while afterwards so that
  # Gitlab services are sure to be fully up before any further configuration
  # takes place.

  exec { 'gitlab-restart':
    path        => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command     => 'gitlab-ctl restart && sleep 30',
    refreshonly => true
  }

}
