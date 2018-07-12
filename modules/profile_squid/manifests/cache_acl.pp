define profile_squid::cache_acl (
  $action = 'allow',
  $value  = $title,
  $order   = '06',
) {

  validate_re($action,['^allow$','^deny$'])
  validate_string($value)

  concat::fragment{"squid_cache_acl_${value}":
    target  => $squid::config,
    content => template('profile_squid/squid.conf.cache_acl.erb'),
    order   => "21-${order}-${action}",
  }

}
