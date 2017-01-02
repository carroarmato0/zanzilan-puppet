class profile_base::collectd {

  include ::collectd

  class {'::collectd::plugin::cpu': valuespercentage => true, }
  class {'::collectd::plugin::memory': valuespercentage => true, }
  include ::collectd::plugin::interface
  include ::collectd::plugin::load
  include ::collectd::plugin::swap
  include ::collectd::plugin::write_network

}
