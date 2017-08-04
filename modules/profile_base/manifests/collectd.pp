class profile_base::collectd {

  include ::profile_collectd

  if $::virtual != 'lxc' {
    include ::collectd::plugin::disk
    include ::collectd::plugin::load
    include ::collectd::plugin::swap
    class {'::collectd::plugin::cpu': valuespercentage => true, }
    class {'::collectd::plugin::memory': valuespercentage => true, }
    class { 'collectd::plugin::cgroups':
      ignore_selected => true,
      cgroups         => [],
    }
  }

  include ::collectd::plugin::interface
  include ::collectd::plugin::write_network

}
