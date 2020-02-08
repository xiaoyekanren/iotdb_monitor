#/bin/bash
#ip=`ifconfig enp0s3 | grep "inet addr"|cut -d ':' -f 2|cut -d ' ' -f 1`

##检查有没有IoTDB进程，如果有，打印PID
check_iotdb_pid(){
	iotdb_pid=`ps -ef|grep '[o]rg.apache.iotdb.db.service.IoTDB'|awk '{print $2}'`
	null=""
	if [[ "$iotdb_pid" -eq $null ]];  #这个地方必须是两个方括号[[]]
	then
		printf "can't find iotdb's pid\n"
		exit
	else
		printf "iotdb's pid is %s\n" ${iotdb_pid}
	fi
}
check_iotdb_pid

##常量
write_system_information(){
	cpu_core_sum=`cat /proc/cpuinfo |grep 'processor'|wc -l`
	#cpu_core_sum2=`grep -c 'processor' /proc/cpuinfo`  #第二种写法
	mem_size_kb=`cat /proc/meminfo |grep 'MemTotal:'|awk '{print $2}'`
	current_user=`whoami`
	start_time=`date "+%Y%m%d%H%M%S"`
	#printf "cpu_core_sum=%s\nmem_size_kb=%s\ncurrent_user=%s\nstart_time=%s\n" $cpu_core_sum $mem_size_kb $current_user $start_time
	## 写入system.csv
	printf "cpu_core_sum,mem_size_kb,current_user,start_time\n$cpu_core_sum,$mem_size_kb,$current_user,$start_time\n" >> system.csv
	printf "Already write system information to system.csv"
}
write_system_information

##查看本PID内存占用,RSS
check_iotdb_mem(){
	iotdb_mem=`cat /proc/${iotdb_pid}/status|grep RSS|awk '{print $2}'`
	printf "iotdb's mem userd is %s\n" ${iotdb_mem}
}
check_iotdb_mem

##确认Iotdb的网卡
check_interface(){
	interface_fake=`cat /proc/${iotdb_pid}/net/dev|awk '{print $1}'|grep -v 'Inter-'|grep -v face|tr -d "\n"`
	replace=':'
	interface=${interface_fake//$replace/ }  #使用空替换所有的:
	printf "interface is %s\n" $interface
}
check_interface

check_net(){
        OLD_IFS="$IFS"  #将旧分割符存储
        IFS=" "  #设置新的分割符
        arr=($interface)  #按照新分割符分割
	IFS="$OLD_IFS"  #还原分割符
	s=0
	#echo "arr的长度是"${#arr[@]}
	while ((s<${#arr[@]}))
	do
		#echo ${arr[s]}
                receive_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $2}'`
                transmit_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $10}'`
                receive_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $3}'`
                transmit_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $11}'`
	        #echo 'receive_size='$receive_size 'transmit_size='$transmit_size 'receive_packages='$receive_packages 'transmit_packages='$transmit_packages
		printf "${arr[s]}:\treceive_size=%s\ttransmit_size=%s\treceive_packages=%s\ttransmit_packages=%s\t\n" $receive_size $transmit_size $receive_packages $transmit_packages
		let s++
	done
}
check_net




#while true
#do
#    check_iotdb_mem
#    check_iotdb_net
#    echo ''
#    sleep 1
#done
