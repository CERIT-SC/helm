require 'spec_helper'

describe 'helm::binary', :type => :class do

  let(:facts) { { :architecture => 'amd64' } }

  context 'with install_path => /usr/bin and version => 3.19.2 and proxy => https://proxy values for all parameters' do
    let(:params) { {
                    'install_path'    => '/usr/bin',
                    'version'         => '3.19.2',
                    'proxy'           => 'https://proxy',
                    'archive_baseurl' => 'https://get.helm.sh',
                 } }
    it do
      is_expected.to compile
      is_expected.to contain_archive('helm').with({
        'path' => '/tmp/helm-v3.19.2-linux-amd64.tar.gz',
        'source' => 'https://get.helm.sh/helm-v3.19.2-linux-amd64.tar.gz',
        'extract_command' => 'tar xfz %s linux-amd64/helm --strip-components=1 -O > /usr/bin/helm-3.19.2',
        'extract' => 'true',
        'extract_path' => '/usr/bin',
        'creates' => '/usr/bin/helm-3.19.2',
        'cleanup' => 'true',
        'proxy_server' => 'https://proxy',
      })
      is_expected.to contain_file('/usr/bin/helm-3.19.2').with({ :owner => 'root', :mode => '0755', :require => 'Archive[helm]'})
      is_expected.to contain_file('/usr/bin/helm').with({ :ensure => 'link', :target => '/usr/bin/helm-3.19.2', :require => 'File[/usr/bin/helm-3.19.2]'})
    end
  end
end
