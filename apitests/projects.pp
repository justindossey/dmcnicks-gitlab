$api_url = hiera('api_url')
$api_login = hiera('api_login')
$api_password = hiera('api_password')

gitlab_session { 'config':
  url               => $api_url,
  login             => $api_login,
  password          => $api_password
}

gitlab_project { 'Simple Project':
  ensure => 'present',
  session => 'config'
}

gitlab_project { 'Owned Project':
  ensure => 'present',
  session => 'config',
  owner => 'foobar'
}

gitlab_project { 'Group Project':
  ensure => 'present',
  session => 'config',
  owner => 'My Group'
}
