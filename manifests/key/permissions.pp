 #
define ceph::key::permissions (
    $keyring_path       = "/var/lib/ceph/tmp/${name}.keyring",
    $mon_permissons     = undef,
    $osd_permissons     = undef,
    $mds_permissons     = undef,
    $set_mon_permission = true,
    $set_osd_permission = true,
    #We don't neeed mds.
    $set_mds_permission = flase,

) {

    # This ensures that the key is injected to the Cluster.
    exec { "ceph-add-key-${name}-to-cluster":
        command => "ceph auth add client.${name} --in-filename=${keyring_path}",
        unless  => "ceph auth get-key client.${name}"
    }
    # We
    # if $mon_permissons == '*'{
    #     $filter_permission = "\\${mon_permissons}"
    #     }else{
    #         $filter_permission = $mon_permissons
    #     }

    #     if $osd_permissons == '*'{
    #     $filter_osd_permission = "\\${mon_permissons}"
    #     }else{
    #         $filter_osd_permission = $mon_permissons
    #     }


    $mon_caps = "mon 'allow ${mon_permissons}'"
    $osd_caps = "osd 'allow ${osd_permissons}'"
    $mds_caps = "mds 'allow ${mds_permissons}'"


    # We're able to set the permisson for a key only once.
    exec { "ceph-set-permisson-key-${name}":
        unless  => "ceph auth list|grep -A4 client.${name}|egrep -o 'allow ${mon_permissons}|allow ${osd_permissons}|allow ${mds_permissons}'",
        command => "ceph auth caps client.${name} ${mon_caps} ${osd_caps} ${$mds_caps}",
        require => Package['ceph'],
      }
    notify {"Executing ceph-set-permisson-key-${name}":}
}