#!/bin/bash
#当前路径
readonly shell_path=$(cd `dirname $0`; pwd)

#打印LOG信息
LOG_INSTALL(){
	echo -e "\033[36m[info]##${2}## \033[0m [`date -d today +"%Y-%m-%d %H:%M:%S"`],${1}."
}

#打印异常信息
LOG_EXCEPTIONS(){
	echo -e "\033[31m[exception]##${2}## [`date -d today +"%Y-%m-%d %H:%M:%S"`],${1}. \033[0m"
	exit
}

check_firewall_state() {
	if [[ ! -f ${1} ]]; then
		LOG_EXCEPTIONS "${1}文件不存在，请检查！"
	fi
	
	if  command -v firewall-cmd; then
		firewall_state=`firewall-cmd --state`
		if [[ -z `systemctl status firewalld|grep "active (running)"` ]]; then
			LOG_INSTALL "开启防火墙..."
			systemctl start firewalld.service
			sleep 2
		else
			LOG_INSTALL "防火墙状态为${firewall_state}，已正常开启！"
		fi
	else
		LOG_EXCEPTIONS "firewall-cmd命令不存在，请检查！"
		
	fi

	if  command -v iptables; then
		LOG_INSTALL "清除防火墙规则..."
		iptables -F &&  iptables -X &&  iptables -F -t nat &&  iptables -X -t nat
	else
		LOG_EXCEPTIONS "iptables命令不存在，请检查！"
		
	fi
}

open_port() {
	list_port=`firewall-cmd --list-port`
	LOG_INSTALL "开启$2相关防火墙端口..."
	cat $1|while read line
	do
		arr=(${line//,/ })
		if [[ -n `echo ${list_port}|grep -w ${arr[2]}/tcp` ]]; then
			LOG_INSTALL "${arr[0]}的${arr[2]}/tcp防火墙端口已经开启，无需再次开启！\n"
		else
			firewall-cmd --zone=public --add-port=${arr[2]}/tcp --permanent
			if [[ $? -ne 0 ]]; then
				LOG_EXCEPTIONS "开启${arr[0]}的${arr[2]}/tcp防火墙端口失败！\n"
			else
				LOG_INSTALL "开启${arr[0]}的${arr[2]}/tcp防火墙端口 【SUSSESS】\n"
			fi
		fi
		sleep 1

		if [[ -n `echo ${list_port}|grep -w ${arr[2]}/udp` ]]; then
			LOG_INSTALL "${arr[0]}的${arr[2]}/udp防火墙端口已经开启，无需再次开启！\n"
		else
			firewall-cmd --zone=public --add-port=${arr[2]}/udp --permanent
			if [[ $? -ne 0 ]]; then
				LOG_EXCEPTIONS "开启${arr[0]}的${arr[2]}/udp防火墙端口失败！\n"
			else
				LOG_INSTALL "开启${arr[0]}的${arr[2]}/udp防火墙端口 【SUSSESS】\n"
			fi
		fi
		sleep 1
	done

	LOG_INSTALL "重启防火墙..."
	firewall-cmd --reload
	sleep 2
	systemctl restart firewalld.service
	iptables -F &&  iptables -X &&  iptables -F -t nat &&  iptables -X -t nat
}

check_firewall_state #$@
open_port #$@