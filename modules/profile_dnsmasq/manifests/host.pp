define profile_dnsmasq::host (
  $ip,
  $aliases = '' ,
) {

  concat::fragment{ "dnsmasq_address ${tile}":
    target  => '/etc/hosts.dnsmasq',
    content => "${ip} ${aliases} ${title}\n",
    order   => '01'
  }

}
