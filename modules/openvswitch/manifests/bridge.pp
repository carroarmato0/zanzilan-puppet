define openvswitch::bridge (
  $ensure         = 'present',
  $bridge         = $title,
  $parent_bridge  = undef,
  $vlan           = undef,
  $network_config = {},
  $ports          = [],
) {

  if $ensure == 'present' {
    if $parent_bridge == undef {
      exec { "Create bridge ${bridge}":
        path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
        command => "ovs-vsctl add-br ${bridge}",
        unless  => "ovs-vsctl br-exists ${bridge}",
        require => Service['openvswitch'],
      }
    } else {
      exec { "Create bridge ${bridge}":
        path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
        command => "ovs-vsctl add-br ${bridge} ${parent_bridge} ${vlan}",
        unless  => "ovs-vsctl br-exists ${bridge}",
        require => [Exec["Create bridge ${parent_bridge}"], Service['openvswitch']],
      }
    }

    $nw_config_defaults = {
      family    => 'inet',
      method    => 'static',
      netmask   => '255.255.255.0',
      onboot    => 'true',
    }

    create_resources('network_config', $network_config, $nw_config_defaults)

    $ports_hash = generate_resource_hash($ports, 'port', '')
    $defaults = {
      'bridge' => $bridge,
      require  => [Exec["Create bridge ${bridge}"], Service['openvswitch']],
    }
    create_resources('openvswitch::helpers::port2bridge', $ports_hash, $defaults)
  } else {
    exec { "Delete bridge ${bridge}":
      path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
      command => "ovs-vsctl del-br ${bridge}",
      onlyif  => "ovs-vsctl br-exists ${bridge}",
      require => Service['openvswitch'],
    }
  }

}
