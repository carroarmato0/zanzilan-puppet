class profile_collectd {

  include ::collectd

  file { '/etc/systemd/system/collectd.service':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/profile_collectd/collectd.service',
    notify  => Exec['Reload systemd for collectd changes'],
  }

  exec { 'Reload systemd for collectd changes':
    command     => 'systemctl daemon-reload',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
  }

}
