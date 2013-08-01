# Class: initial
#
# Baisc, just to make it work.
class initial (
    $path_to_temp_kerying = '/tmp/keyring',
    ){

    file { '/root/admin.key':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        source => $::ceph_admin_key,
    }
    file { '/root/monitor_secret.key':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        source => $::monitor_secret,
    }

    exec { 'ceph-key-mon':
      command => "ceph-authtool ${path_to_temp_kerying} --name='mon.' --add-key='$(cat /root/monitor_secret)'",
      require => [Package['ceph'],File['/root/monitor_secret.key'],]
    }
    exec { 'ceph-key-admin':
      command => "ceph-authtool ${path_to_temp_kerying} --create-keyring --name='client.${name}' --add-key='$(cat /root/admin.key'",
      require => [Package['ceph'],File['/root/admin.key'],Exec['ceph-key-mon'],]
    }


# #Will clean up, comes later.
# exec { "clean-up":
#   command => "/bin/echo",
#   #path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
#   #refreshonly => true,


}