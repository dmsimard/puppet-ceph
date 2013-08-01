# Creates the ceph configuration file
#
# == Parameters
# [*fsid*] The cluster's fsid.
#   Mandatory. Get one with `uuidgen -r`.
#
# [*auth_type*] Auth type.
#   Optional. undef or 'cephx'. Defaults to 'cephx'.
#
# == Dependencies
#
# none
#
# == Authors
#
#  François Charlier francois.charlier@enovance.com
#  Sébastien Han     sebastien.han@enovance.com
#
# == Copyright
#
# Copyright 2012 eNovance <licensing@enovance.com>
#
class ceph::conf (
  $fsid,
  $auth_type         = 'cephx',
  $pool_default_size = undef,
  $journal_size_mb   = 4096,
  $cluster_network   = undef,
  $public_network    = undef,
  $mon_data          = '/var/lib/ceph/mon/mon.$id',
  $osd_data          = '/var/lib/ceph/osd/osd.$id',
  $osd_journal       = undef,
  $mds_enabled       = true,
  $mds_data          = '/var/lib/ceph/mds/mds.$id',
  $rgw_data          = '/var/lib/ceph/radosgw',
  $keyring_path      = undef,
) {

  include 'ceph::package'

  if $auth_type == 'cephx' {
    $mode = '0660'
  } else {
    $mode = '0664'
  }

  if $osd_journal {
    $osd_journal_real = $osd_journal
  } else {
    $osd_journal_real = "${osd_data}/journal"
  }

  # Need 'r' for services like libvirt/glance/cinder to access to the cluster.
  concat { '/etc/ceph/ceph.conf':
    owner   => 'root',
    group   => 0,
    mode    => '0664',
    require => Package['ceph'],
  }

  Concat::Fragment <<| target == '/etc/ceph/ceph.conf' |>>

  concat::fragment { 'ceph.conf':
    target  => '/etc/ceph/ceph.conf',
    order   => '01',
    content => template('ceph/ceph.conf.erb'),
  }

}
