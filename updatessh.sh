#! /bin/bash
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'
echo -e "${green}#########################################"
echo -e "${green}#                                       #"
echo -e "${green}#         jupyter一键部署脚本           #"
echo -e "${green}#        此脚本由alililang维护          #"
echo -e "${green}#           此脚本仅用于学习            #"
echo -e "${green}#                                       #"
echo -e "${green}#########################################${plain}"
#yum install -y telnet-server* telnet xinetd
#systemctl enable xinetd.service
#systemctl enable telnet.socket
#systemctl start telnet.socket
#systemctl start xinetd.service
#echo 'pts/0' >>/etc/securetty
#echo 'pts/1' >>/etc/securetty
#echo 'pts/2' >>/etc/securetty
if /usr/sbin/sestatus -v |grep -Eqi 'enforcing';then
    sed -i s/"SELINUX=enforcing"/"SELINUX=disabled"/g /etc/selinux/config
elif /usr/sbin/sestatus -v |grep -Eqi 'permissive';then
    sed -i s/"SELINUX=permissive"/"SELINUX=disabled"/g /etc/selinux/config
else
    echo -e "${green}已经关闭${plain}\n"
fi
yum install -y gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel pam-devel
yum install -y pam* zlib*
wget https://cloudflare.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.6p1.tar.gz
mv /etc/ssh /etc/ssh_bak
cp /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.bak
cp /etc/pam.d/sshd /etc/pam.d/sshd.bak
tar zxf openssh-8.6p1.tar.gz
cd openssh-8.6p1
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam --with-zlib --with-md5-passwords --with-tcp-wrappers
make
make install
cp contrib/redhat/sshd.init /etc/init.d/sshd
chkconfig --add sshd
chkconfig sshd on
chkconfig --list sshd
sed -i "32 aPermitRootLogin yes" /etc/ssh/sshd_config
service sshd restart
