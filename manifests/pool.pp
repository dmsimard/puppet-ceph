# Manage some operations on the pools in the cluster
#
# == Name
# the resource name is the name of the pool to be created.
#
# == Parameters
#
# [*create_pool*] if a pool should be created
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*delete_pool*] if the given pool should be deleted.
#  WARNING: This will *PERMANENTLY DESTROY* all data stored in the pool!!!
#  Optional. Boolean (true or false).
#  Defaults to 'false'.
#
# [*pg_num*] Number of PGs for the pool.
#  Optional. Boolean (true or false).
#  Defaults to '128'.
#
# [*pgp_num*] Number of PGPs for the pool. 
#  Optional. Boolean (true or false).
#  Defaults to '128'.
#
# == Dependencies
#
# ceph::osd need to be called for the node beforehand. The
# MON node(s) need to be setup and running.
#
# Make sure the machine has a client.admin key in the keyring file.
#
# == Authors
#
#  Danny Al-Gaaf <danny.al-gaaf@bisect.de>
#
# == Copyright
#
#

define ceph::pool (
  $create_pool = false,
  $delete_pool = false,
  $pg_num      = '128',
  $pgp_num     = '128',
){
  include 'ceph::package'

  if $create_pool == true { 
    exec { "ceph-osd-pool-create-${name}":
      command => "ceph osd pool create ${name} ${pg_num} ${pgp_num}",
      onlyif  => "ceph osd lspools | grep ' ${name},'",
      require => Package['ceph']
    }
  }

  if $delete_pool == true { 
    exec { "ceph-osd-pool-delete-${name}":
      command => "ceph osd pool delete ${name} ${name} --yes-i-really-really-mean-it",
      unless  => "ceph osd lspools | grep ' ${name},'",
      require => Package['ceph']
    }
  }
}
