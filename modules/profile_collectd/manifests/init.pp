class profile_collectd (
  $graphite_host  = 'localhost',
  $graphite_proto = 'tcp',
) {

  include ::collectd

  collectd::plugin::write_graphite::carbon {'graphite_connector':
    graphitehost   => $graphite_host,
    graphiteport   => 2003,
    graphiteprefix => '',
    protocol       => $graphite_proto,
  }

  file { '/etc/systemd/system/collectd.service':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/profile_collectd/collectd.service',
    notify  => Exec['Reload systemd for collectd changes'],
    require => Package['collectd'],
  }

  exec { 'Reload systemd for collectd changes':
    command     => 'systemctl daemon-reload',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    refreshonly => true,
    notify      => Service['collectd'],
  }

  if ! $::is_virtual {
    include ::collectd::plugin::disk
  }

}
