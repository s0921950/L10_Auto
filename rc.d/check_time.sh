. ${RCD}/functions

check_time=`ls ${FOX} | grep "time.txt"`

failed_log='TIME';

if [ ! -n "$check_time" ] ; then

	fail_message "时间验证失败..."
	. ${RCD}/failed.sh
	exit 1
fi

set_time=`cat ${FOX}/time.txt`
#echo ${set_time#* }
echo \'$set_time\'
#date_time=\'$set_time\'

#echo "date '+%Y-%m-%d %H:%M:%S' -s $date_time"
echo `date -s "$set_time"`

echo `hwclock -w`

pass_message "时间验证通过..."
exit 0
