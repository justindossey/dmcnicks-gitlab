# == Class: gitlab::config
#
# Configures Gitlab.
#
# === Parameters
#
# [*gitlab_url*]
#   The URL of Gitlab.
#
# [*default_password*]
#   The default password for the admin user set by the installer.
#
# [*api_login*]
#   The admin user used to access the Gitlab API.
#
# [*api_password*]
#   The password for the admin user.
#
# === Authors
#
# David McNicol <david@mcnicks.org>
#
# === Copyright
#
# Copyright 2014 David McNicol
#

class gitlab::config (
  $gitlab_url,
  $default_password,
  $api_login,
  $api_password
) {

  # Work out the Gitlab API URL.

  $api_url = "${gitlab_url}/api/v3"

  # The Gitlab configuration providers require the Ruby rest-client gem. Note
  # that this package will be installed on the first puppet run. The providers
  # themselves are confined to only run once the rest-client package is
  # available. Since providers are autoloaded in the pluginsync stage this
  # means that they will not run during the first puppet run. The next time
  # the agent is calle,d the rest-client package will be available, the confine
  # will return true and the providers will run.

  package { 'rest-client':
    ensure   => 'present',
    provider => 'gem'
  }

  # Login to the Gitlab API.

  gitlab_session { 'config':
    api_url      => $api_url,
    api_login    => $api_login,
    api_password => $default_password
  }

  # Change the default Gitlab password.

  gitlab_user { 'root':
    ensure       => 'present',
    session      => 'config',
    fullname     => 'Joe Bloggs'
  }

  # Associate the root user public key with the Gitlab root user.

  gitlab_user_key { 'root public key':
    ensure       => 'present',
    session      => 'config',
    username     => 'root',
    key          => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1nj25yO+Jgm6/YQTHgEwkjJMgn5q+5vX22CQHdiO1/Dba5TKjr9w0T/SG94yi+l8qJQh/xhrwcvdiQc16V6ltfST1J3yZ0Rad+RUTD1pbWax376HzmtK7a6qZnSkAKTQ+WrQDOqtsPasOT4rLrW8DXUHbXLBTO5X6BydVcmG21sxHU4ikWL3dDI6qkzUd3b3u8EWBSMsirVEiG5hOScSZVy5mzfCGFz0hlx/9gjjbS/mjUAmIh29M6v+DnTkhzNsVeNO+DCWjgVh1nbW8GYDUD4C67seVCzVYNR/4IhLIuj208mJ/ZWZRxOUwj5fC+ApmWyMjN6v2iVxUs/HotxeZ root@agentdebian.local'
  }

  gitlab_group { 'My Group':
    ensure => 'present',
    session => 'config'
  } ->

  gitlab_project { 'My New Project':
    ensure => 'present',
    session => 'config',
    namespace => 'My Group'
  }

  gitlab_deploy_key { 'my deploy key':
    ensure       => 'present',
    session      => 'config',
    project      => 'My New Project',
    key          => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC94v1rpU/pJ1+coP0gThjMpgpvHVCMC/3YX+91SxSv3tpAVnUCi4yUNxLagA/0xQX9+WyWP3hHGo64DnangLZu/1LP8DojqczGVRioYBwpk4KiReCBEJ/m5BdtxPMTHpuh/vK4wTqylwYUgEr0CoZyQxy12wcIDv+CLZj4WiE6yZDodOTPswjidbjkEFZML/n8RFDK8Erq9RZSZZr8EpCSuLOsfMPSTVS5gk1F5X/1ZV1TguE2zVhm9N1MkIZdUn9XxwpabVBEr5B9HLLflch/8A2F+99DHXmpqodlXMaVIkM8T76AoYuZhDRbEoJy/b5nmWRC5irYy8nkgaVzZ83F root@agentdebian'
  }
}
