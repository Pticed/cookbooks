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

directory "/var/lib/tomcat6/webapps/xwiki" do
  owner "tomcat6"
  group "tomcat6"
  action :create
end

directory node['xwiki']['database_path'] do
  owner "tomcat6"
  group "tomcat6"
  action :create
  recursive true
end

directory node['xwiki']['data_path'] do
  owner "tomcat6"
  group "tomcat6"
  action :create
  recursive true
end

execute "extract" do
  command "unzip /tmp/#{warFile}"
  creates "/var/lib/tomcat6/webapps/xwiki/WEB-INF"
  cwd "/var/lib/tomcat6/webapps/xwiki"
end

cookbook_file "/var/lib/tomcat6/webapps/xwiki/WEB-INF/lib/hsqldb.jar" do
  owner "tomcat6"
  group "tomcat6"
  mode "0644"
end

template "/var/lib/tomcat6/webapps/xwiki/WEB-INF/hibernate.cfg.xml" do
  source "hibernate.cfg.xml.erb"
  owner "tomcat6"
  group "tomcat6"
  mode "0644"
end

if node["xwiki"]["setup_proxy"]
  require_recipe 'apache2::mod_proxy_ajp'
  web_app "xwiki" do
    template "xwiki.proxy.erb"
    path "xwiki"
  end
end

