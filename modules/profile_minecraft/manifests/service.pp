class profile_minecraft::service {

  file {'/etc/systemd/system/mcmyadmin.service':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    content => template('profile_minecraft/mcmyadmin.service.erb'),
    notify  => [Exec['Reload McMyadmin service file'], Service['mcmyadmin']],
  }

  exec { 'Reload McMyadmin service file':
    command     => 'systemctl daemon-reload',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    before      => Service['mcmyadmin'],
    refreshonly => true,
  }

  service { 'mcmyadmin':
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/mcmyadmin.service'],
  }

}
