# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "public_network", type: "dhcp"

  config.vm.provision "shell", path: "vagrant-support/bootstrap-sudo.sh"
  config.vm.provision "shell", privileged: false, path: "vagrant-support/bootstrap.sh"

end
