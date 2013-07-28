#
# Cookbook Name:: e2web
# Recipe:: default
#
# Copyright 2012, Everything2 Media LLC
#
# You are free to use/modify these files under the same terms as the Everything Engine itself

package 'gnupg'

template '/etc/apt/sources.list.d/e2apt.list' do
  owner "root"
  group "root"
  mode "0755"
  action "create"
  source "e2apt.list.erb"
end

cookbook_file '/etc/apt/e2apt.pub.gpg' do
  owner "root"
  group "root"
  mode "0755"
  action :create_if_missing
end

execute "Add e2apt key" do
  command "apt-key add /etc/apt/e2apt.pub.gpg"
end

execute "apt-get update" do
  command "apt-get update"
end

package 'liblinux-pid-perl'

to_install = [
    'apache2-mpm-prefork',
    'libapache2-mod-perl2',
]

to_install.each do |p|
  package p
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

service 'apache2' do
  supports :status => true, :restart => true, :reload => true
end
