class profile_teamspeak (
    $version      = '3.0.13.8',
    $license_file = '',
) {

  class {'::teamspeak':
    version      => $version,
    arch         => 'amd64',
    license_file => $license_file,
    init         => 'systemd',
  }

}
