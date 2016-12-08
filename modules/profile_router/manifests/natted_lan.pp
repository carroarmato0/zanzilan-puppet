define profile_router::natted_lan (
  $network,
) {

  $default_firewall_rules = {
    jump     => 'SNAT',
    chain    => 'POSTROUTING',
    table    => 'nat',
    outiface => $wan_interface,
    proto    => 'all',
    tosource => $wan_address,
  }

  firewall{ "201 SNAT outgoing traffic for ${title}":
    jump     => 'SNAT',
    chain    => 'POSTROUTING',
    table    => 'nat',
    outiface => $::profile_router::wan_interface,
    proto    => 'all',
    source   => $network,
    tosource => $::profile_router::wan_address,
  }

}
