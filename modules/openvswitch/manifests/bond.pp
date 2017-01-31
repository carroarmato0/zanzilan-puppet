define openvswitch::bond (
  $bridge,
  $ensure     = 'present',
  $bond       = $title,
  $mode       = 'active-backup',
  $lacp       = 'off',
  $ports      = [],
) {

  # Validate
  if size($ports) < 2 {
    fail('Two interfaces minimum are required for defining a bond')
  }

  validate_re($lacp, ['^off$', '^active$', '^passive$'])
  validate_re($mode, ['^balance-tcp$', '^balance-slb$', '^active-backup$'])

  $port_string = join($ports, ' ')

  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
  }

  if $ensure == 'present' {
    exec { "Create bond ${bond} on ${bridge}":
      command => "ovs-vsctl add-bond ${bridge} ${bond} ${port_string}",
      unless  => "ovs-vsctl port-to-br ${bond} | grep -c ${bridge}",
      require => Service['openvswitch'],
    }

    exec { "Set Bond mode for ${bond}":
      command => "ovs-vsctl set port ${bond} bond_mode=${mode}",
      unless  => "ovs-vsctl list port ${bond} | grep bond_mode | grep -c ${mode}",
      require => Service['openvswitch'],
    }

    if $lacp and $mode != 'balance-tcp' {
      exec { "Set LACP on ${bond}":
        command => "ovs-vsctl set port ${bond} lacp=${lacp}",
        unless  => "ovs-vsctl list port ${bond} | grep lacp | grep -c ${lacp}",
        require => Service['openvswitch'],
      }
    }


  } else {
    # Code for handling removal
  }

}
