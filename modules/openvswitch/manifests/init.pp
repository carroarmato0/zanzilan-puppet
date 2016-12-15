class openvswitch (
  $service = 'running',
  $package = 'installed',
) {

  include openvswitch::package
  include openvswitch::service

}
