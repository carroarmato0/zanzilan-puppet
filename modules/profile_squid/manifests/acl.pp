define profile_squid::acl (
  $type,
  $aclname = $title,
  $entries = [],
  $order   = '05',
) {

  if $type == 'src' {

    if $::profile_squid::enable_ssl {
      $squid_dport = [$::profile_squid::http_port, $::profile_squid::https_port]

      $redirect_https_hash = generate_resource_hash($entries, 'source', "050 redirect port ${::profile_squid::https_port} to SQUID from ${aclname} ")
      $redirect_https_defaults = {
        'chain'   => 'PREROUTING',
        'proto'   => 'tcp',
        'dport'   => '443',
        'jump'    => 'REDIRECT',
        'toports' => "${::profile_squid::https_port}",
        'table'   => 'nat',
      }

      create_resources('firewall', $redirect_https_hash, $redirect_https_defaults)
    } else {
      $squid_dport = $::profile_squid::http_port
    }

    $accept_http_hash = generate_resource_hash($entries, 'source', "010 accept webtraffic to SQUID port from ${aclname} ")
    $accept_http_defaults = {
      'proto'   => 'tcp',
      'dport'   => $squid_dport,
      'action'  => 'accept',
      'chain'   => 'SQUID',
    }

    create_resources('firewall', $accept_http_hash, $accept_http_defaults)

    $redirect_http_hash = generate_resource_hash($entries, 'source', "050 redirect port ${::profile_squid::http_port} to SQUID from ${aclname} ")
    $redirect_http_defaults = {
      'chain'   => 'PREROUTING',
      'proto'   => 'tcp',
      'dport'   => '80',
      'jump'    => 'REDIRECT',
      'toports' => "${::profile_squid::http_port}",
      'table'   => 'nat',
    }

    create_resources('firewall', $redirect_http_hash, $redirect_http_defaults)
  }

  squid::acl{ $aclname:
    type    => $type,
    aclname => $aclname,
    entries => $entries,
    order   => $order,
  }

}
