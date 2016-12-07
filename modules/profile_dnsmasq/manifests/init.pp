class profile_dnsmasq (
  $domain,
  $upstream_dns_servers,
  $lans = {},
) {

  include ::dnsmasq

  dnsmasq::conf { 'general_options':
    ensure  => present,
    content => template('profile_dnsmasq/dnsmasq.general.conf.erb'),
  }

  create_resources('profile_dnsmasq::lan', $lans)

}
