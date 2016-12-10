class profile_cache (
  $worker_processes   = undef,
  $worker_connections = undef,
  $cachedir           = '/var/cache/nginx/lancache',
  $resolvers          = ['8.8.8.8', '8.8.4.4'],
  $max_file_size      = '40960m',
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
      cachelog              => '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$upstream_cache_status" "$host" "$http_range"',
    },
    proxy_cache_path              => $cachedir,
    proxy_cache_levels            => '2:2',
    proxy_cache_keys_zone         => 'generic:500m',
    proxy_cache_inactive          => '200d',
    proxy_cache_max_size          => '500000m',
    proxy_cache_loader_files      => 1000,
    proxy_cache_loader_sleep      => '50ms',
    proxy_cache_loader_threshold  => '300ms',
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

  nginx::resource::server {'generic':
    index_files           => [],
    access_log            => '/var/log/nginx/lancache/access.log',
    error_log             => '/var/log/nginx/lancache/error.log',
    format_log            => 'cachelog',
    resolver              => $resolvers,
    proxy_cache           => 'generic',
    proxy_cache_key       => '$uri$slice_range',
    # Allow the use of stale entries
    proxy_cache_use_stale => 'error timeout invalid_header updating http_500 http_502 http_503 http_504',
    # Allow caching of 200 but not 301 or 302 as our cache key may not include query params
    # hence may not be valid for all users
    proxy_cache_valid     => ['200 206 7d','200 90d','301 302 0'],
    proxy_set_header      => [
      'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'Range $slice_range',
    ],
    add_header            => {
      'X-Upstream-Status'        => '$upstream_status',
      'X-Upstream-Response-Time' => '$upstream_response_time',
      'X-Upstream-Cache-Status'  => '$upstream_cache_status',
    },
    location_cfg_append   => {
      slice                      => '1m',
      proxy_ignore_headers       => 'Expires Cache-Control',
      # Only download one copy at a time and use a large timeout so
      # this really happens, otherwise we end up wasting bandwith
      # getting the file multiple times.
      proxy_cache_lock           => 'on',
      proxy_cache_lock_timeout   => '1h',
      # Enable cache revalidation
      proxy_cache_revalidate     => 'on',
      # Don't cache requests marked as nocache=1
      proxy_cache_bypass         => '$arg_nocache',
      # max file size
      proxy_max_temp_file_size   => $max_file_size,
      proxy_next_upstream        => 'error timeout http_404',
      proxy_pass                 => 'http://$host$request_uri',
      proxy_redirect             => 'off',
      proxy_ignore_client_abort  => 'on',
    },
  }

}
