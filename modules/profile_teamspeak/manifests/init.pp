class profile_teamspeak (
    $version             = '3.0.13.8',
    $license_file        = '',
    $allow_filetransfers = false,
) {

  $accept_filetransfers = $allow_filetransfers ? {
    true    => 'accept',
    false   => 'reject',
    default => 'reject',
  }

  class {'::teamspeak':
    version      => $version,
    arch         => 'amd64',
    license_file => $license_file,
    init         => 'systemd',
  }

  firewall {'080 accept Teamspeak Voice':
    proto   => 'udp',
    dport   => '9987',
    action  => 'accept',
  }

  firewall {'080 accept Teamspeak Server Query':
    proto   => 'tcp',
    dport   => '10011',
    action  => 'accept',
  }

  firewall {'080 accept Teamspeak Filetransfer':
    proto   => 'tcp',
    dport   => '30033',
    action  => $accept_filetransfers,
  }

}
