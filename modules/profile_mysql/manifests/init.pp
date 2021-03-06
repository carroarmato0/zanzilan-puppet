class profile_mysql (
  $root_password,
  $monitor_password,
  $monitor_hostname = '%',
  $remove_default_accounts = true,
  $override_options = {},
  $databases = {},
  $users = {},
  $grants = {},
) {

  class {'::mysql::server':
    root_password           => $root_password,
    remove_default_accounts => $remove_default_accounts,
    override_options        => $override_options,
    databases               => $databases,
    users                   => $users,
    grants                  => $grants,
  }

  class {'::mysql::server::monitor':
    mysql_monitor_username => 'monitor',
    mysql_monitor_password => $monitor_password,
    mysql_monitor_hostname => $monitor_hostname,
  }

  collectd::plugin::mysql::database {'mysql':
    host        => 'localhost',
    username    => 'monitor',
    password    => $monitor_password,
    masterstats => false,
  }

  firewall {'081 accept port 3306':
    proto   => 'tcp',
    dport   => '3306',
    action  => 'accept',
  }

}
