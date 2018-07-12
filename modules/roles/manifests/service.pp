class roles::service {

  include profile_base
  include profile_router
  include profile_lxc
  include ::resolv_conf

  Class['profile_router']->
  Class['resolv_conf']

}
