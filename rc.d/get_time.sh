#!/usr/bin/expect

set timeout 10
spawn scp foxconn@10.1.3.58:/home/foxconn/time.txt /root/Diag_Desktop/
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

