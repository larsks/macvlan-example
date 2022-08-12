Vagrant.configure("2") do |config|
  config.vm.box = "fedora/36-cloud-base"
  config.vm.box_version = "36-20220504.1"

  config.vm.provider :libvirt do |libvirt|
    libvirt.uri = "qemu:///system"
    libvirt.memory = 4096
    libvirt.storage :file, :type => 'qcow2'
  end

  N = 2
  (1..N).each do |machine_id|
    config.vm.define "node#{machine_id}" do |machine|
      machine.vm.hostname = "node#{machine_id}"
      machine.vm.network :private_network,
        :libvirt__network_name => "macvlan-example",
        :libvirt__dhcp_enabled => false,
        :libvirt__netmask => "255.255.255.0",
        :libvirt__host_ip => "192.168.133.1"
      machine.vm.provision "shell", path: "provision.sh"
    end
  end
end
