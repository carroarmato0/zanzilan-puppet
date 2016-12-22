class profile_lxc (
  $containers   = {},
  $enable_ovs   = true,
  $bridge       = 'br0',
) {

  class {'lxc':
    enable_ovs   => $enable_ovs,
    bridge       => $bridge,
  }

  file {'/usr/share/lxc/templates/lxc-centos-puppet':
    ensure => file,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/profile_lxc/centos-puppet',
  }

  create_resources('::lxc::container', $containers)
}
