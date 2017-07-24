class roles::gateway {

  include profile_base
  include profile_router
  include profile_dnsmasq
  include profile_lxc
  include profile_squid
  include profile_graphite
  include profile_grafana
  include ::resolv_conf

  Class['profile_router']->
  Class['profile_dnsmasq']->
  Class['resolv_conf']->
  Class['profile_graphite']->
  Class['profile_grafana']->
  Class['profile_lxc']

}
