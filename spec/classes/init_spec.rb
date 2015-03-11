require 'spec_helper'
describe 'gitlab' do
  let(:facts) do
    { operatingsystem: 'CentOS',
      operatingsystemmajrelease: '6',
      osfamily: 'RedHat'
    }
  end

  context 'with defaults for all parameters' do
    let(:params) do
      { admin_password: 'secret' }
    end
    it { should contain_class('gitlab') }
  end
end
