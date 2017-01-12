class profile_base::packages {

  $default_package_list = [
    'htop',
    'nano',
    'vim-enhanced',
    'tcpdump',
    'dhcping',
    'less',
    'bind-utils',
    'iftop',
  ]

  package { $default_package_list:
    ensure  => installed,
    require => Class['epel']
  }

}
