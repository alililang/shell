#!/bin/bash
red='\033[31m'
green='\033[32m'
yellow='\033[33m'
plain='\033[0m'
echo -e "${green}#########################################"
echo -e "${green}#                                       #"
echo -e "${green}#         jupyter一键部署脚本           #"
echo -e "${green}#  此脚本由aliase@aliyun.com维护        #"
echo -e "${green}#           此脚本仅用于学习            #"
echo -e "${green}#                                       #"
echo -e "${green}#########################################${plain}"
#wget http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz

if [[ -f /etc/redhat-release ]]; then
  release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
  release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
  release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  release="centos"
else
  echo -e "${red}未检测到系统版本，请联系脚本作者！${plain}\n" && exit 1
fi
if [ "$release" == "centos" ]; then
yum -y install gcc gcc-c++ openssl-devel libstdc++* libcap*
yum -y remove ntp ntpdate
else
apt-get -y install gcc gcc-c++ openssl-devel libstdc++* libcap*
apt-get -y remove ntp ntpdate
fi
###################
cp -ar /etc/ntp /etc/ntp.bak
cp /etc/ntp.conf /etc/ntp.conf.bak
cp /etc/sysconfig/ntpd /etc/sysconfig/ntpd.bak
cp /etc/sysconfig/ntpdate /etc/sysconfig/ntpdate.bak
###################
tar xvf ntp-4.2.8p15.tar.gz
cd ntp-4.2.8p15/
mkdir /usr/share/doc/ntp-4.2.8p15
./configure \
--prefix=/usr \
--bindir=/usr/sbin \
--sysconfdir=/etc \
--enable-all-clocks \
--enable-parse-clocks \
--docdir=/usr/share/doc/ntp-4.2.8p15
make clean
make -j8
make install
ln -s /usr/local/ntp-4.2.8p15 /usr/local/ntp
cp /etc/ntp.conf.bak /etc/ntp.conf
cp /etc/ntp/keys.rpmsave /etc/ntp/keys
cp /usr/sbin/ntpd /etc/init.d/ntpd
/usr/sbin/ntpd -c /etc/ntp.conf
ntpd --version
Current_version=$(ntpd --version 2>&1)
Successful_version="ntpd 4.2.8p15"
if [[ $Current_version =~ $Successful_version ]]; then 
   echo -e "${green} 升级成功 ${plain}";
   else
   echo -e "${red}升级失败 ${plain}"; exit 1;
fi
