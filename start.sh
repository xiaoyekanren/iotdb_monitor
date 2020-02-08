#/bin/bash
# Def para
#ip=`ifconfig enp0s3 | grep "inet addr"|cut -d ':' -f 2|cut -d ' ' -f 1`
cputhread=`cat /proc/cpuinfo |grep 'processor' |wc -l`
#cputhread2=`grep -c 'processor' /proc/cpuinfo`
user_sum=`uptime|awk '{print $6}'`

# 常量
cpu_core_sum=`cat /proc/cpuinfo |grep 'processor'|wc -l`
#内存=已用+空闲+缓存
mem_size_kb=`cat /proc/meminfo |grep 'MemTotal:'|awk '{print $2}'`
current_time=`date "+%Y%m%d-%H%M%S"`
current_user=`whoami`

#检查有没有IoTDB进程，如果有，打印PID
check_iotdb_pid(){
	iotdb_pid=`ps -ef|grep '[o]rg.apache.iotdb.db.service.IoTDB'|awk '{print $2}'`
	null=""
	if [[ "$iotdb_pid" -eq $null ]];  #这个地方必须是两个方括号[[]]
	then
		echo "can't find iotdb's pid"
	else
		echo "iotdb's pid is "${iotdb_pid}
	fi
}
check_iotdb_pid

#查看本PID内存占用,RSS
check_iotdb_mem(){
	iotdb_mem=`cat /proc/${iotdb_pid}/status|grep RSS|awk '{print $2}'`
	echo "iotdb's mem userd is "${iotdb_mem}
}
check_iotdb_mem

#检查iotdb所在路径
#这个地方不对，pwdx获得的是启动时的路径，而不是文件路径
#check_iotdb_pwdx(){
#    if [[ "$iotdb_pid" -eq $null ]];  #这个地方必须是两个方括号[[]]
#    then
#        echo "can't find iotdb's pid"
#    else
#        pwdx=`pwdx $iotdb_pid|awk '{print $2}'`
#        echo "iotdb's path is '$pwdx'"
#    fi
#}

#确认Iotdb的网卡
check_interface(){
	interface_fake=`cat /proc/${iotdb_pid}/net/dev|awk '{print $1}'|grep -v 'Inter-'|grep -v face|tr -d "\n"`
	replace=':'
	interface=${interface_fake//$replace/ }  #使用空替换所有的:
	echo "interface is "$interface
}
check_interface

#坏的～可以供参考-真正的查看流量
check_iotdb_net(){
	OLD_IFS="$IFS"  #将旧分割符存储
	IFS=","  #设置新的分割符是,
	arr=($interface)  #按照新分割符分割
	IFS="$OLD_IFS"  #还原分割符
	for s in ${arr[@]}  #${arr[@]}代表整个数组
	do
    		#echo "$s"
		receive_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep $s|awk '{print $2}'`
		transmit_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep $s|awk '{print $10}'`
		receive_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep $s|awk '{print $3}'`
		transmit_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep $s|awk '{print $11}'`
	done
	#receive_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep wlp3s0|awk '{print $2}'`
	#transmit_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep wlp3s0|awk '{print $10}'`
	#receive_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep wlp3s0|awk '{print $3}'`
	#transmit_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep -v lo|grep wlp3s0|awk '{print $11}'`
	echo 'receive_size='$receive_size
	echo 'transmit_size='$transmit_size
	echo 'receive_packages='$receive_packages
	echo 'transmit_packages='$transmit_packages
	echo ''
}
#check_iotdb_net

check_iotdb_net_test(){
        OLD_IFS="$IFS"  #将旧分割符存储
        IFS=" "  #设置新的分割符
        arr=($interface)  #按照新分割符分割
	IFS="$OLD_IFS"  #还原分割符
	s=0
	#echo "arr的长度是"${#arr[@]}
	while ((s<${#arr[@]}))
	do
		echo ${arr[s]}
                receive_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $2}'`
                transmit_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $10}'`
                receive_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $3}'`
                transmit_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $11}'`
	        echo 'receive_size='$receive_size
        	echo 'transmit_size='$transmit_size
        	echo 'receive_packages='$receive_packages
        	echo 'transmit_packages='$transmit_packages
		let s++
	done
}
check_iotdb_net_test




#while true
#do
#    check_iotdb_mem
#    check_iotdb_net
#    echo ''
#    sleep 1
#done
