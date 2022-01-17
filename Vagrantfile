# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.box_version = "202112.19.0"

  config.ssh.insert_key = false
  config.ssh.forward_agent = true

  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 3001, host: 3001
  config.vm.network "forwarded_port", guest: 7900, host: 7900

  # config.vm.network "private_network", ip: "192.168.33.10"
  # config.vm.network "public_network"

  config.vm.synced_folder ".", "/vagrant", disabled: true # /vagrantをマウントしないようにするため
  config.vm.synced_folder "./playbook", "/vagrant/playbook"

  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end

  # config.vm.provision "ansible_local" do |ansible|
  #   ansible.install_mode = "pip"
  #   ansible.version = "latest"
  #   ansible.verbose = true
  #   ansible.playbook = "/vagrant/playbook/setup.yml"
  #   ansible.inventory_path = '/vagrant/playbook/hosts'
  #   ansible.limit = 'localhost'
  # end
end
