#!/usr/bin/expect
. ${RCD}/functions

set timeout 10
spawn scp foxconn@10.1.3.58:/home/foxconn/time.txt ${FOX}
expect {
    "(yes/no)?" {
    send "yes\n"
    
    expect "password:" {
        send "Foxconn99\n"}

    }
    "password:" {
    send "Foxconn99\n"}
}
expect eof
exit 0

