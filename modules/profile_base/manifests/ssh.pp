class profile_base::ssh (
  $restrict_to_interface = undef,
) {

  class { 'ssh::server':
    storeconfigs_enabled => false,
    options => {
      'PermitRootLogin'        => 'no',
      'Port'                   => [22, 2222],
    },
  }

  if $restrict_to_interface {
    firewall { "006 accept SSH from ${restrict_to_interface}":
      dport    => [22,2222],
      proto    => tcp,
      iniface  => $restrict_to_interface,
      action   => accept,
    }
  } else {
    firewall { '006 accept SSH':
      dport    => [22,2222],
      proto    => tcp,
      action   => accept,
    }
  }

}
