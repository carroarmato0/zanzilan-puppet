define profile_squid::refresh_pattern (
  $case_sensitive = false,
  $regex = '.',
  $order = 60,
  $min = 0,
  $percent = 0,
  $max = 0,
  $options = '',
) {

  if $case_sensitive {
    $case_senitivity = '-i '
  } else {
    $case_senitivity = ''
  }

  concat::fragment { "Refresh Patterns: ${name}":
    target  => "/etc/${::squid::package_name}/refresh_patterns",
    content => "# ${name}\nrefresh_pattern ${case_senitivity}${regex} ${min} ${percent}% ${max} ${options}\n",
    order   => '01',
    require => Package[$::squid::package_name],
    notify  => Service[$::squid::service_name],
  }

}
