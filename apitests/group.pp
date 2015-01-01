$api_url = hiera('api_url')
$api_login = hiera('api_login')
$api_password = hiera('api_password')

gitlab_session { 'config':
  url          => $api_url,
  login        => $api_login,
  password     => $api_password
}

gitlab_group { 'My Group':
  ensure   => 'present',
  session  => 'config',
  #  owner    => 'foobar'
}
