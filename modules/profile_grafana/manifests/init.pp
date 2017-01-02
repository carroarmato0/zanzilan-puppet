class profile_grafana (
  $interface = undef,
) {

  include ::grafana

  if $interface != undef {
    firewall{"100 accept Grafana from ${interface}":
      proto   => 'tcp',
      dport   => '3000',
      iniface => $interface,
      action  => 'accept',
    }
  } else {
    firewall{'100 accept Grafana':
      proto   => 'tcp',
      dport   => '3000',
      action  => 'accept',
    }
  }

}
