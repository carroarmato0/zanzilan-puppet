class openvswitch::package {

  if $::openvswitch::manage_repo {

    yumrepo { 'centos-ovirt40-release':
      baseurl => 'http://mirror.centos.org/centos/7/virt/$basearch/ovirt-4.0/',
      descr => 'CentOS-7 - oVirt 4.0',
      enabled => '1',
      gpgcheck => '0',
    }

    package { 'openvswitch':
      ensure  => $::openvswitch::package,
      require => Yumrepo['centos-ovirt40-release'],
    }

  } else {

    package { 'openvswitch':
      ensure    => $::openvswitch::package,
      provider  => 'rpm',
      source    => 'ftp://ftp.ntua.gr/pub/linux/centos/7.2.1511/virt/x86_64/ovirt-3.6/openvswitch-2.4.0-1.el7.x86_64.rpm',
    }

  }
}
