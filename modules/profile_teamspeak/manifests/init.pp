class profile_teamspeak (
    $version             = '3.0.13.8',
    $license_file        = '',
    $username            = 'serveradmin',
    $password            = '',
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

  package { 'collectd-python':
    ensure => installed,
    before => Class['collectd::plugin::python'],
  }

  class { 'collectd::plugin::python':
    modulepaths    => ['/usr/share/collectd/python'],
    modules        => {
      'collectd_ts3' => {
        'script_source' => 'puppet:///modules/profile_collectd/collectd_ts3.py',
        'config'        => [
          {
            'Host'     => '127.0.0.1',
            'Port'     => '10011',
            'Username' => "${username}",
            'Password' => "${password}",
          },
        ],
      },
    },
    logtraces      => true,
    interactive    => false,
  }

}
