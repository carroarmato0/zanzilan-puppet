class openvswitch::package {

  package { 'openvswitch':
    ensure    => $::openvswitch::package,
    provider  => 'rpm',
    source    => 'ftp://ftp.ntua.gr/pub/linux/centos/7.2.1511/virt/x86_64/ovirt-3.6/openvswitch-2.4.0-1.el7.x86_64.rpm',
  }

}
