class openvswitch::service {

  service {'openvswitch':
    ensure  => $::openvswitch::service,
    require => Package['openvswitch'],
  }

}
