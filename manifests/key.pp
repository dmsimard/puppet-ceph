 #
define ceph::key (
  $secret       = undef,
  $keyring_path = "/var/lib/ceph/tmp/${name}.keyring",
  $user         = 'root',
  $group        = 'root',
) {

  exec { "ceph-key-${name}":
    command => "ceph-authtool ${keyring_path} --create-keyring --name='client.${name}' --add-key='${secret}'",
    creates => $keyring_path,
    require => Package['ceph'],
  }

  file { "${keyring_path}":
    ensure  => file,
    owner   => $user,
    group   => $group,
    require => Exec["ceph-key-${name}"]
  }

}
