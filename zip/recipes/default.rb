#
# Cookbook Name:: zip
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

zip_pkgs = value_for_platform(
  "default" => ["zip"]
)

zip_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end
