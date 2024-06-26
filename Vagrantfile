require_relative 'control'

Vagrant.configure("2") do |config|
  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = false

  config.vm.boot_timeout = 600

  (1..NUM_MASTERS).each do |i|
    config.vm.define "kube-master-#{i}" do |node|
      node.vm.hostname = "kube-master-#{i}"
      node.vm.network "private_network", ip: "#{MASTER_IP_START.split('.')[0..2].join('.')}." + "#{MASTER_IP_START.split('.')[3].to_i + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kube-master-#{i}"
        vb.memory = MASTER_MEMORY
        vb.cpus = MASTER_CPU
        #vb.gui = true
      end
      # Copy post_setup.sh on the load balancer node
      node.vm.provision "file", source: "./post_setup.sh", destination: "/home/vagrant/post_setup.sh"
      node.vm.provision "shell", inline: "sudo cp /home/vagrant/post_setup.sh /root"
      node.vm.provision "shell", inline: "sudo chown root: /root/post_setup.sh"
      node.vm.provision "shell", inline: "sudo chmod +x /root/post_setup.sh"
    end 
  end

  (1..NUM_WORKERS).each do |i|
    config.vm.define "kube-worker-#{i}" do |node|
      node.vm.hostname = "kube-worker-#{i}"
      node.vm.network "private_network", ip: "#{WORKER_IP_START.split('.')[0..2].join('.')}." + "#{WORKER_IP_START.split('.')[3].to_i + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "kube-worker-#{i}"
        vb.memory = WORKER_MEMORY
        vb.cpus = WORKER_CPU
        #vb.gui = true

        # Ensure the existing file is removed before creating a new one
        disk_filename = "kube-worker-#{i}-newdisk.vdi"
        #vb.customize ["closemedium", "disk", disk_filename, "--delete"]
        
        unless File.exist?(disk_filename)
          vb.customize ["createhd", "--filename", disk_filename, "--size", 51200]
        end
        
        #vb.customize ["storagectl", :id, "--name", "SATAControllerWorker#{i}", "--add", "sata", "--controller", "IntelAHCI"]
        vb.customize ["storageattach", :id, "--storagectl", "SCSI", "--port", 3, "--device", 0, "--type", "hdd", "--medium", disk_filename]

        # Set the boot order to boot from the existing disk at SCSI port 1
        vb.customize ["modifyvm", :id, "--boot1", "disk"]
        #vb.customize ["modifyvm", :id, "--scsi1", "disk"]
      end
    end
  end

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provision "shell", inline: "sudo echo '127.0.0.1 localhost\n\n' > /etc/hosts"
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
