#!/bin/bash
#挂载光盘
mount /dev/cdrom /var/www/html/centos &>/dev/null
if [ $? -ne 0 ] ; then
	echo"挂载失败请重新设置"
	exit
fi
#安装dhcp,tftp,http和pxelinux.0(sysliux)
yum -y install httpd dhcp tftp-server syslinux &>/dev/null
mkdir /var/www/html/centos
mkdir /var/lib/tftpboot/pxelinux.cfg
#主机ip
a=`ifconfig eth0 |awk '/inet /{print$2}'`
#IP前三个字段
b=`echo $a |awk -F. '//{print$1"."$2"."$3}'`
#配置dhcp
echo "subnet $b.0 netmask 255.255.255.0 {
range $b.100 $b.200;
option domain-name-servers $a;
option routers $b.254;
default-lease-time 600;
max-lease-time 7200;
next-server $a;
filename \"pxelinux.0\";
}" > /etc/dhcp/dhcpd.conf
#配置tftp
cp /var/www/html/centos/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
cp /var/www/html/centos/isolinux/{initrd.img,splash.png,vesamenu.c32,vmlinuz} /var/lib/tftpboot/
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
sed -i '1s/.*/[development]/' /etc/yum.repos.d/*.repo
sed -i '65,120d' /var/lib/tftpboot/pxelinux.cfg/default 
sed -i "s!inst.stage.*!ks=http://$a/ks.cfg!" /var/lib/tftpboot/pxelinux.cfg/default
sed -i '63i menu default' /var/lib/tftpboot/pxelinux.cfg/default
sed -i '62c menu label Install CentOS 7.5' /var/lib/tftpboot/pxelinux.cfg/default 
#修改应答文件的ip
sed -i "s!http://.*/!http://$a/!" $PWD/ks.cfg
cp $PWD/ks.cfg /var/www/html/
systemctl restart httpd tftp dhcpd
if [ $? -eq 0 ] ; then
	 echo "执行成功,可以直接PXE装机" 
fi
