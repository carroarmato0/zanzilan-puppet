class profile_grafana (
  $restrict_to_network = '',
  $grafana_user = 'admin',
  $grafana_password = 'admin',
  $version = '4.4.1',
  $iteration = '1',
  $cfg = {},
) {

  $cfg_defaults = {
    'app_mode' => 'production',
    'security' => {
      'admin_user'      => $grafana_user,
      'admin_password'  => $grafana_password,
    },
  }

  $cfg_merged_hash = deep_merge($cfg, $cfg_defaults)

  class {'::grafana':
    install_method  => 'repo',
    cfg             => $cfg_merged_hash,
    version         => $version,
    rpm_iteration   => $iteration,
  }

  # grafana_datasource {'influxdb':
  #   grafana_url       => 'http://localhost:3000',
  #   grafana_user      => $grafana_user,
  #   grafana_password  => $grafana_password,
  #   type              => 'influxdb',
  #   url               => 'http://localhost:8086',
  #   user              => 'admin',
  #   password          => '1nFlux5ecret',
  #   database          => 'collectd',
  #   access_mode       => 'proxy',
  #   is_default        => true,
  # }

  if !empty($restrict_to_network) {
    firewall{"100 accept Grafana from ${restrict_to_network}":
      proto   => 'tcp',
      dport   => '3000',
      source  => $restrict_to_network,
      action  => 'accept',
    }
  } else {
    firewall{"100 accept Grafana":
      proto   => 'tcp',
      dport   => '3000',
      action  => 'accept',
    }
  }

}
