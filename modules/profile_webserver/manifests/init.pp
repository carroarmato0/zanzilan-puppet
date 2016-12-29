class profile_webserver (
  $server_name,
  $php_version        = '5.6',
  $worker_processes   = undef,
  $worker_connections = undef,
  $php_backend        = 'unix:/var/run/php-fpm/www.socket',
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

  class { 'nginx':
    worker_processes              => $real_worker_processes,
    worker_connections            => $real_worker_connections,
    server_purge                  => true,
    confd_purge                   => true,
    multi_accept                  => 'on',
    events_use                    => 'epoll',
    sendfile                      => 'on',
    http_tcp_nopush               => 'on',
    http_tcp_nodelay              => 'on',
    keepalive_timeout             => 65,
    gzip                          => 'on',
  }

  class {'::php::globals':
    php_version  => $php_version,
  }->
  class { '::php':
    manage_repos => true,
  }

  nginx::resource::server { $server_name:
    www_root        => "/var/www/${server_name}",
    listen_options  => 'default',
    locations       => {
      '~ \.php$'            => {
        'fastcgi' => $php_backend,
      },
      '~ ^/(status|ping)$'  => {
        'location_cfg_append' => {
          'access_log'      => 'off',
        },
        'location_allow'      => ['127.0.0.1'],
        'location_deny'       => ['all'],
        'fastcgi'             => $php_backend,
      },
    },
  }

  file { "/var/www/${server_name}":
    ensure  => directory,
    mode    => '0644',
    require => Package[$::nginx::package::package_name],
  }

  firewall {'080 accept port 80':
    proto   => 'tcp',
    dport   => '80',
    action  => 'accept',
  }

}
