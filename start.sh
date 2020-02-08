#/bin/bash
#ip=`ifconfig enp0s3 | grep "inet addr"|cut -d ':' -f 2|cut -d ' ' -f 1`
rm *.csv

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

##常量1:cpu核心数量、内存、当前用户、时间
write_system_information(){
	cpu_core_sum=`cat /proc/cpuinfo |grep 'processor'|wc -l`  ##CPU核心数量
	#cpu_core_sum2=`grep -c 'processor' /proc/cpuinfo`  #第二种写法
	mem_size_kb=`cat /proc/meminfo |grep 'MemTotal:'|awk '{print $2}'`  ##内存大小
	current_user=`whoami`  ##用户
	start_time=`date "+%Y%m%d%H%M%S"`  ##时间
	#printf "cpu_core_sum=%s\nmem_size_kb=%s\ncurrent_user=%s\nstart_time=%s\n" $cpu_core_sum $mem_size_kb $current_user $start_time  ##这个是输出到屏幕
	## 写入system.csv
	printf "cpu_core_sum,mem_size_kb,current_user,start_time\n$cpu_core_sum,$mem_size_kb,$current_user,$start_time\n" >> system.csv
	printf "Already write system information to system.csv\n"
}
write_system_information

##常量2:网卡
system_interface(){
        interface_fake=`cat /proc/net/dev|awk '{print $1}'|grep -v 'Inter-'|grep -v face|tr -d "\n"`
        replace=':'
        interface=${interface_fake//$replace/ }  #使用空替换所有的:
        OLD_IFS="$IFS"  #将旧分割符存储
        IFS=" "  #设置新的分割符
        arr=($interface)  #按照新分割符分割,将interface给了arr这个变量，并且分割好了
        IFS="$OLD_IFS"  #还原分割符
	interface=$arr
}
system_interface

##内存
used_memory(){
	iotdb_mem_kb=`cat /proc/${iotdb_pid}/status|grep RSS|awk '{print $2}'`
}

##拼网卡的csv的标题
write_monitor_interface_title(){
	s=0
        while ((s<${#arr[@]}))
        do
		interface_title=$interface_title,"${arr[$s]}_system_receive_size","${arr[$s]}_system_transmit_size","${arr[$s]}_system_receive_packages","${arr[$s]}_system_transmit_packages","${arr[$s]}_iotdb_receive_size","${arr[$s]}_iotdb_transmit_size","${arr[$s]}_iotdb_receive_packages","${arr[$s]}_iotdb_transmit_packages"  ##拼csv的标题..
                let s++
        done
	interface_title=${interface_title:1}
	#printf $interface_title"\n" > monitor.csv
}
write_monitor_interface_title

##拼monitor.csv的完整标题
write_monitor_title(){
	title="datetime","iotdb_mem",$interface_title
	printf $title"\n" > monitor.csv
}
write_monitor_title

##写监控的网卡的数值
write_monitor_interface_value(){
        s=0
        while ((s<${#arr[@]}))
        do
                ##system的网络情况
                system_receive_size=`cat /proc/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $2}'`
                system_transmit_size=`cat /proc/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $10}'`
                system_receive_packages=`cat /proc/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $3}'`
                system_transmit_packages=`cat /proc/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $11}'`
                ##IoTDB的网络情况
                iotdb_receive_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $2}'`
                iotdb_transmit_size=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $10}'`
                iotdb_receive_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $3}'`
                iotdb_transmit_packages=`cat /proc/${iotdb_pid}/net/dev|grep -v 'Inter-'|grep -v face|grep ${arr[s]}|awk '{print $11}'`
                interface_line=$interface_line,$system_receive_size,$system_transmit_size,$system_receive_packages,$system_transmit_packages,$iotdb_receive_size,$iotdb_transmit_size,$iotdb_receive_packages,$iotdb_transmit_packages
                let s++
        done
        interface_line=${interface_line:1}
	#printf $interface_line
}
#write_monitor_interface_value

##拼全部的值
write_value(){
	used_memory
	write_monitor_interface_value
	date=`date "+%Y%m%d%H%M%S"`
	value="$date,$iotdb_mem_kb,$interface_line"
	printf $value"\n" >> monitor.csv
}

##执行循环
printf "Now,writing monitor items to monitor.csv...\nYou should press 'ctrl+c' to stop and start with 'nohup,&'\n"
while true
do
	write_value&
	sleep 2
done
