$api_url = hiera('api_url')
$api_login = hiera('api_login')
$api_password = hiera('api_password')
$new_password = hiera('new_password')

gitlab_session { 'config':
  url          => $api_url,
  login        => $api_login,
  password     => $api_password,
  new_password => $new_password
}
