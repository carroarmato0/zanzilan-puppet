class profile_share (
  $workgroup,
  $server_string,
  $interfaces = 'eth0 lo',
  $bind_interfaces_only = false,
  $security = 'share',
  $shares = {},
  $users = {},
) {

  class {'samba::server':
    workgroup             => $workgroup,
    server_string         => $server_string,
    interfaces            => $interfaces,
    security              => $share,
    bind_interfaces_only  => $bind_interfaces_only,
  }

  file { '/srv/shares/':
    ensure => directory,
    mode => '0644',
  }

  create_resources('profile_share::share', $shares, {})
  create_resources('samba::server::user', $users, {})

  user { 'crew':
    comment => 'Crew User',
    home => '/home/crew',
    ensure => present,
    shell => '/bin/false',
  }

  firewall{'400 accept NETBIOS Name Service':
    proto   => 'tcp',
    dport   => 137,
    action  => 'accept',
  }

  firewall{'400 accept NETBIOS Datagram Service':
    proto   => 'tcp',
    dport   => 138,
    action  => 'accept',
  }

  firewall{'400 accept NETBIOS session service':
    proto   => 'tcp',
    dport   => 139,
    action  => 'accept',
  }

  firewall{'400 accept NetBIOS CIFS':
    proto   => 'tcp',
    dport   => 445,
    action  => 'accept',
  }

}
