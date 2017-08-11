class profile_router (
  $wan_interfaces = [ pick(split($::interfaces, ',')) ],
  $bridges = {},
  $bonds = {},
  $restrict_forwarding = false,
  $input_rules = {},
  $forwarding_rules = {},
  $output_rules = {},
  $ping_hosts = [
    'google-public-dns-a.google.com',
    'google-public-dns-b.google.com',
  ],
  $routing_rules = {},
) {

  include ::openvswitch

  class {'::collectd::plugin::ping':
    hosts => $ping_hosts,
  }

  sysctl::value {'net.ipv4.ip_forward': value => '1'}

  if $restrict_forwarding {
    firewall{'999 drop all':
      proto  => 'all',
      chain  => 'FORWARD',
      action => 'drop',
      before => undef,
    }
  }

  file {"/etc/dhcp/dhclient.d/":
    ensure => directory,
  }

  each($wan_interfaces) | $index, $value | {
    network::interface{$value:
      enable_dhcp => true,
      ipv6init    => false,
      peerdns     => false,
      peerntp     => false,
    }

    $_counter = $index + 1
    $table   = "isp${_counter}"

    network::routing_table{ $value:
      table_id => $index+1,
      table    => $table,
    }

    file {"/etc/dhcp/dhclient.d/${value}.sh":
      ensure  => absent,
      mode    => '0755',
      content => template('profile_router/dhcp_wan.erb'),
    }
  }

  $wan_defaults = {
    enable_dhcp     => true,
    ipv6init        => false,
    peerdns         => false,
    peerntp         => false,
    defroute        => false,
    manage_defroute => true,
  }

  $input_defaults = {
    'chain' => 'INPUT',
  }

  $forwarding_defaults = {
    'chain' => 'FORWARD',
  }

  $output_defaults = {
    'chain' => 'OUTPUT',
  }

  $nat_defaults = {
    jump     => 'MASQUERADE',
    chain    => 'POSTROUTING',
    table    => 'nat',
    proto    => 'all',
  }

  $nat_rules = generate_resource_hash($wan_interfaces, 'outiface', "201 MASQUERADE outgoing traffic ")

  create_resources('network::rule', $routing_rules)
  create_resources('firewall', $input_rules, $input_defaults)
  create_resources('firewall', $forwarding_rules, $forwarding_defaults)
  create_resources('firewall', $output_rules, $output_defaults)
  create_resources('firewall', $nat_rules, $nat_defaults)
  create_resources('openvswitch::bridge', $bridges)
  create_resources('openvswitch::bond', $bonds)
}
