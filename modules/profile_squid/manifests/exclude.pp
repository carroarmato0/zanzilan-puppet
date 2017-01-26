define profile_squid::exclude (
  $address = $title,
) {

  if $::profile_squid::enable_ssl {
    $dport = [80,443]
  } else {
    $dport = 80
  }

  firewall {"010 exclude webtraffic from SQUID redirect from ${address}":
    chain   => 'PREROUTING',
    proto   => 'tcp',
    dport   => $dport,
    source  => $address,
    action  => 'accept',
    table   => 'nat',
  }

  firewall {"010 exclude webtraffic from SQUID redirect to ${address}":
    chain       => 'PREROUTING',
    proto       => 'tcp',
    dport       => $dport,
    destination => $address,
    action      => 'accept',
    table       => 'nat',
  }

}
