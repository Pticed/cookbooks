#
# Cookbook Name:: xwiki
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

require_recipe 'tomcat'
require_recipe 'zip'

warFile="xwiki-enterprise-web-3.5.1.war"

cookbook_file "/tmp/#{warFile}"

# Data folder
directory node['xwiki']['data_path'] do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  action :create
  recursive true
end

# Xwiki installation
directory "/var/lib/tomcat6/webapps/xwiki" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  action :create
end

execute "extract" do
  command "unzip /tmp/#{warFile}"
  creates "/var/lib/tomcat6/webapps/xwiki/WEB-INF"
  cwd "/var/lib/tomcat6/webapps/xwiki"
end

# JDBC driver installation
jdbc_driver = case node['xwiki']['db_type']
when "hsqldb"
  "hsqldb.jar"
when "mysql"
  "mysql-connector-java-5.1.20-bin.jar"
else
  "mysql-connector-java-5.1.20-bin.jar"
end

cookbook_file "/var/lib/tomcat6/webapps/xwiki/WEB-INF/lib/#{jdbc_driver}" do
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0644"
end

# Datasource configuration
template "/var/lib/tomcat6/webapps/xwiki/WEB-INF/hibernate.cfg.xml" do
  source "hibernate.cfg.xml.erb"
  owner node["tomcat"]["user"]
  group node["tomcat"]["group"]
  mode "0644"
end

if node["xwiki"]["db_type"]=="hsqldb" then
  directory node['xwiki']['database_path'] do
    owner node["tomcat"]["user"]
    group node["tomcat"]["group"]
    action :create
    recursive true
  end
elsif node["xwiki"]["db_type"]=="mysql" then
  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

  # generate all passwords
  node.set_unless['xwiki']['db_password'] = secure_password

  mysql_connection_info = {:host => "localhost", :username => 'root', :password => node['mysql']['server_root_password']}

  database node["xwiki"]["db_name"] do
    connection mysql_connection_info
    provider Chef::Provider::Database::Mysql
    action :create
  end

  database_user node["xwiki"]["db_user"] do
    connection mysql_connection_info
    provider Chef::Provider::Database::MysqlUser
    host node["xwiki"]["db_host"]
    password node["xwiki"]["db_password"]
    action :create
  end

  database_user node["xwiki"]["db_user"] do
    connection mysql_connection_info
    provider Chef::Provider::Database::MysqlUser
    database_name node["xwiki"]["db_name"]
    host node["xwiki"]["db_host"]
    privileges [:all]
    action :grant
  end

end

# Proxy configuration
if node["xwiki"]["setup_proxy"]
  require_recipe 'apache2::mod_proxy_ajp'
  web_app "xwiki" do
    template "xwiki.proxy.erb"
    path "xwiki"
  end
end

