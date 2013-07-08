# Configure a ceph rgw node
#
#

class ceph::rgw (
  $fsid,
  $rgw_data = '/var/lib/ceph/radosgw'
) {

  include 'ceph::package'

  ensure_packages( [ 'radosgw','apache2','libapache2-mod-fastcgi', 'ceph-common', 'ceph' ] )

  exec { 'rewrite':
    command => 'a2enmod rewrite',
    path    => ['/usr/bin', '/usr/sbin'],
    creates => '/etc/apache2/mods-enabled/rewrite.load',
    require => Package['apache2'],
  }

  exec { 'fastcgi':
    command => 'a2enmod fastcgi',
    path    => ['/usr/bin', '/usr/sbin'],
    creates => '/etc/apache2/mods-enabled/fastcgi.load',
    require => Package['libapache2-mod-fastcgi'],
  }

  Package['ceph'] -> Ceph::Key <<| title == 'admin' |>>

  file { $::ceph::rgw::rgw_data:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

  class { 'ceph::conf':
    fsid      => $fsid,
    auth_type => $auth_type,
  }

  ceph::conf::rgw {$name:
    rgw_addr  => $address
  }

  exec { 'ceph-rgw-keyring':
    command => "ceph-authtool /var/lib/ceph/tmp/keyring.rgw \
--create-keyring \
--gen-key \
--name client.rgw \
--cap osd 'allow rwx' \
--cap mon 'allow r'",
    creates => "/var/lib/ceph/tmp/keyring.rgw",
    require => Package['ceph', 'ceph-common'],
  }

  exec { 'ceph-add-key':
    command => "ceph -k /etc/ceph/keyring \
auth get-or-create client.rgw -i /var/lib/ceph/tmp/keyring.rgw",
    require => Package['ceph'],
  }

  file { '/var/www/s3gw.fcgi':
    owner   => 'root',
    mode    => '0755',
    content => '#!/bin/sh
exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway'
  }

  service { 'radosgw':
    ensure   => running,
    provider => $::ceph::params::service_provider,
    start    => '/etc/init.d/radosgw start',
    stop     => '/etc/init.d/radosgw stop',
  }

}

