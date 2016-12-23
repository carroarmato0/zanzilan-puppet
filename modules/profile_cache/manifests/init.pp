class profile_cache (
  $worker_processes   = undef,
  $worker_connections = undef,
  $cachedir           = '/var/cache/nginx/lancache',
  $resolvers          = ['8.8.8.8', '8.8.4.4'],
  $max_file_size      = '40960m',
) inherits profile_cache::defaults {

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

  nginx::resource::server {'cache-steam':
    server_name           => $::profile_cache::defaults::steam_servers,
    #listen_options        => 'default_server',
    index_files           => ['index.html', 'index.htm'],
    access_log            => '/var/log/nginx/lancache/access.log',
    error_log             => '/var/log/nginx/lancache/error.log',
    format_log            => 'cachelog',
    resolver              => $resolvers,
    server_cfg_prepend    => {
      'root'            => "$cachedir/steam",
      'error_page'      => '500 502 503 504 /50x.html',
      'proxy_temp_path' => "${cachedir}/tmp/ 1 2",
    },
    use_default_location  => false,
    raw_append            => template('profile_cache/steam_cache.erb'),
  }

  firewall{'080 accept HTTP':
    proto   => 'tcp',
    dport   => 80,
    action  => 'accept',
  }

}
