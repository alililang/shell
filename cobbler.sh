#!/bin/bash
# centos7/8 cobbler服务器软件
# Author: aliase
# link: aliase@aliyun.com

RED="\033[31m"      # Error message
GREEN="\033[32m"    # Success message
YELLOW="\033[33m"   # Warning message
BLUE="\033[36m"     # Info message
PLAIN='\033[0m'

colorEcho() {
    echo -e "${1}${@:2}${PLAIN}"
}

config(){
    if /usr/sbin/sestatus -v |grep -Eqi 'enforcing';then
        sed -i s/"SELINUX=enforcing"/"SELINUX=disabled"/g /etc/selinux/config
    elif /usr/sbin/sestatus -v |grep -Eqi 'permissive';then
        sed -i s/"SELINUX=permissive"/"SELINUX=disabled"/g /etc/selinux/config
    else
        echo -e "${GREEM}已经关闭${PLAIN}\n"
    fi  
}

Epel(){
    yum -y update
    yum -y install wget vim epel-release dhcp httpd xinetd tftp tftp-server cobbler cobbler-web -y
}

EnableSer(){
    systemctl start rsyncd httpd dhcpd xinetd cobblerd
    systemctl enable rsyncd httpd dhcpd xinetd cobblerd
    systemctl stop firewalld
    systemctl disable firewalld
}

Conf(){
    sed -ri 's/^(manage_dhcp: ).*/\1/' /etc/cobbler/settings
    sed -ri 's/^(manage_rsync: ).*/\1/' /etc/cobbler/settings
    sed -ri 's/^(next_server: ).*/\192.168.10.1/' /etc/cobbler/settings
    sed -ri 's/^(server: ).*/\192.168.10.1/' /etc/cobbler/settings
    #运行命令，拷贝密码到/etc/cobbler/settings下更改
    #default_password_crypted: "$1$random-p$RkqDMTpuNlZZhJ7moLn3Q."
    #openssl passwd -1 -salt 'random-phrase-here' '1234567890'

    #下载此文件后，将其挂载到某个位置
    #mount -t iso9660 -o loop,ro /root/CentOS-7-x86_64-DVD-1810.iso /mnt
    #现在可以导入分配了。名称和路径参数是导入唯一必需的选项
    #cobbler import --name=CentOS7 --arch=X86_64 --path=/mnt
    #检查问题
    cobbler check
    #同步数据
    cobbler sync
    systemctl restart cobblerd
}
DHCPCONF(){
    cat > /etc/dhcp/dhcpd.conf<<-EOF
ddns-update-style interim;

allow booting;
allow bootp;

ignore client-updates;
set vendorclass = option vendor-class-identifier;

option pxe-system-type code 93 = unsigned integer 16;

subnet 192.168.10.0 netmask 255.255.255.0 {
     option routers             192.168.10.5;
     option domain-name-servers 192.168.10.1;
     option subnet-mask         255.255.255.0;
     range dynamic-bootp        192.168.10.100 192.168.10.254;
     default-lease-time         21600;
     max-lease-time             43200;
     next-server                192.168.10.1;
     class "pxeclients" {
          match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
          if option pxe-system-type = 00:02 {
                  filename "ia64/elilo.efi";
          } else if option pxe-system-type = 00:06 {
                  filename "grub/grub-x86.efi";
          } else if option pxe-system-type = 00:07 {
                  filename "grub/grub-x86_64.efi";
          } else if option pxe-system-type = 00:09 {
                  filename "grub/grub-x86_64.efi";
          } else {
                  filename "pxelinux.0";
          }
     }

}

# group for Cobbler DHCP tag: default
group {
}
EOF
systemctl start dhcpd
systemctl enable dhcpd
}

main(){
    config
    Epel
    EnableSer
    Conf
}
main