$api_url = hiera('api_url')
$api_login = hiera('api_login')
$api_password = hiera('api_password')

gitlab_session { 'config':
  url      => $api_url,
  login    => $api_login,
  password => $api_password
}

gitlab_user { 'foobar':
  ensure   => 'present',
  session  => 'config',
  email    => 'david@mcnicks.org',
  fullname => 'Foo Bar',
  password => 'fAoobaar'
}

gitlab_user_key { 'foobar-key':
  ensure => 'present',
  session => 'config',
  username => 'foobar',
  key => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDH4OK90z8IUCMtZr/UEyyy9R1wOt/v3mJZfk/u5lHjSUUh7qsvCaRaeURIXZFUbevljJT4xMt0cWY+j206jQU/gdc9tsUF7p0nUKLNDfVVAM0ZMrWQylQgRbO95J0bY8YMitKNO5haArxNPz62bXWV2q/Yy+a+GvxBw3G/jgjwp7ri4ydrk+/UXTq/4dLlkP0xOw/xNRnCrFoTrbvsh1LTJJWqdzX/Tby6hnyIUyR1iZEcKLGbouUosT6VhDnkN1SMfaWw7i+dxr10Pwfyis5+ZUxi9O5wOAXajJEHBnpnAU4LFESaGi5n40fyLMC5uOC0on1wlxMyb+R+7RsATTRH mcnicks@McNicks-MBA.home'
}
