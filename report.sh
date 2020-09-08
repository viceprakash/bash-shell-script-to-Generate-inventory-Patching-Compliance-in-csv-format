#!/bin/bash

print_header(){
	printf "#%0.s" $(seq 1 $(tput cols)) 
	printf "\n"
}
center_msg(){
	msg=$1
	terminalcol=$(tput cols)
	msg_1en=$(echo ${#1})
	pre_space=$(($((terminalcol-msg_len))/2))
	
	print_header
	printf "%0.s" $(seq 1 $pre_space)
	printf "%s" "$1"
	printf "\n"
	print_header
}
check_remotepass(){
	if [ ! -e "remotepass" ]
	then
         center_msg "Please store your password in >>remotepass<< file and retry"
	 exit 1
	fi
}
check_remoteuser(){
	if [ ! -e"remoteuser" ]
	then
	center_msg "Please store your remote user in >>remoteuser<< file and retry"
	exit 2
	fi
}
check_list_of_servers(){
	if [ ! -e "list_of_servers" ]
	then
		center_msg "Please store list of servers in >>list_of_servers<< file and retry"
	fi
}
center_msg "Linux server report"
check_remotepass
check_remoteuser
check_list_of_servers
ssh_opt="sshpass -f remotepass ssh -n -o StrictHostkeyChecking=No -o PubkeyAuthentication=No root"

echo "SERVER_IP,HOST_NAME,OS_TYPE,OS_VERSION,OS_INSTALLED_DATE,SECURITY_NOTICE,BUG_FIX,ENHANCEMENT,FIREWALL_STATUS,SELINUX_STATUS" > SERVER_INFO.csv

while read server
do 
	echo "working on $server"
	OS_TYPE=$($ssh_opt@$server "cat /etc/os-release" | grep -w "NAME" | awk -F "NAME=" '{print $2}' | tr '"' " ") 
        echo "$OS_TYPE" | grep -i "ubuntu" 1>/dev/null 2>&1
	if [ $? -eq 0 ]
	then 
	OS_VERSION=$($ssh_opt@$server "cat /etc/os-release" | grep "VERSION_ID" | awk -F "VERSION_ID=" '{print $2}')
        else
        OS_VERSION=$($ssh_opt@$server "cat /etc/redhat-release" | awk -F "release" '{print $2}'| awk '{print $1}')
	fi
        HOST_NAME=$($ssh_opt@$server "hostname")
        SECURITY_NOTICE=$($ssh_opt@$server yum updateinfo summary | grep 'Security' | grep -v 'Important|Moderate' | tail -1 | awk '{print $1}')
	BUG_FIX=$($ssh_opt@$server yum updateinfo summary | grep 'Bugfix' | tail -1 | awk '{print $1}')
	ENHANCEMENT=$($ssh_opt@$server yum updateinfo summary | grep 'Enhancement' | tail -1 | awk '{print $1}')
        OS_INSTALLED_DATE=$($ssh_opt@$server ls -lact --full-time /etc | tail -1 | awk '{print $6}')
	FIREWALL_STATUS=$($ssh_opt@$server systemctl status firewalld.service |grep -w  "Active" | awk -F "Active" '{print $2}' | tr ':' " ")
	SELINUX_STATUS=$($ssh_opt@$server getenforce)

#echo "OS_TYPE=$OS_TYPE"
#echo "OS_VERSION=${OS_VERSION}"
echo "$server,$HOST_NAME,$OS_TYPE,$OS_VERSION,$OS_INSTALLED_DATE,$SECURITY_NOTICE,$BUG_FIX,$ENHANCEMENT,$FIREWALL_STATUS,$SELINUX_STATUS" >> SERVER_INFO.csv
done < list_of_servers
