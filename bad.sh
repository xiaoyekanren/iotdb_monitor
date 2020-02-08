#/bin/bash


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


#检查iotdb所在路径
#坏的～这个地方不对，pwdx获得的是启动时的路径，而不是文件路径
check_iotdb_pwdx(){
    if [[ "$iotdb_pid" -eq $null ]];  #这个地方必须是两个方括号[[]]
    then
        echo "can't find iotdb's pid"
    else
        pwdx=`pwdx $iotdb_pid|awk '{print $2}'`
        echo "iotdb's path is '$pwdx'"
    fi
}
