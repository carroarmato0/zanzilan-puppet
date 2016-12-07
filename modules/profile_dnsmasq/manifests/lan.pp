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

}
