#
# Cookbook Name:: lcm
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#default['lcm']['oracleuser']['home'] = '/home/oracle'
#default['lcm']['oracleuser']['password'] = 'Welcome01'
#default['lcm']['jdkpath'] = '/home/oracle/jdk'
#default['lcm'][''] = ''

##{node['apache']['default_site_name']}


execute "update package index" do
  command "yum -y update"
  ignore_failure true
  user 'root'  
end

# X related packages
%w{Xorg xauth xdpyinfo xorg-x11-utils}.each do |pkg|
  package pkg do
    action :install
  end
end


%w{compat-libstdc++-33 compat-libstdc++-33.i686 elfutils-libelf-devel glibc glibc-devel glibc-headers libaio libaio-devel libaio-devel.i686 libaio.i686 libstdc++-devel libstdc++.i686 unixODBC-devel oracle-rdbms-server-11gR2-preinstall}.each do |pkg|
  package pkg do
    action :install
  end
end

#oracle-rdbms-server-11gR2-preinstall.x86_64

user_account 'oracle' do
  ssh_keygen true
  password 'Welcome01'
end
# copy vagrant's authorized_keys file into oracle's .ssh directory
# this will allow us to "vagrant ssh -- -l oracle" directly
file "#{node['lcm']['oracleuser']['home']}/.ssh/authorized_keys" do
  owner 'oracle'
  group 'oinstall'
  mode 0600
  content ::File.open("/home/vagrant/.ssh/authorized_keys").read
  action :create
end


#template '/tmp/file.txt' do
#  source 'file.txt.erb'
#end

#puts 'Verifying zip files'
# use md5sum to compare the zips provided with their expected fingerprint
execute 'verify zip checksums' do
  user 'oracle'
  cwd '/software'
  command 'md5sum -c /vagrant/md5sums'
  # if we have already extracted the zips then don't bother checking the checksums
  not_if { ::File.exists?("/var/tmp/installers")}
end



Dir[ "/software/*.zip" ].each do |curr_path|
  execute "extract #{curr_path}" do
    command "unzip -n #{curr_path}"
    cwd '/var/tmp'
    user 'oracle'
  end
end

#%w{rover fido bubbers}.each do |pet_name|
#  execute "feed_pet_#{pet_name}" do
#    command "echo 'Feeding: #{pet_name}'; touch '/tmp/#{pet_name}'"
#    not_if { ::File.exists?("/tmp/#{pet_name}")}
#  end
#end

execute 'copy jdk to ~' do
  user "oracle"
  command "cp -Ra /var/tmp/jdk #{node['lcm']['oracleuser']['home']}"
  not_if {::Dir.exist?(node['lcm']['oracleuser']['home']+"/jdk")}
  #not_if {::Dir.exist?('/home/oracle/jdk')}
end

bash "append to bash_profile" do
  user "oracle"
  code <<-EOF
    echo 'export JAVA_HOME=~/jdk' >> ~oracle/.bash_profile
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~oracle/.bash_profile
  EOF
  not_if "grep -q JAVA_HOME ~oracle/.bash_profile"
end

#execute "create central inventory" do
#  user "root"
#  command "./stage/Response/createCentralInventory.sh /home/oracle/oraInventory oinstall"
#  cwd "/var/tmp/installers/iamsuite/Disk1"
#  #cwd "/var/tmp/installers/idmlcm/Disk1"
#  not_if { ::File.exists?("/etc/oraInst.loc")}
#end

directory "/home/oracle/appInventory" do
  owner 'oracle'
  group 'oinstall'
  mode '664'
  action :create
end

template '/etc/oraInst.loc' do
  source 'oraInst.loc.erb'
  user "oracle"
  group "oinstall"
  mode "664"
  action :create
end

template '/tmp/db.rsp' do
  source 'db.rsp.erb'
  user "oracle"
  group "oinstall"
  mode "600"
  action :create
  variables(
    :password => node['lcm']['database']['password']
  )
  
end

#execute "install database" do
#  user "oracle"
#  group "dba"
#  command "./runInstaller -silent -responseFile /tmp/db.rsp -waitforcompletion -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs"
#  #command "id > /tmp/whatgroups"
#  cwd "/var/tmp/installers/database/Disk1"
#  not_if { ::Dir.exists?("/home/oracle/app")}
#end

bash "install database" do
  user "root"
  group "dba"
  code <<-EOH
    id > /tmp/whatgroups
    su - oracle -c "/var/tmp/installers/database/Disk1/runInstaller -silent -responseFile /tmp/db.rsp -waitforcompletion -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -ignorePrereq"
  EOH
  not_if { ::Dir.exists?("/home/oracle/app")}
end

execute "execute dbhome_1/root.sh" do
  user "root"
  command "/home/oracle/app/oracle/product/11.2.0/dbhome_1/root.sh"
  not_if { ::File.exists?("/usr/local/bin/dbhome")}
end


#execute "install IDMLCM" do
#  user "oracle"
#  command "./runInstaller -jreLoc /home/oracle/jdk -silent -responseFile /vagrant/cookbooks/lcm/templates/default/idlmcp.rsp.erb -waitforcompletion -invPtrLoc /etc/oraInst.loc"
#  cwd "/var/tmp/installers/idmlcm/Disk1"
#  not_if { ::Dir.exists?("/home/oracle/Middleware/Oracle_IDMLCM1")}
#end

bash "install IDMLCM" do
  user "oracle"
  code <<-EOH
    /var/tmp/installers/idmlcm/Disk1/runInstaller -jreLoc /home/oracle/jdk -silent -responseFile /vagrant/cookbooks/lcm/templates/default/idlmcp.rsp.erb -waitforcompletion -invPtrLoc /etc/oraInst.loc
  EOH
  not_if { ::Dir.exists?("/home/oracle/Middleware/Oracle_IDMLCM1")}
end

