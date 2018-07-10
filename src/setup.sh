#!/bin/bash
# include parse_yaml function
exec > >(tee trace.log) 2>&1
exec 2> >(tee error.log)

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

readonly base_file=`readlink -f "$0"`
readonly base_path=`dirname $base_file`
. "$base_path/tool/parse_yaml.sh"



# read yaml file
eval $(parse_yaml "$base_path/config/config.yaml" "config_")


# Setup hostname
hostname_conf(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Setup Hostname " && sleep 2s
    hostnamectl set-hostname $config_host_hostname
}

pre_setup_install(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Install required package " && sleep 2s
    yum install -y epel-release
    var=$(echo $config_package_lists | tr " " "\n")
    for x in $var
    do
        echo -e "\n"
        echo "[${red} Installing ${reset}] $x" 
        yum install -y $x
    done  
    chmod +x tool/*
}

## setup ip interface
ip_conf(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Setup IP CONFIG " && sleep 2s

    var=$(echo $config_network_interface | tr " " "\n")
    for x in $var
    do
        echo "[${red} Setup interface ${reset}]  $x"            
        temp_ip=config_network_"$x"_ip
        var_ip=${!temp_ip}
        #echo $var_ip       
        if [ ! -z $var_ip ]; then
            nmcli c modify $x ipv4.addresses $var_ip
        fi

        temp_gateway=config_network_"$x"_gateway
        var_gw=${!temp_gateway} 
        #echo $var_gw
        if [ ! -z $var_gw ]; then
            nmcli c modify $x ipv4.gateway $var_gw
        fi

        temp_dns=config_network_"$x"_dns
        var_dns=${!temp_dns} 
        #echo $var_dns
        if [ ! -z $var_dns ]; then
            nmcli c modify $x ipv4.dns $var_dns
        fi

        nmcli c modify $x ipv4.method manual
        nmcli con mod $x connection.autoconnect yes
    done      
    service network restart
}

## setup selinux
selinux_conf(){    
    echo -e "\n"
    echo "[${green} Notification ${reset}] Setup SELinux" && sleep 2s
    setenforce 0
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
}

## setup hostfile
host_file_conf(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Setup Host File" && sleep 2s    
    var=$(echo $config_hostfile_hosts | tr " " "\n")
    for x in $var
    do
        echo "[${red} Setup host ${reset}]  $x"        
        temp_ip_host=config_hostfile_"$x"_ip
        var_ip=${!temp_ip_host}           
        ./tool/manage-etc-hosts.sh add $x $var_ip       
    done          
}

# setup firewalld
firewalld_conf(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Setup Firewalld " && sleep 2s
    systemctl stop firewalld
    systemctl disable firewalld
}

# check hosts node
host_checks(){
    echo -e "\n"
    echo "[${green} Notification ${reset}] Checking list host " && sleep 2s
    
    var=$(echo $config_host_checkhosts | tr " " "\n")
    for x in $var
    do
        echo "[${red} Check host ${reset}] $x" 
        fping -u $x >& /dev/null
        if [ $? -eq 0 ]; then
            echo $x host is up
        else
            echo $x host is down
        fi
    done  
}

# RUN
echo "WELCOME TO SCRIPT SETUP HOST CENTOS 7" && sleep 2s

echo "-------------------------------------------" && sleep 2s


hostname_conf

pre_setup_install

ip_conf

selinux_conf

host_file_conf

firewalld_conf

host_checks