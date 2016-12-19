class profile_lxc (
  $containers   = {},
  $enable_ovs   = true,
  $bridge       = 'br0',
) {

  class {'lxc':
    enable_ovs   => $enable_ovs,
    bridge       => $bridge,
  }

  create_resources('::lxc::container', $containers)
}
