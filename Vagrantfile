# Load control file
require_relative 'control'

Vagrant.configure("2") do |config|

  config.vm.provision "shell", path: "bootstrap.sh"
  # Define the box and provider (VirtualBox) with Ubuntu Jammy version 22.04.3
  config.vm.box = "ubuntu/jammy64"
  #config.vm.box_version = "20220120.0.0"
  # Disable box update checks to prevent errors when the box doesn't exist locally
  config.vm.box_check_update = false

  # Define the master nodes
  (1..NUM_MASTERS).each do |i|
    config.vm.define "kube-master-#{i}" do |node|
      node.vm.hostname = "kube-master-#{i}"
      node.vm.network "private_network", ip: "#{MASTER_IP_START.split('.')[0..2].join('.')}." + "#{MASTER_IP_START.split('.')[3].to_i + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kube-master-#{i}"
        vb.memory = MASTER_MEMORY
        vb.cpus = MASTER_CPU
      end
    end 
  end

  # Define the worker nodes
  (1..NUM_WORKERS).each do |i|
    config.vm.define "kube-worker-#{i}" do |node|
      node.vm.hostname = "kube-worker-#{i}"
      node.vm.network "private_network", ip: "#{WORKER_IP_START.split('.')[0..2].join('.')}." + "#{WORKER_IP_START.split('.')[3].to_i + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kube-worker-#{i}"
        vb.memory = WORKER_MEMORY
        vb.cpus = WORKER_CPU
      end
    end
  end
  
  config.vm.provider "virtualbox" do |vb|
    # Add a new storage controller
    vb.customize ["storagectl", :id, "--name", "SATAController", "--add", "sata", "--controller", "IntelAHCI"]
    
    # Attach a new storage device with 50GB size
    vb.customize ["createhd", "--filename", "newdisk.vdi", "--size", 51200] # Size is in MB (50GB here)
    vb.customize ["storageattach", :id, "--storagectl", "SATAController", "--port", 1, "--device", 0, "--type", "hdd", "--medium", "newdisk.vdi"]
  end

  # Enable internet access from VMs
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end
  
  # Update /etc/hosts on each VM to enable communication between them
  config.vm.provision "shell", inline: "sudo echo '127.0.0.1	localhost\n\n' > /etc/hosts"
  config.vm.provision "shell", inline: "sudo sed -i '/kube-master-/d' /etc/hosts"
  config.vm.provision "shell", inline: "sudo sed -i '/kube-worker-/d' /etc/hosts"
  (1..NUM_MASTERS).each do |i|
    master_ip = "#{MASTER_IP_START.split('.')[0..2].join('.')}." + "#{MASTER_IP_START.split('.')[3].to_i + i}"
    config.vm.provision "shell", inline: "sudo echo '#{master_ip} kube-master-#{i} kube-master-#{i}.tedcluster.com' >> /etc/hosts"
  end
  (1..NUM_WORKERS).each do |i|
    worker_ip = "#{WORKER_IP_START.split('.')[0..2].join('.')}." + "#{WORKER_IP_START.split('.')[3].to_i + i}"
    config.vm.provision "shell", inline: "sudo echo '#{worker_ip} kube-worker-#{i} kube-worker-#{i}.tedcluster.com' >> /etc/hosts"
  end


end

