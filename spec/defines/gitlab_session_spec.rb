require 'spec_helper'

describe 'gitlab_session' do
  let(:facts) do
    { operatingsystem: 'CentOS',
      operatingsystemmajrelease: '6',
      osfamily: 'RedHat'
    }
  end
  let(:title) { 'test-session' }
  context 'with a valid URI' do
    let(:params) do
      { name: 'abc',
        url: 'http://www.example.com:80',
        login: 'root',
        password: 'secret',
        new_password: 'supersecret'
      }
    end
    it { should compile }
  end
  context 'with an invalid URI' do
    let(:params) do
      { name: 'abc',
        url: 'http://w_w.example.com:80',
        login: 'root',
        password: 'secret',
        new_password: 'supersecret'
      }
    end
    it { expect { should compile }.to raise_error }
  end
  context 'with a hyphenated URI' do
    let(:params) do
      { name: 'abc',
        url: 'http://www-test.example.com:80',
        login: 'root',
        password: 'secret',
        new_password: 'supersecret'
      }
    end
    it { should compile }
  end
end
