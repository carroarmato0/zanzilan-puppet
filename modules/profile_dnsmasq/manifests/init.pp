class profile_dnsmasq (
  $domain,
  $upstream_dns_servers,
  $lans = {},
) {

  include ::dnsmasq

  dnsmasq::conf { 'general_options':
    ensure  => present,
    content => template('profile_dnsmasq/dnsmasq.general.conf.erb'),
  }

  firewallchain { 'DNS:filter:IPv4':
    ensure => present,
    before => undef,
  }

  firewall {'053 jump to DNS TCP chain':
    proto       => 'tcp',
    dport       => '53',
    jump        => 'DNS',
  }
  firewall {'053 jump to DNS UDP chain':
    proto       => 'udp',
    dport       => '53',
    jump        => 'DNS',
  }

  firewallchain { 'NTP:filter:IPv4':
    ensure  => present,
    before  => undef,
  }

  firewall {'053 jump to NTP UDP chain':
    proto => 'udp',
    dport => '123',
    jump  => 'NTP',
  }

  firewallchain { 'DHCP:filter:IPv4':
    ensure  => present,
    before  => undef,
  }

  firewall {'067 jump to DHCP UDP chain':
    proto => 'udp',
    dport => ['67','68'],
    sport => ['67','68'],
    jump  => 'DHCP',
  }

  create_resources('profile_dnsmasq::lan', $lans)

}
