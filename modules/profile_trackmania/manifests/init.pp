class profile_trackmania {

  class {'::php::globals':
    php_version  => '5.6',
  }->
  class { '::php':
    manage_repos => true,
  }

  package {'at':
    ensure  => installed,
  }

  service {'atd':
    ensure  => running,
    enable  => true,
    require => Package['at'],
  }

  firewall {'080 accept Trackmania':
    dport   => 2350,
    action  => 'accept',
  }

}
