class profile_router (
  $wan_interface = $::interfaces[0],
  $natted_lans = {},
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
) {

  include ::openvswitch
  include ::collectd::plugin::ping

  sysctl::value {'net.ipv4.ip_forward': value => '1'}

  if $restrict_forwarding {
    firewall{'999 drop all':
      proto  => 'all',
      chain  => 'FORWARD',
      action => 'drop',
      before => undef,
    }
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

  create_resources('firewall', $input_rules, $input_defaults)
  create_resources('firewall', $forwarding_rules, $forwarding_defaults)
  create_resources('firewall', $output_rules, $output_defaults)
  create_resources('openvswitch::bridge', $bridges)
  create_resources('openvswitch::bond', $bonds)
  create_resources('profile_router::natted_lan', $natted_lans)

}
