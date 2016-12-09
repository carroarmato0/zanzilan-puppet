class profile_cache (
  $worker_processes   = undef,
  $worker_connections = undef,
) {

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
      cachelog => '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$upstream_cache_status" "$host" "$http_range"',
    },
    proxy_cache_path              => '/var/cache/nginx/lancache',
    proxy_cache_levels            => '2:2',
    proxy_cache_keys_zone         => 'generic:500m',
    proxy_cache_inactive          => '200d',
    proxy_cache_max_size          => '500000m',
    proxy_cache_loader_files      => 1000,
    proxy_cache_loader_sleep      => '50ms',
    proxy_cache_loader_threshold  => '300ms',
  }

  nginx::resource::server { 'default':
    listen_port         => 80,
    index_files         => [],
    listen_options      => 'default',
    location_cfg_append => {
      root        => '/var/www/',
      add_header  => 'Host $host',
    },
  }

  firewall{'080 accept HTTP':
    proto   => 'tcp',
    dport   => 80,
    action  => 'accept',
  }

  # nginx::resource::server {'generic':
  #
  # }

}
