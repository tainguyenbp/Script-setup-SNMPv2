#!/bin/bash
# Author: Nguyen Ngoc Tai
# Email: nguyenngoctaibp@gmail.com
# github: https://github.com/tainguyenbp

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

# Global variable
OS_DISTRO="Unknow"
OS_CENTOS_STAND="7.0"
PATH_FILE_SNMP="/etc/snmp/snmpd.conf"


function setup_snmp_centos(){

	yum -y install net-snmp net-snmp-devel net-snmp-utils bzip2-devel newt-devel lm_sensors-devel
}

function enable_restart_snmp_centos6(){

	# turn on service start up witch linux	
	chkconfig snmpd on
	# restart service snmpd
	/etc/init.d/snmpd restart
}

function enable_restart_snmp_centos7(){

	# enable service startup with linux
	systemctl enable snmpd
	# restart service snmpd
	systemctl restart snmpd
}

function config_snmpv2_centos(){

	year=$(date +"%Y")
	month=$(date +"%m")
	day=$(date +"%d")

	hour=$(date +"%H")
	munites=$(date +"%M")
	second=$(date +"%S")

	hms=$hour$munites$second
	ymd=$year$month$day

	value_systemview=`grep "view    systemview    included   .1" "$PATH_FILE_SNMP" | grep -v "view    systemview    included   .1.3.6.1.2.1.25.1.1" | grep -v "view    systemview    included   .1.3.6.1.2.1.1" | wc -l`
		if [ -f "$PATH_FILE_SNMP" ]
			then
				echo "File $PATH_FILE_SNMP found !!!"
				# Backup file snmpd.conf 
				cp "$PATH_FILE_SNMP" "$PATH_FILE_SNMP"_backup_"$ymd"_"$hms"
				if [ "$value_systemview" == 0 ]
				then
					echo "Add string: view    systemview    included   .1"
					sed -i '/view    systemview    included   .1.3.6.1.2.1.25.1.1/a\view    systemview    included   .1' "$PATH_FILE_SNMP"
				
				else
					echo "String: view    systemview    included   .1"
				fi
	value_community=`grep "com2sec notConfigUser  default       " /etc/snmp/snmpd.conf | wc -l`
		read -p 'Enter string community authentication SNMPv2 : ' string_snmpv2

				if [ "$value_community" = 0 ]
					then
					 echo "Add string community authentication SNMPv2 to file $PATH_FILE_SNMP"
					 sed -i '/com2sec notConfigUser  default       /c \com2sec notConfigUser  default       '$string_snmpv2'' "$PATH_FILE_SNMP"
				else
					echo "Add string community authentication SNMPv2 to file $PATH_FILE_SNMP"	
					sed -i '/com2sec notConfigUser  default       /c \com2sec notConfigUser  default       '$string_snmpv2'' "$PATH_FILE_SNMP"
				fi
				
		else
			echo "File $PATH_FILE_SNMP not found !!!"
		fi	
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
						config_snmpv2_centos
						enable_restart_snmp_centos7
						
			elif [ "$OS_DISTRO_VER" \< "$OS_CENTOS_STAND" ];
					then
                                                # setup service snmp on centos 5.x to 6.x
                                                setup_snmp_centos
						config_snmpv2_centos
						enable_restart_snmp_centos6

			else
					 # setup service snmp on centos 7.x
                                                setup_snmp_centos
						config_snmpv2_centos
						enable_restart_snmp_centos7
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
