class profile_squid::delay_pool (
  $delay_initial_bucket_level = 50,
  $pools = {},
) {

  validate_integer($delay_initial_bucket_level)
  validate_hash($pools)

  squid::extra_config_section {'Include Delay Pools File':
    order          => '70',
    config_entries => {
      'include'   => "/etc/${::squid::package_name}/delay_pools",
    }
  }

  file { "/etc/${::squid::package_name}/delay_pools":
    ensure  => file,
    mode    => '0644',
    owner   => $::squid::config_user,
    group   => $::squid::config_group,
    content => template('profile_squid/delay_pool.erb'),
    notify  => Service[$::squid::service_name],
  }

}
