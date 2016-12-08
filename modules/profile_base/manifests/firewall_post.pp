# Helper class to avoid lock-outs during initial puppet run
class profile_base::firewall_post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
