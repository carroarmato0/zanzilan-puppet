class profile_base::packages {

  $default_package_list = [
    'htop',
    'nano',
    'vim-minimal',
    'tcpdump',
    'dhcping',
  ]

  package { $default_package_list:
    ensure  => installed,
    require => Class['epel']
  }

}
