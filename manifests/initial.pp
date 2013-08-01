# Class: initial
#
# Baisc, just to make it work.
class ceph::initial (
    $path_to_temp_kerying = '/tmp/keyring',
    ){

    file { '/root/admin.key':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        source => $ceph_admin,
    }
    file { '/root/monitor_secret.key':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        source => $monitor_secret,
    }
    file { "${path_to_temp_kerying}":
        ensure => file,
    }

    exec { 'ceph-key-mon':
      command => "ceph-authtool ${path_to_temp_kerying} --name='mon.' --add-key=$(cat /root/monitor_secret.key)",
      require => [Package['ceph'],File['/root/monitor_secret.key'],File["${path_to_temp_kerying}"]],
      unless  => "grep -o '\\[mon.\\]' ${path_to_temp_kerying}",
  }
    exec { 'ceph-key-admin':
      command => "ceph-authtool ${path_to_temp_kerying} --name='client.admin' --add-key=$(cat /root/admin.key)  --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *'",
      require => [Package['ceph'],File['/root/admin.key'],Exec['ceph-key-mon'],],
      unless  => "grep -o '\\[client.admin]' ${path_to_temp_kerying}",
  }

    exec { 'ceph-key-admin':
      command => "ceph-authtool /etc/ceph/keyring -C --name='client.admin' --add-key=$(cat /root/admin.key)",
      require => [Package['ceph'],File['/root/admin.key'],Exec['ceph-key-mon'],],
      unless  => "grep -o '\\[client.admin]' ${path_to_temp_kerying}",
  }

}
