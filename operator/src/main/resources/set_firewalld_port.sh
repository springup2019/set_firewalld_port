#!/bin/bash
#当前路径
readonly shell_path=$(cd `dirname $0`; pwd)
conf_file=$shell_path/conf

#服务名称
service=set_firewalld,assembly_port,service_port,dgep_port,k8s_port
explain=explain,poseidon组件,特征服务,中台,k8s
IFS=','
services=($service)
explains=($explain)
IFS=''
services_size=${#services[*]}

#打印LOG信息
LOG_INSTALL(){
	echo -e "\033[36m[info]##${2}## \033[0m [`date -d today +"%Y-%m-%d %H:%M:%S"`],${1}."
}

#打印异常信息
LOG_EXCEPTIONS(){
	echo -e "\033[31m[exception]##${2}#### [`date -d today +"%Y-%m-%d %H:%M:%S"`],${1}. \033[0m"
	exit
}

check_file(){
	if [ ! -d $conf_file ]
	then
		LOG_EXCEPTIONS "$conf_file配置文件目录不存在,请检查！"
	fi
}

#输入相关信息
usage() {
	echo "........................................................"
	echo -e "\033[33m【USAGE】功能列表\033[0m"
	echo -e "\033[33m【USAGE】输入0：退出\033[0m"
	for (( i = 1; i < ${services_size}; i++ )); do
		echo -e "\033[33m【USAGE】输入${i}：开启${explains[i]}相关防火墙端口...\033[0m"
	done
	echo -e "\033[33m【USAGE】输入${services_size}：开启所有相关防火墙端口...\033[0m"	
	echo "........................................................"

	read -p "请输入相关功能编号: " option
	sleep 1
	
	if [[  ! `seq 0 ${services_size}` =~ ${option} ]]; then
		echo -e "\033[33m【WARNING】功能编号输入错误，请重新输入...\033[0m"
		usage
	else
		#退出
		if [[ "${option}" == "0" ]];then
			exit
		fi

		#开启单个部分端口
		if [[ "${option}" != "${services_size}" ]]; then
			LOG_INSTALL "开启${explains[option]}相关端口..."
			sh $shell_path/bin/open_firewall_port.sh $shell_path/conf/${services[option]} ${explains[option]}
		fi

		#开启所有端口
		if [[ "${option}" == "${services_size}" ]];then
			LOG_INSTALL "开启所有端口..."
			for (( i = 1; i < ${services_size}; i++ )); do
				LOG_INSTALL "开启${explains[i]}相关端口..."
				sh $shell_path/bin/open_firewall_port.sh $shell_path/conf/${services[i]} ${explains[i]}
			done
		fi
	fi
}
check_file
usage