class profile_dnsmasq (
  $domain,
  $cache_server,
  $upstream_dns_servers,
  $addresses = {},
  $lans = {},
) {

  include ::dnsmasq

  class {'::collectd::plugin::dns':
    require => Yumrepo['collectd-ci'],
  }

  dnsmasq::conf { 'general_options':
    ensure  => present,
    content => template('profile_dnsmasq/dnsmasq.general.conf.erb'),
  }

  dnsmasq::conf { 'game_cdns':
    ensure  => present,
    content => template('profile_dnsmasq/dnsmasq.gamecache.conf.erb'),
  }

  firewallchain { 'DNS:filter:IPv4':
    ensure => present,
    before => undef,
  }

  firewall { '999 drop all DNS':
    proto  => 'all',
    action => 'drop',
    chain  => 'DNS',
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

  firewall { '999 drop all NTP':
    proto  => 'all',
    action => 'drop',
    chain  => 'NTP',
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

  firewall { '999 drop all DHCP':
    proto  => 'all',
    action => 'drop',
    chain  => 'DHCP',
  }

  firewall {'067 jump to DHCP UDP chain':
    proto => 'udp',
    dport => ['67','68'],
    sport => ['67','68'],
    jump  => 'DHCP',
  }

  create_resources('profile_dnsmasq::lan', $lans)

}
