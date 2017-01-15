class profile_minecraft::install {

  group { 'minecraft':
    ensure     => present,
  }

  user { 'minecraft':
    ensure     => present,
    gid        => 'minecraft',
    home       => '/opt/minecraft',
    managehome => true,
    require    => Group['minecraft'],
  }

  file { '/opt/minecraft':
    ensure  => directory,
    owner   => 'minecraft',
    group   => 'minecraft',
    require => User['minecraft'],
  }

  file { '/opt/minecraft/McMyAdmin':
    ensure  => directory,
    owner   => 'minecraft',
    group   => 'minecraft',
    require => User['minecraft'],
  }

  staging::file { 'mcmyadmin_etc.zip':
    source => 'http://mcmyadmin.com/Downloads/etc.zip',
  }->
  staging::extract { 'mcmyadmin_etc.zip':
    target  => '/usr/local',
    user    => 'root',
    group   => '0',
    creates => '/usr/local/etc/mono',
  }

  staging::file { 'mcmyadmin.zip':
    source => 'http://mcmyadmin.com/Downloads/MCMA2_glibc26_2.zip',
  }->
  staging::extract { 'mcmyadmin.zip':
    target  => '/opt/minecraft/McMyAdmin/',
    user    => 'minecraft',
    group   => 'minecraft',
    creates => '/opt/minecraft/McMyAdmin/MCMA2_Linux_x86_64',
    require => [File['/opt/minecraft/McMyAdmin'], Staging::Extract['mcmyadmin_etc.zip']],
  }~>
  exec { 'Install McMyAdmin':
    command     => "/opt/minecraft/McMyAdmin/MCMA2_Linux_x86_64 -nojavatest -nonotice -setpass ${::profile_minecraft::password} -configonly",
    user        => 'minecraft',
    refreshonly => true,
    logoutput   => true,
    cwd         => '/opt/minecraft/McMyAdmin',
    require     => User['minecraft'],
  }

}
