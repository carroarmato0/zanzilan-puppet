define profile_dnsmasq::static_ip (
  $ip,
  $hwaddr,
) {

  concat::fragment{ "dnsmasq_static_address ${title}":
    target  => '/etc/ethers',
    content => "# ${title}\n${hwaddr} ${ip}\n",
    order   => '01',
    notify  => Service[$::dnsmasq::params::service_name],
  }

}
