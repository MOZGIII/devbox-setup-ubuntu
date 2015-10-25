# -*- mode: ruby -*-
# vi: set ft=ruby :

REQURED_PLUGINS = %w{
  vagrant-vbguest
  vagrant-cachier
}
unless REQURED_PLUGINS.all? {|e| Vagrant.has_plugin?(e) }
  raise "This Vagrantfile requires the following plugins to be installed: #{REQURED_PLUGINS * ' '}"
end

Vagrant.configure(2) do |config|
  config.vm.box = 'boxcutter/ubuntu1404-desktop'

  # config.vm.network 'forwarded_port', guest: 80, host: 8080
  # config.vm.network 'private_network', ip: '192.168.33.10'
  # config.vm.network 'public_network'

  config.vm.network 'private_network', type: :dhcp

  config.vm.provider 'virtualbox' do |vb|
    # vb.gui = true
    vb.memory = 1024
  end

  config.cache.scope = :box if Vagrant.has_plugin?('vagrant-cachier')

  config.vm.provision 'shell', inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y wget curl git
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
  SHELL
end
