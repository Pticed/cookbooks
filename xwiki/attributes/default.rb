#
# Cookbook Name:: jetty
# Attributes:: default

default["xwiki"]["database_path"] = "/var/lib/tomcat6/database"
default["xwiki"]["data_path"] = "/var/lib/tomcat6/data"
default["xwiki"]["setup_proxy"] = true
default["xwiki"]["db_host"] = ipaddress
default["xwiki"]["db_type"] = "mysql"
default["xwiki"]["db_name"] = "xwiki"
default["xwiki"]["db_user"] = "xwiki"