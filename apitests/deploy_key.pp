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

gitlab_deploy_key {'sp-deploy-key':
  ensure => 'absent',
  session => 'config',
  project => 'Simple Project',
  key => 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlYuqucNkStRcUiI8LgnN7FpGD3/fk+3BCLprThBV4vICcVvEhIJpNSh74fTm5lP3zm2HpFwCIML9nDKcR4bDHQDJQXleS3T+P7qPxksj/EqSrJ3gC3EjKQyLgqIo0uLkKsd2MSwqGAhUx2DBmriVGugMRiqgGO/unoD9sibDVbgLGyrNF0jj4/J28+/hGtxZvO5fx4RukmxpZkhgKUEebssq+/3AyM5x8FXSwZAg/wrKKnWpNL/VBerUQFYaLYrgSrlooQ8kv1S6g8bxjMozHBQeh4E5z2lFSTYGFqsjQtBVLSJ/wFljHsSomJljzmtWzywgrJ2M8RKy4L+9WB6qT mcnicks@McNicks-MBA.home'
}
