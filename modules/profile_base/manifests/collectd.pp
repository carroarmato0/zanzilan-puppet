class profile_base::collectd {

  include ::profile_collectd

  if $::virtual != 'lxc' {
    include ::collectd::plugin::disk
    include ::collectd::plugin::load
    include ::collectd::plugin::swap
    include ::collectd::plugin::cgroups
    include ::collectd::plugin::lvm
    class {'::collectd::plugin::cpu': valuespercentage => true, }
    class {'::collectd::plugin::memory': valuespercentage => true, }
  }

  include ::collectd::plugin::interface
  include ::collectd::plugin::write_network

}
