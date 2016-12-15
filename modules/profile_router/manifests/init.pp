class profile_router (
  $wan_interface = $::interfaces[0],
  $natted_lans = {},
  $bridges = {},
) {

  sysctl::value {"net.ipv4.ip_forward": value => "1"}

  firewall{"888 forward anything":
    proto  => 'all',
    chain  => 'FORWARD',
    action => 'accept',
  }

  include ::openvswitch
  create_resources('openvswitch::bridge', $bridges)

  create_resources('profile_router::natted_lan', $natted_lans)

}
