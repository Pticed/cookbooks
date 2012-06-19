#
# Cookbook Name:: owncloud
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "php"
include_recipe "php::module_gd"
include_recipe "php::module_mysql"
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "mysql::server"
include_recipe "database"

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# generate all passwords
node.set_unless['owncloud']['admin_password'] = secure_password
node.set_unless['owncloud']['db_password']   = secure_password

cookbook_file "/tmp/owncloud-4.0.2.tar.bz2"

execute "tar -xjf /tmp/owncloud-4.0.2.tar.bz2" do
  cwd "/var/www"
  creates "/var/www/owncloud"
end

directory "/var/www/owncloud/data" do
  owner node["apache"]["user"]
  group node["apache"]["group"]
end

#needed for vagrant as it installs a ruby in /opt and thus the mysql package does not install its gem for this ruby installation
gem_package "mysql" do
  action :install
end

mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

database node["owncloud"]["db_name"] do
   connection mysql_connection_info
   provider Chef::Provider::Database::Mysql
   action :create
end

database_user node["owncloud"]["db_user"] do
  connection mysql_connection_info
  provider Chef::Provider::Database::MysqlUser
  password node["owncloud"]["db_password"]
  action :create
end

database_user node["owncloud"]["db_user"] do
  connection mysql_connection_info
  provider Chef::Provider::Database::MysqlUser
  database_name node["owncloud"]["db_name"]
  privileges [:all] 
  action :grant
end

template "/var/www/owncloud/config/autoconfig.php" do
  source "autoconfig.php.erb"
  owner node["apache"]["user"]
  group node["apache"]["group"]
  mode "0644"
end

# TODO use web_app to configure apache2
# web_app "owncloud" do
#   template "owncloud.conf.erb"
#   docroot ...
#   server_name ...
# end
