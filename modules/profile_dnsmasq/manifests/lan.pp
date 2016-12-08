define profile_dnsmasq::lan (
  $domain,
  $dhcp_range,
  $dns_servers,
  $ntp_servers,
  $gw_ipaddress,
  $interface = $::interfaces[0],
  $dhcp_lease = '24h',
) {

  dnsmasq::conf { $title:
    ensure  => present,
    prio    => 20,
    content => template('profile_dnsmasq/dnsmasq.lan.conf.erb'),
  }

  firewall {"053 accept DNS on ${title} interface over UDP":
    proto   => 'udp',
    dport   => '53',
    iniface => $interface,
    action  => 'accept',
  }
  firewall {"053 accept DNS on ${title} interface over TCP":
    proto   => 'tcp',
    dport   => '53',
    iniface => $interface,
    action  => 'accept',
  }
  firewall {"067 accept DHCP request on ${title} interface":
    proto   => 'udp',
    dport   => ['67','68'],
    sport   => ['67','68'],
    iniface => $interface,
    action  => 'accept',
  }

}
