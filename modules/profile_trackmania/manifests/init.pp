class profile_trackmania {

  class {'::php::globals':
    php_version  => '5.6',
  }->
  class { '::php':
    manage_repos => true,
  }

  firewall {'080 accept Trackmania':
    proto   => 'tcp',
    dport   => 2450,
    action  => 'accept',
  }

}
