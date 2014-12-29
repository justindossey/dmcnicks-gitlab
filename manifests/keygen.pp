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
  $homedir = "/home/${title}",
  $comment = "${name}@${::fqdn}",
  $type = 'rsa',
  $bits = '2048'
) {

  $ssh_dir = "${homedir}/.ssh"
  $file = "${ssh_dir}/id_${type}"

  file { $ssh_dir:
    ensure => 'directory',
    owner => $title,
    mode => '0600'
  } ->

  exec { "keygen-${title}":
    path    => [ "/bin", "/usr/bin" ],
    command => "ssh-keygen -t ${type} -b ${bits} -N '' -C ${comment} -f \"${file}\"",
    user    => $title,
    creates => $file
  }
}
