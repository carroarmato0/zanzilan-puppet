class roles::gateway {

  include profile_base
  include profile_router
  include profile_dnsmasq

  Class['profile_router']->Class['profile_dnsmasq']

}
