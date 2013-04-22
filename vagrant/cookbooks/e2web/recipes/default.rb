#
# Cookbook Name:: e2web
# Recipe:: default
#
# Copyright 2012, Everything2 Media LLC
#
# You are free to use/modify these files under the same terms as the Everything Engine itself

to_install = [
    'apache2-mpm-prefork',
    'libapache2-mod-perl2',
]

to_install.each do |p|
  package p
end

cookbook_file '/tmp/Apache2-SizeLimit-2.0.7.tar.gz' do
  source 'Apache2-SizeLimit-2.0.7.tar.gz'
  mode 0700
  owner "root"
  group "root"
end

cookbook_file '/tmp/Linux-Pid-0.04.tar.gz' do
  source 'Linux-Pid-0.04.tar.gz'
  mode 0700
  owner "root"
  group "root"
end

template '/etc/apache2/conf.d/everything' do
  owner "root"
  group "root"
  mode "0755"
  action "create"
  source 'everything.erb'
  notifies :reload, "service[apache2]", :delayed
end

template '/etc/apache2/mod_rewrite.conf' do
  owner "root"
  group "root"
  mode "0755"
  action "create"
  source "mod_rewrite.conf.erb"
  notifies :reload, "service[apache2]", :delayed
end

template '/etc/apache2/apache2.conf' do
  owner "root"
  group "root"
  mode "0755"
  action "create"
  source 'apache2.conf.erb'
  notifies :reload, "service[apache2]", :delayed
  variables(node["e2web"])
end

link '/etc/apache2/mods-enabled/rewrite.load' do
  action "create"
  to "../mods-available/rewrite.load"
  link_type :symbolic
  owner "root"
  group "root"
end

link '/etc/apache2/mods-enabled/proxy.load' do
  action "create"
  to "../mods-available/proxy.load"
  link_type :symbolic
  owner "root"
  group "root"
end

link '/etc/apache2/mods-enabled/proxy_http.load' do
  action "create"
  to "../mods-available/proxy_http.load"
  link_type :symbolic
  owner "root"
  group "root"
end

file '/etc/logrotate.d/apache2' do
  action "delete"
  notifies :reload, "service[apache2]", :delayed
end

# Also in e2cron, e2web
logdir = "/var/log/everything"
datelog = "`date +\\%Y\\%m\\%d\\%H`.log"

directory logdir do
  owner "www-data"
  group "root"
  mode 0755
  action :create
end

cron 'log_deliver_to_s3.pl' do
  minute '5'
  command "/var/everything/tools/log_deliver_to_s3.pl 2>&1 >> #{logdir}/e2cron.log_deliver_to_s3.#{datelog}"
end

# Remove this and the file above when this is fixed
# https://bugs.launchpad.net/ubuntu/+source/libapache2-mod-perl2/+bug/898124
execute "fix-ubuntu-apache2-SizeLimit" do
  command "cd /usr/lib/perl5/ && tar xzvf /tmp/Apache2-SizeLimit-2.0.7.tar.gz && rm -f /tmp/Apache2-SizeLimit-2.0.7.tar.gz"
  not_if { ::File.exists?("/usr/lib/perl5/Apache/SizeLimit/Core.pm")}
end

# Ubuntu also doesn't provide linux-pid, which is a requirement for Apache2::SizeLimit
execute "install-linux-pid-from-cpan" do
  command "cd /tmp && tar xzvf Linux-Pid-0.04.tar.gz && cd Linux-Pid-0.04 && perl Makefile.PL && make && make install"
  not_if { ::File.exists?("/usr/local/lib/perl/5.14.2/Linux/Pid.pm")}
end

service 'apache2' do
  supports :status => true, :restart => true, :reload => true
end
