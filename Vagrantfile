# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "OEL6_6"


  config.vm.hostname = "lcmdemo.oracleateam.com"
  config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
  #config.vm.synced_folder "/Users/cmj/Downloads/Software/Oracle/IAM/11.1.2.3/LCM", "/software", :mount_options => ["dmode=555","fmode=555"]
  config.vm.synced_folder "software", "/software", :mount_options => ["dmode=555","fmode=555"]

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "8192"]
    vb.customize ["modifyvm", :id, "--name"  , "lcmdemo"]
    vb.customize ["modifyvm", :id, "--cpus"  , 2]
  end
  
  # if you want the VM to have a specific IP address do that here
  #config.vm.network "private_network", ip: "192.168.33.10"

  # for the purposes of a simple demo we are going to use a script provisioner
  config.vm.provision "shell", inline: <<-SHELL
    # this is not recommended since it usually results in a new kernel
    # and you'd want to reboot after that
    #yum -y update
    # instead ssh in later and yum update by hand
    
    echo "Running shell provisioner as:" `whoami`
    #rpm -U /vagrant/chef-12.3.0-1.el6.x86_64.rpm
  SHELL
  
  config.vm.provision "chef_solo" do |chef|
    #chef.log_level = "Debug"
    chef.verbose_logging = "true"
    
    # we're going to put "official" cookbooks in "cookbooks"
    # and my own in my_cookbooks
    #chef.cookbooks_path = ["cookbooks", "my_cookbooks"]
    chef.add_recipe "lcm"
    #chef.json = {
    #  :apache => { :default_site_enabled => true }
    #}
    chef.json = {
      :lcm => { 
        :oracleuser => {
          :home => "/home/oracle",
          :password => "Welcome01"
        },
        :jdkpath => "/home/oracle/jdk",
        :database => {
          :dbhome => "/home/oracle/database",
          :password => "Welcome01"
        }
      }
    }
            
  end
  
end
