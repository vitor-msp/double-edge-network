# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  IP_ERP="130.214.229.163" #ip example
  IP_DEFAULT_EDGE = "192.168.100.1"
  LAN_DEFAULT_EDGE = "192.168.100.0/24"
  IP_ERP_EDGE = "192.168.200.1"
  LAN_ERP_EDGE = "192.168.200.0/24"
  IP_ROUTER_LAN_DEFAULT = "192.168.100.2"
  IP_ROUTER_LAN_ERP = "192.168.200.2"

  ##### DEFAULT EDGE #####
  config.vm.define "default-edge" do |default|
    default.vm.box = "ubuntu/trusty64"
    default.vm.hostname = "default-edge"
    # eth1
    default.vm.network "private_network", ip: IP_DEFAULT_EDGE, netmask: 24, virtualbox__intnet: true
    # eth2
    default.vm.network "public_network", use_dhcp_assigned_default_route: true
    default.vm.provider "virtualbox" do |vb|
      vb.name = "default-edge"
      vb.memory = "512"
      vb.cpus = 2
    end
    default.vm.provision "shell", run: "always", path: "./scripts/init-config-edges.sh", args: LAN_DEFAULT_EDGE
  end

  ##### ERP EDGE #####
  config.vm.define "erp-edge" do |erp|
    erp.vm.box = "ubuntu/trusty64"
    erp.vm.hostname = "erp-edge"
    # eth1
    erp.vm.network "private_network", ip: IP_ERP_EDGE, netmask: 24, virtualbox__intnet: true
    # eth2
    erp.vm.network "public_network", use_dhcp_assigned_default_route: true
    erp.vm.provider "virtualbox" do |vb|
      vb.name = "erp-edge"
      vb.memory = "512"
      vb.cpus = 2
    end
    erp.vm.provision "shell", run: "always", path: "./scripts/init-config-edges.sh", args: LAN_ERP_EDGE
  end
  
  ##### ROUTER #####
  config.vm.define "router" do |router|
    router.vm.box = "ubuntu/trusty64"
    router.vm.hostname = "router"
    # eth1
    router.vm.network "private_network", ip: IP_ROUTER_LAN_DEFAULT, netmask: 24, virtualbox__intnet: true
    # eth2
    router.vm.network "private_network", ip: IP_ROUTER_LAN_ERP, netmask: 24, virtualbox__intnet: true
    router.vm.provider "virtualbox" do |vb|
      vb.name = "router"
      vb.memory = "512"
      vb.cpus = 2
    end
    router.vm.provision "file", source: "./scripts/router.sh", destination: "/home/vagrant/scripts/router.sh"
    router.vm.provision "shell" do |sh|
      sh.args = [IP_ERP, IP_ERP_EDGE, IP_DEFAULT_EDGE, IP_ROUTER_LAN_DEFAULT, IP_ROUTER_LAN_ERP]
      sh.inline = <<-SHELL
        sudo chown root:root /home/vagrant/scripts/router.sh
        sudo chmod +x /home/vagrant/scripts/router.sh
        sudo echo "* *    * * *   root /home/vagrant/scripts/router.sh \
          $1 $2 $3 $4 $5 \
          > /dev/null 2>&1" >> /etc/crontab
        sudo apt update
        sudo apt install -y traceroute
      SHELL
    end
  end
end
