#!/bin/sh

# check preconditions
command_name="tailscale"
command -v $command_name >/dev/null 2>&1 || { 
    echo >&2 "$command_name is required but it's not installed. exiting."
    exit 1 
}

command_name="docker"
command -v $command_name >/dev/null 2>&1 || { 
    echo >&2 "$command_name is required but it's not installed. exiting."
    exit 1 
}

command_name="docker-compose"
command -v $command_name >/dev/null 2>&1 || { 
    echo >&2 "$command_name is required but it's not installed. exiting."
    exit 1 
}

# get domain name in tailnet
host_name=$(hostname)
tailnet_name=".tail80de.ts.net"
domain_name=${host_name}${tailnet_name}

# generate ssl certificate
tailscale cert domain_name
cert_file=${domain_name}".crt"
key_file=${domain_name}".key"

if [ ! -f $cert_file ] || [ ! -f $key_file ]
then
    echo "Fail to generate cert. exiting."
    exit 1 
fi

# replace example.com in docker-compose.yml with real domain
sed -i "s/example\.com\-ssl\.crt/$cert_file/g" docker-compose.yml
sed -i "s/example\.com\-ssl\.key/$key_file/g" docker-compose.yml

# # replace example.com in nginx.conf with real domain
sed -i "s/example\.com/$domain_name/g" nginx_proxy.conf
sed -i "s/example\.com\-ssl\.crt/$cert_file/g" nginx_proxy.conf
sed -i "s/example\.com\-ssl\.key/$key_file/g" nginx_proxy.conf

# # start instance
docker-compose up -d
