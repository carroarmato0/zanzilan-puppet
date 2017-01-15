class profile_minecraft (
  $server_port    = 25565,
) {

  include ::java

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
