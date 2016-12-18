define openvswitch::helpers::port2bridge (
  $bridge,
  $port = $title,
) {

  exec { "Add port ${port} to ${bridge}":
    path    => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
    command => "ovs-vsctl add-port ${bridge} ${port}",
    unless  => "ovs-vsctl port-to-br ${port} | grep -c ${bridge}",
  }

  network::interface { $port:
    type        => 'OVSPort',
    devicetype  => 'ovs',
    ovs_bridge  => $bridge,
  }

}
