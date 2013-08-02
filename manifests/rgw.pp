# Configure a ceph rgw node
#
#

class ceph::rgw (
  $fsid,
  $swift_user,
  $swift_key,
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

   exec { 'a2-dis-default':
     command => 'a2dissite 000-default',
     path    => ['/usr/bin', '/usr/sbin'],
     require => Package['apache2'],
     onlyif  => "/bin/ls /etc/apache2/sites-enabled/000-default"
   }
  
   exec { 'a2-en-rgw.conf':
     command => 'a2ensite rgw.conf',
     path    => ['/usr/bin', '/usr/sbin'],
     require => File['/etc/apache2/sites-available/rgw.conf'],
     creates => '/etc/apache2/sites-enabled/rgw.conf',
   }


   file_line { "apache_listen": 
      line => "Listen ${::network_eth2_1}:80", 
      path => "/etc/apache2/ports.conf", 
      match => "^Listen.*$",
      ensure => present 
   }

  service { 'apache2':
    ensure    => running,
    name      => 'apache2'
  }

  exec { 'a2 reload':
     command => '/etc/init.d/apache2 reload',
     path    => ['/usr/bin', '/usr/sbin', '/bin'],
     require => [ Exec['a2-en-rgw.conf'],
                  Exec['a2-dis-default'],
                  File_line['apache_listen'],
                  Service['apache2'],],
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
    command => "ceph-authtool /var/lib/ceph/radosgw/keyring.rgw \
--create-keyring \
--gen-key \
--name client.radosgw.gateway \
--cap osd 'allow rwx' \
--cap mon 'allow r'",
    creates => "/var/lib/ceph/radosgw/keyring.rgw",
    require => Package['ceph', 'ceph-common'],
  }

  exec { 'ceph-add-key':
    command => "ceph -k /etc/ceph/keyring \
auth add client.radosgw.gateway -i /var/lib/ceph/radosgw/keyring.rgw \
mon 'allow r' \
osd 'allow rwx'
",
    require => Exec['ceph-rgw-keyring'] ,
  }

  file { '/var/www/s3gw.fcgi':
    owner   => 'root',
    mode    => '0755',
    content => '#!/bin/sh
exec /usr/bin/radosgw -c /etc/ceph/ceph.conf -n client.radosgw.gateway'
  }
  # NOTE(mkoderer): seems hasstatus doesn't work with all puppet versions
  # service { 'radosgw':
  #    ensure    => running,
  #    start     => '/etc/init.d/radosgw start',
  #    stop      => '/etc/init.d/radosgw stop',
  #    hasstatus => false,
  #    pattern   => 'radosgw',
  #  }

  exec {'start_radosgw':
    command => '/etc/init.d/radosgw start',
    unless  => 'ps -ef|grep radosgw|grep -q grep',
  }

  exec { 'add-swift-user':
    command => "radosgw-admin user create --uid=admin \
--gen-secret --display-name ${swift_user}",
    require => Exec['start_radosgw'],
    unless  => "radosgw-admin user info --uid=admin"
  }

  exec { 'add-swift-subuser':
    command => "radosgw-admin subuser create \
--uid=admin --subuser=${swift_user} \
--secret=${swift_key} --display-name ${swift_user} \
--key-type swift --access=full",
    require => Exec['add-swift-user'] ,
    unless  => "radosgw-admin user info --uid=admin|grep admin:${swift_user}"
  }
  

}

