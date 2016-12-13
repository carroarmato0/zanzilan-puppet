class profile_router (
  $wan_interface = $::interfaces[0],
  $natted_lans = {},
) {

  sysctl::value {"net.ipv4.ip_forward": value => "1"}

  firewall{"888 forward anything":
    proto  => 'all',
    chain  => 'FORWARD',
    action => 'accept',
  }

  create_resources('profile_router::natted_lan', $natted_lans)

}
