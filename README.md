# bash/shellscript to Generate inventory,Patching/Compliance report in csv format on muliple RHEL/CentoS servers
bash/shell script to Generate inventory/Patching/Compliance on multiple RHEL/CentOS &amp; Ubuntu Servers

if you are running a Red Hat environment without satellite integration, or if it is CentOS systems, this script will help you to create a report like listed usecases

Available security updates on Red Hat (RHEL) and CentOS system
Inventory about server info (IP,Hostname,OS Version,OS Installed date, firewalld status,SELinux Status,RAM,HDD,CPUs size,Up time,etc)

# Pre-Requirements
we are going to use sshpass method so you may have three different files for login ID & password files and targeted list of remote servers 
login ID of remote server : remoteuser file
Password of remote server : remotepass file 
And ensure access for your targetd servers 
