define profile_dnsmasq::lan (
  $domain,
  $dhcp_range,
  $dns_servers,
  $ntp_servers,
  $gw_ipaddress,
  $interface = $::interfaces[0],
  $dhcp_lease = '24h',
  $restrict_dns = true,
  $restrict_ntp = true,
) {

  dnsmasq::conf { $title:
    ensure  => present,
    prio    => 20,
    content => template('profile_dnsmasq/dnsmasq.lan.conf.erb'),
  }

  if $restrict_dns {
    $dns_destination = $dns_servers
  } else {
    $dns_destination = ['0.0.0.0/0']
  }

  if $restrict_ntp {
    $ntp_destination = $ntp_servers
  } else {
    $ntp_destination = ['0.0.0.0/0']
  }

  $printable_dns_destination = join($dns_destination,", ")
  $printable_ntp_destination = join($ntp_destination,", ")

  $dns_udp_hash = generate_resource_hash($dns_destination, 'destination', "053 accept DNS on ${title} interface over UDP to ${printable_dns_destination} ")
  $dns_tcp_hash = generate_resource_hash($dns_destination, 'destination', "053 accept DNS on ${title} interface over TCP to ${printable_dns_destination} ")
  $ntp_udp_hash = generate_resource_hash($dns_destination, 'destination', "053 accept NTP on ${title} interface over UDP to ${printable_dns_destination} ")

  $dns_udp_defaults = {
    'proto'       => 'udp',
    'dport'       => '53',
    'iniface'     => $interface,
    'action'      => 'accept',
  }
  $dns_tcp_defaults = {
    'proto'       => 'tcp',
    'dport'       => '53',
    'iniface'     => $interface,
    'action'      => 'accept',
  }
  $ntp_udp_defaults = {
    'proto'       => 'udp',
    'dport'       => '123',
    'iniface'     => $interface,
    'action'      => 'accept',
  }
  create_resources(firewall, $dns_udp_hash, $dns_udp_defaults)
  create_resources(firewall, $dns_tcp_hash, $dns_tcp_defaults)
  create_resources(firewall, $ntp_udp_hash, $ntp_udp_defaults)

  # $dns_servers.each |String $dns_destination| {
  #   firewall {"053 accept DNS on ${title} interface over UDP to ${dns_destination}":
  #     proto       => 'udp',
  #     dport       => '53',
  #     iniface     => $interface,
  #     destination => $dns_destination,
  #     action      => 'accept',
  #   }
  #   firewall {"053 accept DNS on ${title} interface over TCP to ${dns_destination}":
  #     proto       => 'tcp',
  #     dport       => '53',
  #     iniface     => $interface,
  #     destination => $dns_destination,
  #     action      => 'accept',
  #   }

  # }

  firewall {"067 accept DHCP request on ${title} interface":
    proto   => 'udp',
    dport   => ['67','68'],
    sport   => ['67','68'],
    iniface => $interface,
    action  => 'accept',
  }

}
