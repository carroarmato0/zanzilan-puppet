class profile_base {

  include ::ntp
  include ::stdlib
  include ::timezone
  include ::profile_network
  include ::profile_base::repos
  include ::profile_base::packages
  include ::profile_base::firewall

  firewall { '006 Allow inbound SSH':
    dport    => [22,2222],
    proto    => tcp,
    action   => accept,
  }

}
