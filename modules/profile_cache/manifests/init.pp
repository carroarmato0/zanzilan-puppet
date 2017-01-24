class profile_cache (
  $worker_processes   = undef,
  $worker_connections = undef,
  $cachedir           = '/var/cache/nginx/lancache',
  $resolvers          = ['8.8.8.8', '8.8.4.4'],
  $max_file_size      = '40960m',
) inherits profile_cache::defaults {

  class {'collectd::plugin::nginx':
    url => 'http://127.0.0.1/nginx_status',
  }

  if $worker_processes == undef {
    $real_worker_processes = $::processorcount
  } else {
    $real_worker_processes = $worker_processes
  }

  if $worker_connections == undef {
    $real_worker_connections = $::processorcount * 1024
  } else {
    $real_worker_connections = $worker_processes
  }

  class { "nginx":
    worker_processes              => $real_worker_processes,
    worker_connections            => $real_worker_connections,
    worker_rlimit_nofile          => $::ulimit,
    server_purge                  => true,
    multi_accept                  => 'on',
    events_use                    => 'epoll',
    sendfile                      => 'on',
    http_tcp_nopush               => 'on',
    http_tcp_nodelay              => 'on',
    keepalive_timeout             => 65,
    gzip                          => 'on',
    log_format                    => {
      cachelog      => '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$upstream_cache_status" "$host" "$http_range"',
    },
    proxy_cache_path              => {
      "${cachedir}/riot"      => 'riot:500m',
      "${cachedir}/blizzard"  => 'blizzard:500m',
    },
    proxy_cache_levels            => '2:2',
    proxy_cache_inactive          => '120d',
    proxy_cache_max_size          => '15100m',
    proxy_cache_loader_files      => '1000',
    proxy_cache_loader_sleep      => '50ms',
    proxy_cache_loader_threshold  => '300ms',
  }

  file { $cachedir:
    ensure  => directory,
    mode    => '0644',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::log_group,
    require => Package[$::nginx::params::package_name],
  }
  file { "${cachedir}/tmp":
    ensure  => directory,
    mode    => '0644',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::log_group,
  }
  file { '/var/log/nginx/lancache':
    ensure  => directory,
    mode    => '0644',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::log_group,
  }
  file { '/var/log/nginx/lancache/access.log':
    ensure  => file,
    mode    => '0644',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::log_group,
    notify  => Service['nginx'],
  }
  file { '/var/log/nginx/lancache/error.log':
    ensure  => file,
    mode    => '0644',
    owner   => $::nginx::daemon_user,
    group   => $::nginx::log_group,
    notify  => Service['nginx'],
  }

  nginx::resource::server {'default':
    listen_options        => 'default_server',
    index_files           => [],
    use_default_location  => false,
    locations             => {
      '~ ^/nginx_status$' => {
        'location_cfg_append' => {
          'stub_status' => 'on',
          'access_log'  => 'off',
        },
        'location_allow' => ['127.0.0.1'],
        'location_deny'  => ['all'],
      },
    },
  }

  nginx::resource::server {'cache-steam':
    server_name           => $::profile_cache::defaults::steam_servers,
    index_files           => ['index.html', 'index.htm'],
    access_log            => '/var/log/nginx/lancache/access.log',
    error_log             => '/var/log/nginx/lancache/error.log',
    format_log            => 'cachelog',
    resolver              => $resolvers,
    server_cfg_prepend    => {
      'root'            => "${cachedir}/steam",
      'error_page'      => '500 502 503 504 /50x.html',
      'proxy_temp_path' => "${cachedir}/tmp/ 1 2",
    },
    use_default_location  => false,
    raw_append            => template('profile_cache/steam_cache.erb'),
  }

  nginx::resource::server {'cache-blizzard':
    server_name           => $::profile_cache::defaults::blizzard_servers,
    index_files           => ['index.html', 'index.htm'],
    access_log            => '/var/log/nginx/lancache/access.log',
    error_log             => '/var/log/nginx/lancache/error.log',
    format_log            => 'cachelog',
    resolver              => $resolvers,
    server_cfg_prepend    => {
      'root'            => "${cachedir}/blizzard",
      'error_page'      => '500 502 503 504 /50x.html',
      'proxy_temp_path' => "${cachedir}/tmp/ 1 2",
    },
    use_default_location  => false,
    raw_append            => template('profile_cache/blizzard_cache.erb'),
  }

  nginx::resource::server {'cache-riot':
    server_name           => $::profile_cache::defaults::riot_servers,
    index_files           => ['index.html', 'index.htm'],
    access_log            => '/var/log/nginx/lancache/access.log',
    error_log             => '/var/log/nginx/lancache/error.log',
    format_log            => 'cachelog',
    resolver              => $resolvers,
    server_cfg_prepend    => {
      'root'            => "${cachedir}/riot",
      'error_page'      => '500 502 503 504 /50x.html',
      'proxy_temp_path' => "${cachedir}/tmp/ 1 2",
    },
    use_default_location  => false,
    raw_append            => template('profile_cache/riot_cache.erb'),
  }

  firewall{'080 accept HTTP':
    proto   => 'tcp',
    dport   => 80,
    action  => 'accept',
  }

}
