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
  $ssl
) {

  # Create a certificate if SSL is enabled.

  if str2bool($ssl) {

    $ssl_cert_dir = '/etc/gitlab/ssl'

    file { $ssl_cert_dir:
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
        base_dir     => $ssl_cert_dir,
        require      => File[$ssl_cert_dir],
        notify       => Exec['gitlab-postinstall']
    }
  }

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

  exec { 'gitlab-install':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => "${installer_cmd} ${installer_path}",
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

  # Run the post-install configuration if the installer has been run.

  exec { 'gitlab-postinstall':
    path    => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    command => 'gitlab-ctl reconfigure',
    refreshonly => true,
    require => File['/etc/gitlab/gitlab.rb']
  }
}
