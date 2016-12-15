class openvswitch (
  $service      = 'running',
  $package      = 'installed',
  $manage_repo  = true,
) {

  include openvswitch::package
  include openvswitch::service

}
