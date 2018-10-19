#!/bin/bash
# Author: Nguyen Ngoc Tai
# Email: nguyenngoctaibp@gmail.com
# github: https://github.com/tainguyenbp

# Global variable
OS_DISTRO="Unknow"
OS_CENTOS_STAND="7.0"

function setup_snmp_centos(){

	yum -y install net-snmp net-snmp-devel net-snmp-utils bzip2-devel newt-devel lm_sensors-devel
}

function config_snmpv2_centos(){

	
}

function setup_snmp_ubuntu(){

	sudo apt-get install snmp snmp-mibs-downloader
}


function main() {

	if [[ -f /etc/redhat-release ]];
		then
			OS_DISTRO="Centos"
			OS_DISTRO_VER=$(grep -oE '[0-9]+\.[0-9]+' /etc/redhat-release)
	
			if [ "$OS_DISTRO_VER" \> "$OS_CENTOS_STAND" ];
					then
						# setup service snmp on centos 7.x
						setup_snmp_centos
						
			elif [ "$OS_DISTRO_VER" \< "$OS_CENTOS_STAND" ];
					then
                                                # setup service snmp on centos 5.x to 6.x
                                                setup_snmp_centos

			else
					 # setup service snmp on centos 7.x
                                                setup_snmp_centos
			fi
	
	elif [[ -f /etc/lsb-release ]];
		then
			OS_DISTRO="Ubuntu"
			OS_DISTRO_VER="$(grep "DISTRIB_RELEASE" /etc/lsb-release | awk -F'=' '{print $2}' | sed 's/[[:blank:]]//g')"
	
			if [[ -z ${OS_DISTRO_VER} ]] || [[ ${OS_DISTRO_VER} == "" ]];
				then
					OS_DISTRO_VER=$(lsb_release -a | grep -i "Release" | awk -F':' '{print $2}' | sed 's/[[:blank:]]//g')
			fi
	
	elif [[ -f /etc/debian_version ]];
		then
			OS_DISTRO="Debian"
			OS_DISTRO_VER="$(cat /etc/debian_version | sed 's/[[:blank:]]//g')"
	
			if [[ -z ${OS_DISTRO_VER} ]] || [[ ${OS_DISTRO_VER} == "" ]];then
				OS_DISTRO_VER=$(lsb_release -a | grep -i "Release" | awk -F':' '{print $2}' | sed 's/[[:blank:]]//g')
			fi
	fi
}

main
