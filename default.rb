#
# Cookbook Name:: open-resty
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Install prerequisite packages
%w{libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential}.each do |pkg|
  package pkg do
    action :install
  end
end

# Download openresty installation package
remote_file "#{Chef::Config[:file_cache_path]}/openresty-1.9.7.4.tar.gz" do
  source "https://openresty.org/download/openresty-1.9.7.4.tar.gz"
  action :create_if_missing
end

# Decompress file and make install
bash "compile_openresty_source" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar zxf openresty-1.9.7.4.tar.gz
    cd openresty-1.9.7.4
    ./configure \
    --with-http_stub_status_module
    make
    make install
  EOH
end

# Setup $PATH:/usr/local/openresty/nginx/sbin in etc/profile
bash "setup_openresty_nginx_path" do
  code <<-EOS
    sudo echo "export PATH=$PATH:/usr/local/openresty/nginx/sbin" >> /etc/profile
  EOS
  not_if "grep -q export PATH=$PATH:/usr/local/openresty/nginx/sbin /etc/profile"
end

# Run nginx-openresty
bash "run_nginx" do
  code <<-EOH
    cd /usr/local/openresty/nginx/sbin
    sudo ./nginx
  EOH
  not_if "ps aux | grep '[n]ginx'"
end
