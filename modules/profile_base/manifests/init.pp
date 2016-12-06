class profile_base {

  include ::ntp
  include ::profile_base::repos
  include ::profile_base::packages
}
