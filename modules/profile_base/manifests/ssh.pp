class profile_base::ssh {

  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'PermitRootLogin'        => 'no',
      'Port'                   => [22, 2222],
    },
  }

  firewall { '006 accept SSH':
    dport    => [22,2222],
    proto    => tcp,
    action   => accept,
  }

}
