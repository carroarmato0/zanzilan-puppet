class profile_router (
  $wan_interface = $::interfaces[0],
  $natted_lans = {},
  $bridges = {},
  $restrict_forwarding = false,
  $forwarding_rules = {},
) {

  include ::openvswitch

  sysctl::value {"net.ipv4.ip_forward": value => "1"}

  if $restrict_forwarding {
    firewall{'999 drop all':
      proto  => 'all',
      chain  => 'FORWARD',
      action => 'drop',
      before => undef,
    }
  }

  $forwarding_defaults = {
    'chain' => 'FORWARD',
  }

  create_resources('firewall', $forwarding_rules, $forwarding_defaults)
  create_resources('openvswitch::bridge', $bridges)
  create_resources('profile_router::natted_lan', $natted_lans)

}
