class profile_influxdb (
  $http_log_enabled = false,
  $collectd_port = '25826',
  $restrict_to_interface = '',
) {

  class {'::influxdb::server':
    http_log_enabled => $http_log_enabled,
    collectd_options => {
      'enabled'       => 'true',
      'bind-address'  => ":${collectd_port}",
    }
  }

  if empty($restrict_to_interface) {

    firewall {'080 accept Influxdb collectd port':
      proto   => 'udp',
      dport   => $collectd_port,
      action  => 'accept',
    }

    firewall {'080 accept Influxdb webinterface':
      proto   => 'tcp',
      dport   => '8083',
      action  => 'accept',
    }

    firewall {'080 accept Influxdb api':
      proto   => 'tcp',
      dport   => '8086',
      action  => 'accept',
    }

  } else {
    firewall {"080 accept Influxdb collectd port from ${restrict_to_interface}":
      proto   => 'udp',
      dport   => $collectd_port,
      iniface => $restrict_to_interface,
      action  => 'accept',
    }

    firewall {"080 accept Influxdb webinterface from ${restrict_to_interface}":
      proto   => 'tcp',
      dport   => '8083',
      iniface => $restrict_to_interface,
      action  => 'accept',
    }

    firewall {"080 accept Influxdb api from ${restrict_to_interface}":
      proto   => 'tcp',
      dport   => '8086',
      iniface => $restrict_to_interface,
      action  => 'accept',
    }
  }

}
