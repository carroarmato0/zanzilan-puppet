class profile_graphite (
  $secret_key,
  $timezone         = 'Europe/Brussels',
  $graphite_version = '0.9.15-1.el7',
) {

  class {'::graphite':
    gr_timezone    => $timezone,
    secret_key     => $secret_key,
    gr_pip_install => false,
    graphite_ver   => $graphite_version,
  }

  package { 'python2-pip':
    ensure => installed,
  }

}
