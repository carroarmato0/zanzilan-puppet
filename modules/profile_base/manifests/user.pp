define profile_base::user (
  $ensure = 'present',
  $managehome = true,
  $purge_ssh_keys = true,
  $groups = undef,
  $password = undef,
  $ssh_key_hash = {},
) {

  user { $name:
    ensure          => $ensure,
    groups          => $groups,
    home            => "/home/${name}",
    managehome      => $managehome,
    password        => $password,
    purge_ssh_keys  => $purge_ssh_keys,
  }

  file { "/home/${name}":
    ensure  => directory,
    mode    => '0640',
    owner   => $name,
    group   => $name,
  }

  file { "/home/${name}/.ssh/":
    ensure  => directory,
    mode    => '0600',
    owner   => $name,
    group   => $name,
  }

  $ssh_key_defaults = {
    'user'  => $name,
    require => File["/home/${name}/.ssh/"],
  }

  create_resources('ssh_authorized_key', $ssh_key_hash, $ssh_key_defaults)

}
