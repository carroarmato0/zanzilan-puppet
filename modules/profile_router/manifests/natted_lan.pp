define profile_router::natted_lan (
  $network,
) {

  firewall{ "201 MASQUERADE outgoing traffic for ${title}":
    jump     => 'MASQUERADE',
    chain    => 'POSTROUTING',
    table    => 'nat',
    outiface => $::profile_router::wan_interface,
    proto    => 'all',
    source   => $network,
  }

}
