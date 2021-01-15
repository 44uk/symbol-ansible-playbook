# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  #config.vm.box = "bento/centos-8"
  #config.vm.box = "bento/amazonlinux-2"
  config.vm.box = "bento/ubuntu-20.04"

  config.ssh.insert_key = false
  config.ssh.forward_agent = true
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 3001, host: 3001
  config.vm.network "forwarded_port", guest: 7200, host: 7200
  config.vm.network "forwarded_port", guest: 7202, host: 7202
  # config.vm.network "forwarded_port", guest: 7202, host: 7202
  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  config.vm.synced_folder "./", "/vagrant"

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  # config.vm.provision "ansible_local" do |ansible|
  #   ansible.install_mode = "pip"
  #   ansible.playbook = "/vagrant/playbook/setup.yml"
  #   ansible.inventory_path = '/vagrant/playbook/hosts'
  #   ansible.limit = 'localhost'
  # end
end
