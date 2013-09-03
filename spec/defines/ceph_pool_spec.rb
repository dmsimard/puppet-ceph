require 'spec_helper'

describe 'ceph::pool' do

  let (:title) { 'rbd_testing_pool' }

  it { should include_class('ceph::package') }

  context 'wen create pool' do
    let(:params) { { :create_pool => true, :pg_num => '128', :pgp_num => '128'} }

    it do 
      should contain_exec('ceph-osd-pool-create-rbd_testing_pool').with({
        'command' => 'ceph osd pool create rbd_testing_pool 128 128',
        'onlyif'  => "ceph osd lspools | grep ' rbd_testing_pool,'",
        'require' => 'Package[ceph]'
      })
    end

  end

  context 'wen delete pool' do
    let(:params) { { :delete_pool => true } } 

    it do
      should contain_exec('ceph-osd-pool-delete-rbd_testing_pool').with({
        'command' => 'ceph osd pool delete rbd_testing_pool rbd_testing_pool --yes-i-really-really-mean-it',
        'unless'  => "ceph osd lspools | grep ' rbd_testing_pool,'",
        'require' => 'Package[ceph]'
    })
    end

  end

end
