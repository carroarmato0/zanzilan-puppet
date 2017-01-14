class profile_minecraft (
  $heap_size = 2048,
  $max_players = 100,
  $version = '1.11.2',
) {

  class {'minecraft':
    heap_size   => $heap_size,
    max_players => $max_players,
    source      => $version,
  }

  firewall {'080 accept Minecraft':
    proto   => 'tcp',
    dport   => 25565,
    action  => 'accept',
  }

}
