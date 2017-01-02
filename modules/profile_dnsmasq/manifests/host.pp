define profile_dnsmasq::host (
  $ip,
  $aliases = '' ,
) {

  concat::fragment{ "dnsmasq_address ${title}":
    target  => '/etc/hosts.dnsmasq',
    content => "${ip} ${aliases} ${title}\n",
    order   => '01',
    notify  => Class['dnsmasq::service'],
  }

}
