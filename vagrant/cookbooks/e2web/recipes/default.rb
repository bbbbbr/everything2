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

template '/etc/apache2/conf.d/everything' do
  owner "root"
  group "root"
  mode "0755"
  action "create"
  source 'everything.erb'
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

service 'apache2' do
  supports :status => true, :restart => true, :reload => true
end
