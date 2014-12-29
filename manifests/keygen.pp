# == Class: gitlab::keygen
#
# Generates a public/private key pair for a user.
#
# === Parameters
#
# [*homedir*]
#   The home directory of the user (if not the default /home/user).
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#
# === Copyright
#
# Copyright 2014 David McNicol
#

define gitlab::keygen (
  $homedir = "/home/${name}",
  $comment = "${name}@${::fqdn}",
  $type = 'rsa',
  $bits = '2048'
) {

  $ssh_dir = "${homedir}/.ssh"
  $file = "${ssh_dir}/id_${type}"

  file { $ssh_dir:
    ensure => 'directory',
    owner => ${name},
    mode => '0600'
  } ->

  exec { "keygen-${name}":
    path    => [ "/bin", "/usr/bin" ],
    command => "ssh-keygen -t ${type} -b ${bits} -N '' -C ${comment} -f \"${file}\"",
    user    => ${name},
    creates => $file
  }
}


  # Get the root user's public key.

  $pubkey = gitlab_get_pubkey('root')

  # Fix the default password.

  gitlab_user_password { $api_login:
    password     => $api_password,
    api_login    => $api_login,
    api_password => $default_password,
    api_url      => $api_url
  } ->

  # Associate the root user public key with the Gitlab admin user.

  gitlab_user_key { 'admin-pubkey':
    ensure       => 'present',
    username     => 'root',
    key          => $pubkey,
    api_login    => $api_login,
    api_password => $default_password,
    api_url      => $api_url
  }
}
