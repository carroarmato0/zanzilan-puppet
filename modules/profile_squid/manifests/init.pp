class profile_squid (
  $workers                        = $::processorcount,
  $http_access                    = {},
  $acls                           = {},
  $http_port                      = '8080',
  $redirect_exclude               = [],
  # Memory cache configuration options
  $cache_mem                      = '512 MB',
  $minimum_object_size            = '4 KB', # Should fit blocksize of partition
  $maximum_object_size_in_memory  = '2048 KB',
  # Disk cache configuration options
  $cache_dir                      = '/var/cache/squid',
  $cache_dir_space                = 30000, #Megabytes, should always be ~10-15% smaller than total of partition
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

  # Squid listening port
  squid::http_port { $http_port:
    options => 'transparent',
  }
  squid::http_port { '3128': }

  if $enable_ssl {
    squid::http_port { $https_port:
      ssl     => true,
      options => "intercept ssl-bump generate-host-certificates=on dynamic_cert_mem_cache_size=${dynamic_cert_mem_cache_size} cert=/etc/squid/ssl_cert/server.pem",
    }

    squid::extra_config_section {'SSL Bump Stare':
      config_entries => {
        'ssl_bump' => 'stare all',
      }
    }
    squid::extra_config_section {'SSL Bump Bump':
      config_entries => {
        'ssl_bump' => 'bump all',
      }
    }

    squid::extra_config_section {'sslcrtd':
      config_entries => {
        'sslcrtd_program'   => "/usr/lib64/squid/ssl_crtd -s /var/lib/ssl_db/ -M ${sslcrt_storage_max_size} -b ${minimum_object_size}",
        'sslcrtd_children'  => '8 startup=1 idle=1',
      }
    }

    file { '/etc/squid/ssl_cert':
      ensure       => directory,
      mode         => '0700',
      owner        => 'squid',
      group        => 'squid',
      recurse      => true,
      recurselimit => 1,
      require      => Package['squid'],
    }
    file { '/etc/squid/ssl_cert/server.pem':
      ensure  => file,
      mode    => '0700',
      owner   => 'squid',
      group   => 'squid',
      content => $ssl_cert,
      notify  => Service['squid'],
      require => Package['squid'],
    }

    file { '/var/lib/ssl_db':
      ensure  => directory,
      mode    => '0700',
      owner   => 'squid',
      group   => 'squid',
      require => Package['squid'],
    }

    exec { 'Initialize SSL DB':
      command   => "ssl_crtd -c -s /var/lib/ssl_db/ && touch /var/lib/ssl_db/.lock",
      creates   => '/var/lib/ssl_db/.lock',
      before    => File['/var/lib/ssl_db'],
      path      => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/lib64/squid/',
      require   => Package['squid'],
      #logoutput => 'on_failure',
      logoutput => true,
    }

    $dport = [$http_port,$https_port]
  } else {
    $dport = $http_port
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

  $redirect_exclude_hash = generate_resource_hash($redirect_exclude, 'address', '')

  create_resources('squid::http_access', $http_access, {})
  create_resources('profile_squid::acl', $acls, {})
  create_resources('profile_squid::exclude', $redirect_exclude_hash, {})
}
