# == Class: gitlab::keygen
#
# Generates a public/private key pair for a user.
#
# === Parameters
#
# [*homedir*]
#   The home directory of the user (if not the default /home/user).
#
# [*comment*]
#   The comment added to the end of the public key.
#
# [*type*]
#   The type of key (rsa or dsa).
#
# [*bits*]
#   The length of the key.
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
  $args = "-t ${type} -b ${bits} -N '' -C ${comment} -f \"${file}\""

  file { $ssh_dir:
    ensure => 'directory',
    owner  => $title,
    mode   => '0600'
  }

  exec { "keygen-${name}":
    path    => [ '/bin', '/usr/bin' ],
    command => "ssh-keygen ${gitlab::keygen::args}",
    user    => $title,
    creates => $file,
    require => File[$ssh_dir]
  }
}
