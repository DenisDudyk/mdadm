#!/usr/bin/ruby
# Describe VMs

home = ENV['HOME']

MACHINES = {
  # VM name "Working with the mdadm command"
  :"mdadm-comand" => {
        # VM box
        :box_name => "centos/7",

        # VM CPU count
        :cpus => 2,

        # VM RAM size (Mb)
        :memory => 1048,

        # networks
        :net => [],

		# forwarded ports
        :forwarded_port => [],

		# add disk
		:disks => {
			:count => 6,
			:medium => home + '/VirtualBox VMs/sata_raid_mdadm_{i}.vdi',
			:size => 250,
			:start_port => 0
			
		}
	}
}

Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
    # Disable shared folders
    config.vm.synced_folder ".", "/vagrant", disabled: true

    # Apply VM config
    config.vm.define boxname do |box|
			# Set VM base box and hostname
			box.vm.box = boxconfig[:box_name]
			box.vm.host_name = boxname.to_s

			# Additional network config if present
			if boxconfig.key?(:net)
				boxconfig[:net].each do |ipconf|
					box.vm.network "private_network", ipconf
				end
			end

			# Port-forward config if present
			if boxconfig.key?(:forwarded_port)
				boxconfig[:forwarded_port].each do |port|
					box.vm.network "forwarded_port", port
				end
			end

			# VM resources config
			box.vm.provider "virtualbox" do |v|
				# SetVM RAM size and CPU count
				v.memory = boxconfig[:memory]
				v.cpus = boxconfig[:cpus]

			
				if boxconfig.key?:disks
					
					f_added_discs = false
					
					(1..boxconfig[:disks][:count]).each  do |i|
						unless File.exist?(boxconfig[:disks][:medium].sub('{i}', i.to_s))
								# puts boxconfig[:disks][:medium].sub('{i}', i.to_s)
								v.customize ['createhd', '--filename', boxconfig[:disks][:medium].sub('{i}', i.to_s), '--variant', 'Fixed', '--size', boxconfig[:disks][:size]]
								f_added_discs = true
						end
					end	
					
					if f_added_discs == true
						v.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
					
						(1..boxconfig[:disks][:count]).each  do |i|
							v.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', i, '--device', 0, '--type', 'hdd', '--medium', boxconfig[:disks][:medium].sub('{i}', i.to_s)]
						end	
					end	
					
				end
			end
			
			config.vm.provision "shell",
				path: "raid.sh"
    end
  end
end
