class profile_webserver (
  $vhosts             = {},
  $php_version        = '5.6',
  $worker_processes   = undef,
  $worker_connections = undef,
) {

  class {'collectd::plugin::nginx':
    url => 'http://localhost/status',
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

  create_resources('nginx::resource::server', $vhosts, {})

  firewall {'080 accept port 80':
    proto   => 'tcp',
    dport   => '80',
    action  => 'accept',
  }

}
