 #
define ceph::key::permissions (
    $keyring_path       = "/var/lib/ceph/tmp/${name}.keyring",
    $mon_permissons     = undef,
    $osd_permissons     = undef,
    $mds_permissons     = undef,
) {

    # This ensures that the key is injected to the Cluster.
    exec { "ceph-add-key-${name}-to-cluster":
        unless  => "ceph auth get-key client.${name}",
        command => "ceph auth add client.${name} --in-file=${keyring_path}",
        require => Package['ceph'],
    }
    notify {"Executing ceph-add-key-${name}-to-cluster":}
    notify {"keyring_path is ${keyring_path}":}

    $mon_caps = "mon 'allow ${mon_permissons}'"
    $osd_caps = "osd 'allow ${osd_permissons}'"
    $mds_caps = "mds 'allow ${mds_permissons}'"


    # We're able to set the permission for a key only once.
    # Some notes to the unless:
    # It will call the `ceph auth list`, add some newline and then
    # grep the right key out.`
    # The newlines are necessary so existing permissions don't interfere
    # with the grep output. Adding enough newlines allow a more accurate
    # out and validating each key.
    exec { "ceph-set-permisson-key-${name}":
        unless  => "ceph auth list|sed 's/client.*/\n\n\n&/g'| grep -A4 client.${name}|egrep -o 'allow ${mon_permissons}|allow ${osd_permissons}|allow ${mds_permissons}'",
        command => "ceph auth caps client.${name} ${mon_caps} ${osd_caps} ${$mds_caps}",
        require => [Package['ceph'],Exec["ceph-add-key-${name}-to-cluster"]]
      }
    notify {"Executing ceph-set-permisson-key-${name}":}
}