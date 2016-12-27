class profile_squid (
  $workers                        = $::processorcount,
  $http_access                    = {},
  $acls                           = {},
  $http_port                      = '8080',
  $redirect_exclude               = [],
  $cache_mgr                      = 'root@localhost',
  # Delay Pools
  $delay_pools                    = {},
  $delay_initial_bucket_level     = 50,                   # initial bucket percentage
  # Memory cache configuration options
  $cache_mem                      = '512 MB',
  $minimum_object_size            = '4 KB',               # Should fit blocksize of partition
  $maximum_object_size_in_memory  = '2048 KB',
  # Disk cache configuration options
  $cache_dir                      = '/var/cache/squid',
  $cache_dir_space                = 30000,                #Megabytes, should always be ~10-15% smaller than total of partition
  $cache_dir_L1                   = 16,
  $cache_dir_L2                   = 256,
  # SSL configuration options
  $ssl_cert                       = undef,
  $https_port                     = '8443',
  $enable_ssl                     = false,
  $sslcrt_storage_max_size        = '4MB',
  $dynamic_cert_mem_cache_size    = '16MB',
) {

  class {'squid':
    cache_mem                     => $cache_mem,
    workers                       => $workers,
    maximum_object_size_in_memory => $maximum_object_size_in_memory,
  }

  if !empty($delay_pools) {
    class { 'profile_squid::delay_pool':
      delay_initial_bucket_level  => $delay_initial_bucket_level,
      pools                       => $delay_pools,
    }
  }

  # Squid listening port
  squid::http_port { $http_port:
    options => 'transparent',
  }
  squid::http_port { '3128': }

  if $enable_ssl {
    squid::http_port { $https_port:
      ssl     => true,
      options => "intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=${dynamic_cert_mem_cache_size} cert=/etc/${::squid::package_name}/ssl_cert/server.pem",
    }

    squid::extra_config_section {'SSL Bump - not for localhost':
      config_entries => {
        'ssl_bump' => 'none localhost',
      }
    }
    squid::extra_config_section {'SSL Bump - server-first all':
      config_entries => {
        'ssl_bump' => 'server-first all',
      }
    }
    squid::extra_config_section {'sslproxy_cert_error allow all':
      config_entries => {
        'sslproxy_cert_error' => 'allow all',
      }
    }
    squid::extra_config_section {'sslproxy_flags DONT_VERIFY_PEER':
      config_entries => {
        'sslproxy_flags' => 'DONT_VERIFY_PEER',
      }
    }

    squid::extra_config_section {'sslcrtd':
      config_entries => {
        'sslcrtd_program'   => "/usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db/ -M ${sslcrt_storage_max_size} -b ${minimum_object_size}",
        'sslcrtd_children'  => '8 startup=1 idle=1',
      }
    }

    file { '/etc/squid/ssl_cert':
      ensure        => directory,
      mode          => '0700',
      owner         => $::squid::daemon_user,
      group         => $::squid::daemon_group,
      recurse       => true,
      recurselimit  => 2,
      require       => Package[$::squid::package_name],
    }
    file { '/etc/squid/ssl_cert/server.pem':
      ensure  => file,
      mode    => '0740',
      owner   => $::squid::config_user,
      group   => $::squid::daemon_group,
      content => $ssl_cert,
      notify  => Service[$::squid::service_name],
      require => Package[$::squid::package_name],
    }

    file { '/var/lib/ssl_db':
      ensure  => directory,
      mode    => '0700',
      owner   => $::squid::daemon_user,
      group   => $::squid::daemon_group,
      require => Package[$::squid::package_name],
    }

    exec { 'Initialize SSL DB':
      command   => "ssl_crtd -c -s /var/lib/ssl_db/ && touch /var/lib/ssl_db/.lock",
      creates   => '/var/lib/ssl_db/.lock',
      before    => File['/var/lib/ssl_db'],
      path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/lib64/squid/',
      require   => Package[$::squid::package_name],
      logoutput => 'on_failure',
    }

    $dport = [$http_port,$https_port]
  } else {
    $dport = $http_port
  }

  squid::extra_config_section {'Cache manager':
    config_entries => {
      'cache_mgr' => $cache_mgr,
    },
  }

  squid::cache_dir { $cache_dir:
    type    => 'aufs',
    options => "${cache_dir_space} ${cache_dir_L1} ${cache_dir_L2}"
  }

  squid::extra_config_section {'Minimum object size':
    config_entries => {
      'minimum_object_size' => $minimum_object_size,
    },
  }

  firewallchain { 'SQUID:filter:IPv4':
    ensure => present,
    before => undef,
  }

  firewall { '999 drop all SQUID':
    proto  => 'all',
    action => 'drop',
    chain  => 'SQUID',
  }

  firewall {'010 jump webtraffic to SQUID chain':
    proto  => 'tcp',
    dport  => $dport,
    jump   => 'SQUID',
  }

  $http_access_defaults = {
    'port' => $http_port,
  }

  squid::http_access {'Access manager from localhost':
    value => 'localhost manager',
  }
  squid::http_access {'Deny manager from elsewhere':
    action  => 'deny',
    value   => 'manager',
  }

  $redirect_exclude_hash = generate_resource_hash($redirect_exclude, 'address', '')

  create_resources('squid::http_access', $http_access, {})
  create_resources('profile_squid::acl', $acls, {})
  create_resources('profile_squid::exclude', $redirect_exclude_hash, {})
}
