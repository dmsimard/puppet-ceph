define ceph::conf::rgw (
  $rgw_addr 
) {

  concat::fragment { "ceph-rgw-${name}.conf":
    target  => '/etc/ceph/ceph.conf',
    order   => '90',
    content => template('ceph/ceph.conf-rgw.erb'),
  }

 file { "rgw.conf":
    ensure  => file,
    path    => '/etc/apache2/sites-available/rgw.conf',
    require => Package['apache2'],
    content => template('ceph/rgw.conf.erb'),
  }
}
