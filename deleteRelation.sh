#!/bin/bash
echo '输入需要删除关系的场所:'
read serviceCode
impala-shell -q  "select id_from, from_type, id_to, to_type from relation where first_terminal_num = '${serviceCode}'" -B --output_delimiter="," -o deleteRelation_temp1.txt
#impala-shell -q  "select id_from, from_type, id_to, to_type from relation where first_terminal_num = '44030588011222' limit 10" -B --output_delimiter="," -o deleteRelation_temp1.txt
echo "" > deleteRelation.txt
cat deleteRelation_temp1.txt | while read line
do
	IFS=',' arr=($line)
	MD5_1=`echo -n ${arr[0]}"|"${arr[1]} | md5sum | cut -c1-8`
	MD5_2=`echo -n ${arr[2]}"|"${arr[3]} | md5sum | cut -c1-8`
	rowKey_1=${MD5_1}"|"${arr[0]}"|"${arr[1]}"|"${arr[2]}"|"${arr[3]}
	rowKey_2=${MD5_2}"|"${arr[2]}"|"${arr[3]}"|"${arr[0]}"|"${arr[1]}
	command_1="deleteall 'relation', '"${rowKey_1}"'"
	command_2="deleteall 'relation', '"${rowKey_2}"'"
#	echo ${rowKey_1}
#	echo ${rowKey_2}
	echo -e "${command_1}" >> deleteRelation.txt
	echo -e "${command_2}" >> deleteRelation.txt
done
echo "exit" >> deleteRelation.txt
hbase shell deleteRelation.txt > deleteRelation.log
rm -f deleteRelation_temp1.txt
echo '删除场所采集的关系完成,请查看日志deleteRelation.log...'



