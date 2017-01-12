class profile_base {

  include ::cron
  include ::stdlib
  include ::timezone
  include ::network
  include ::selinux
  include ::profile_base::ssh
  include ::profile_base::accounting
  include ::profile_base::repos
  include ::profile_base::packages
  include ::profile_base::firewall
  include ::profile_base::collectd

  if $::virtual != 'virtualbox' {
    include ::puppet
  }

  if $::virtual != 'lxc' {
    include ::ntp
  }

}
