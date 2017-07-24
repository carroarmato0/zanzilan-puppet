class profile_graphite (
  $secret_key,
  $timezone   = 'Europe/Brussels',
) {

  class {'::graphite':
    gr_timezone    => $timezone,
    secret_key     => $secret_key,
    gr_pip_install => false,
  }

  package { 'python2-pip':
    ensure => installed,
  }

}
