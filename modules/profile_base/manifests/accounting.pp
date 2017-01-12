class profile_base::accounting (
  $user_hash = {},
) {

  class {'sudo':
    includedirsudoers => true,
  }

  if $::virtual == 'virtualbox' {
    sudo::conf { 'vagrant':
       priority => 20,
       content  => "Defaults:vagrant !requiretty\nvagrant ALL=(ALL) NOPASSWD: ALL",
    }
  }

  sudo::conf { 'admins':
    priority => 20,
    content  => "%wheel	ALL=(ALL)	NOPASSWD: ALL",
  }

  $user_defaults = {
    managehome      => true,
    purge_ssh_keys  => true,
  }

  create_resources('profile_base::user', $user_hash, $user_defaults)
}
