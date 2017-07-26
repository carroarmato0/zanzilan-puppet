class profile_graphite (
  $secret_key,
  $timezone         = 'Europe/Brussels',
) {

  class {'::graphite':
    gr_timezone     => $timezone,
    secret_key      => $secret_key,
    gr_pip_install  => true,
  }

  package { 'python2-pip':
    ensure => installed,
  }

}
