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
  $homedir = "/home/${title}",
  $comment = "${title}@${::fqdn}",
  $type = 'rsa',
  $bits = '2048'
) {

  $ssh_dir = "${homedir}/.ssh"

  file { $ssh_dir:
    ensure => 'directory',
    owner  => $title,
    mode   => '0600'
  }

  # I have no idea why the file has to be quoted like it is. If I change
  # the quotes to single quotes or leave them out, ssh-keygen prompts for a
  # file location when the exec runs. 

  $args = "-t ${type} -b ${bits} -N '' -C ${comment}"
  $file = "${ssh_dir}/id_${type}"

  exec { "keygen-${title}":
    path    => [ '/bin', '/usr/bin' ],
    command => "ssh-keygen ${args} -f \"${file}\"",
    user    => $title,
    creates => $file,
    require => File[$ssh_dir]
  }
}
