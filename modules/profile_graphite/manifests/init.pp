class profile_graphite (
  $secret_key,
  $timezone            = 'Europe/Brussels',
  $restrict_to_network = '',
) {

  class {'::graphite':
    gr_timezone               => $timezone,
    secret_key                => $secret_key,
    gr_pip_install            => true,
    gr_manage_python_packages => false,
    gr_web_server             => 'nginx',
    gr_storage_schemas        => [
      {
        name       => 'carbon',
        pattern    => '^carbon\.',
        retentions => '1m:90d'
      },
      {
        name       => 'default',
        pattern    => '.*',
        retentions => '10s:3d,60s:7d,300s:30d,600s:356d'
      }
    ],
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

  if !empty($restrict_to_network) {
    firewall{"80 accept Graphite Web":
      proto   => 'tcp',
      dport   => '80',
      source  => $restrict_to_network,
      action  => 'accept',
    }
  } else {
    firewall{"80 accept Graphite Web":
      proto   => 'tcp',
      dport   => '80',
      action  => 'accept',
    }
  }

  firewall{"80 accept Carbon TCP":
    proto   => 'tcp',
    dport   => '2003',
    action  => 'accept',
  }

  firewall{"80 accept Carbon UDP":
    proto   => 'udp',
    dport   => '2003',
    action  => 'accept',
  }

}
