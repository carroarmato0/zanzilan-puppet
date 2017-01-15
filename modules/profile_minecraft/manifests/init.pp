class profile_minecraft (
  $server_port  = 25565,
  $java_memory  = 2048,
  $max_players  = 100,
  $license_key  = undef,
  $password     = 'admin',
  $server_name  = 'A Minecraft Server',
) {

  include ::java
  include profile_minecraft::install
  include profile_minecraft::service

  Class['profile_minecraft::install']->
  Class['profile_minecraft::service']

  package { 'unzip':
    ensure => installed,
  }

  firewall {'080 accept MCMyAdmin':
    proto   => 'tcp',
    dport   => '8080',
    action  => 'accept',
  }

  firewall {'080 accept Minecraft':
    proto   => 'tcp',
    dport   => $server_port,
    action  => 'accept',
  }

}
