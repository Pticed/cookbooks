#
# Cookbook Name:: init
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node["platform"]=="ubuntu"
  execute "update package index" do
    command "apt-get update"
    ignore_failure true
    action :run
  end
end