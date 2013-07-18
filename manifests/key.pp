 #
define ceph::key (
  $secret       = undef,
  $secret_file  = false,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
  $user         = 'root',
  $group        = 'root',
) {

  if ! $secret_file {
    exec { "ceph-key-${name}":
      command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}'",
      creates => $keyring_path,
      require => Package['ceph'],
    }

    file { "${keyring_path}":
      ensure  => file,
      owner   => $user,
      group   => $group,
      #require => Exec["ceph-key-${name}"]
    }
  } else {
    exec { "ceph-key-${name}":
      command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key=$(cat ${secret})",
      creates => $keyring_path,
      require => Package['ceph'],
    }

    @@file { "${keyring_path}":
      ensure  => file,
      owner   => $user,
      group   => $group,
      tag     => "key-${name}",
      source  => "${keyring_path}"
      #require => Exec["ceph-key-${name}"]
    }
  }



}
