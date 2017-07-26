class profile_graphite (
  $secret_key,
  $timezone         = 'Europe/Brussels',
) {

  class {'::graphite':
    gr_timezone               => $timezone,
    secret_key                => $secret_key,
    gr_pip_install            => true,
    gr_manage_python_packages => false,
  }

  package { 'python2-pip':
    ensure => installed,
  }

  package { 'python-devel':
    ensure => installed,
  }

  package { 'gcc':
    ensure => installed,
  }

}
