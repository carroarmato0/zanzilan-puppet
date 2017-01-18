define profile_squid::exclude (
  $address = $title,
) {

  if $::profile_squid::enable_ssl {
    $dport = [80,443]
  } else {
    $dport = 80
  }

  firewall {"010 exclude webtraffic from SQUID redirect for ${address}":
    chain   => 'OUTPUT',
    proto   => 'tcp',
    dport   => $dport,
    source  => $address,
    action  => 'accept',
  }

}
