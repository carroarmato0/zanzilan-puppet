class profile_base {

  include ::ntp
  include ::stdlib
  include ::timezone
  include ::network
  include ::selinux
  include ::profile_base::repos
  include ::profile_base::packages
  include ::profile_base::firewall
  include ::profile_base::collectd

  if $::virtual != 'virtualbox' {
    include ::puppet
  }

  firewall { '006 accept SSH':
    dport    => [22,2222],
    proto    => tcp,
    action   => accept,
  }

}
