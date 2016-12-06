class profile_base {

  include ::ntp
  include ::stdlib
  include ::timezone
  include ::profile_base::repos
  include ::profile_base::packages
}
