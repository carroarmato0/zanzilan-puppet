class roles::gateway {

  include profile_base
  include profile_router
  include profile_dnsmasq
  include profile_squid
  include ::resolv_conf

  Class['profile_router']->
  Class['profile_dnsmasq']->
  Class['resolv_conf']->
  Class['profile_squid']

}
