require 'spec_helper'

describe 'jenkins', :type => :module do
  let (:facts) do
    {
      :osfamily                  => 'RedHat',
      :operatingsystem           => 'RedHat',
      :operatingsystemrelease    => '6.7',
      :operatingsystemmajrelease => '6',
    }
  end

  context 'user_setup' do
    context 'default' do
      it { should contain_user('jenkins') }
      it { should contain_group('jenkins') }

      [
        '/var/lib/jenkins',
        '/var/lib/jenkins/plugins',
        '/var/lib/jenkins/jobs'
      ].each do |datadir|
        it do
          should contain_file(datadir).with(
            :ensure => 'directory',
            :mode   => '0755',
            :group  => 'jenkins',
            :owner  => 'jenkins',
          )
        end
      end
    end
    context 'unmanaged' do
      let (:params) {{
        :manage_user     => false,
        :manage_group    => false,
        :manage_datadirs => false,
      }}
      it { should_not contain_user('jenkins') }
      it { should_not contain_group('jenkins') }
      it { should_not contain_file('/var/lib/jenkins') }
      it { should_not contain_file('/var/lib/jenkins/jobs') }
      it { should_not contain_file('/var/lib/jenkins/plugins') }
    end

    context 'custom home' do
      let (:params) {{
        :localstatedir => '/custom/jenkins',
      }}
      it { should contain_user('jenkins').with_home('/custom/jenkins') }
      it { should contain_file('/custom/jenkins') }
      it { should contain_file('/custom/jenkins/plugins') }
      it { should contain_file('/custom/jenkins/jobs') }
    end

  end

end
