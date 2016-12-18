define openvswitch::bridge (
  $ensure         = 'present',
  $bridge         = $title,
  $parent_bridge  = undef,
  $vlan           = undef,
  $ipaddress      = [],
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

      network::interface { $bridge:
        type        => 'OVSBridge',
        devicetype  => 'ovs',
      }

    } else {
      exec { "Create bridge ${bridge}":
        path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
        command => "ovs-vsctl add-br ${bridge} ${parent_bridge} ${vlan}",
        unless  => "ovs-vsctl br-exists ${bridge}",
        require => [Exec["Create bridge ${parent_bridge}"], Service['openvswitch']],
      }

      network::interface { $bridge:
        type        => 'OVSBridge',
        devicetype  => 'ovs',
        ipaddress   => $ipaddress,
        ovs_options => "${parent_bridge} ${vlan}",
      }

    }

    # $nw_config_defaults = {
    #   family    => 'inet',
    #   method    => 'static',
    #   onboot    => 'true',
    #   hotplug   => 'false',
    #   #notify    => Service['network'],
    # }
    #
    # create_resources('network_config', $network_config, $nw_config_defaults)

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
