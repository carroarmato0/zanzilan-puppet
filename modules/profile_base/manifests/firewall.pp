class profile_base::firewall {

  # Purge all Unmanaged rules
  resources { 'firewall':
    purge => true,
  }

  # Purge all Unmanaged chains
  # resources { 'firewallchain':
  #   purge => true,
  # }

  # Set load order to avoid accidental lockout
  Firewall {
    before  => Class['profile_base::firewall_post'],
    require => Class['profile_base::firewall_pre'],
  }

  # Instantiate classes with sane defaults
  class { ['profile_base::firewall_pre', 'profile_base::firewall_post']: }

  include ::firewall

}
