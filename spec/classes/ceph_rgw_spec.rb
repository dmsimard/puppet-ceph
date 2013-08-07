require 'spec_helper'

describe "ceph::rgw" do

  let :params do
    {
      :fsid  => '000000',
    }
  end


 it do
    should contain_file('/var/www/s3gw.fcgi')
    should contain_file('/var/lib/ceph/radosgw')
  end

end
