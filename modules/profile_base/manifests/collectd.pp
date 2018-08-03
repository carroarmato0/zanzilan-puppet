class profile_base::collectd {

  include ::profile_collectd

  if $::virtual != 'lxc' {
    include ::collectd::plugin::load
    include ::collectd::plugin::swap
    include ::collectd::plugin::cgroups
    class {'::collectd::plugin::cpu': valuespercentage => true, }
    class {'::collectd::plugin::memory': valuespercentage => true, }
  }

  class {'::collectd::plugin::df': reportbydevice => true, }
  #include ::collectd::plugin::interface
  #include ::collectd::plugin::write_network

}
