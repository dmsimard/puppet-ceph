 #
define ceph::osd::pool (
    $pg_num = '128',
){
    exec { "create-pool-${name}":
        command => "ceph osd pool create ${name} ${pg_num}",
        #path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
        unless  => "ceph osd dump|grep -o ${name}"
    }
}