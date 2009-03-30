#!/bin/sh
#requires the following
# free, hostname, grep, cut, awk, uname

HOSTNAME=`hostname -s`
IP_ADDRS=`ifconfig | grep 'inet addr' | grep -v '255.0.0.0' | cut -f2 -d':' | awk '{print $1}'`
IP_ADDRS=`echo $IP_ADDRS | sed 's/\n//g'`

#memory
MEMORY=`free | grep Mem | awk '{print $2}'`

#cpu info
CPUS=`cat /proc/cpuinfo | grep processor | wc -l | awk '{print $1}'`
CPU_MHZ=`cat /proc/cpuinfo | grep MHz | tail -n1 | awk '{print $4}'`
CPU_TYPE=`cat /proc/cpuinfo | grep vendor_id | tail -n 1 | awk '{print $3}'`
CPU_TYPE2=`uname -m`
CPU_TYPE3=`uname -p`

OS_NAME=`uname -s`
OS_OS=`uname -o`
OS_KERNEL=`uname -r`
OS_RELEASE=`cat /etc/sabayon-release`
OS_EDITION=`cat /etc/sabayon-edition`
ESELECT_KERNEL=`eselect --no-color kernel list`
ESELECT_OPENGL=`eselect --no-color opengl list`
ESELECT_JAVA=`eselect --no-color java-vm list`
ESELECT_JAVAP=`eselect --no-color java-nsplugin list`

EQUO=`equo --version`
PORTAGE=`emerge --version`

UPTIME=`uptime`
MEM=`free -t -m`
SPACE=`df -TH`

PCIINFO=`lspci | cut -f3 -d':'`
#Another way to do it
#PCIINFO=`lspci | cut -f3 -d':'`

LSUSB=`lsusb`
LSMOD=`lsmod`
#print it out
echo "$HOSTNAME"
echo "--------------------------------------------------------------------"
echo "Hostname         : $HOSTNAME"
echo "Host Address     : $IP_ADDRS"
echo "Main Memory      : $MEMORY"
echo "Number of CPUs   : $CPUS"
echo "CPU Type         : $CPU_TYPE2 $CPU_TYPE3 $CPU_MHZ MHz"
echo "OS Release       : $OS_RELEASE"
echo "OS Edition       : $OS_EDITION"
echo "Kernel Name      : $OS_NAME $OS_OS"
echo "Kernel Version   : $OS_KERNEL"
echo "Uptime           : $UPTIME"
echo "--------------------------------------------------------------------"
echo
echo "Entropy Version"
echo "$EQUO"
echo
echo "Portage Version"
echo "$PORTAGE"
echo "--------------------------------------------------------------------"
echo
echo "Kernel List"
echo "$ESELECT_KERNEL"
echo "Your Kernel Should Be Set To:"
echo "$OS_KERNEL"
echo "Use eselect kernel set #"
echo "--------------------------------------------------------------------"
echo
echo "OpenGL List"
echo "$ESELECT_OPENGL"
echo "The above should be set to your video card, see lspci"
echo "Use eselect opengl set #"
echo "--------------------------------------------------------------------"
echo
echo "Java VM List"
echo "$ESELECT_JAVA"
echo "Use java-config --set-system-vm #"
echo "--------------------------------------------------------------------"
echo
echo "Java-nsplugin List"
echo "$ESELECT_JAVAP"
echo "Use eselect java-nsplugin set #"
echo "--------------------------------------------------------------------"
echo
echo "Devices - lspci"
echo "--------------------------------------------------------------------"
echo "$PCIINFO"
echo "--------------------------------------------------------------------"
echo
echo "Devices - lsmod"
echo "--------------------------------------------------------------------"
echo "$LSMOD"
echo "--------------------------------------------------------------------"
echo
echo "Devices - lsusb"
echo "--------------------------------------------------------------------"
echo "$LSUSB"
echo "--------------------------------------------------------------------"
echo
echo "Memory"
echo "--------------------------------------------------------------------"
echo "$MEM"
echo "--------------------------------------------------------------------"
echo
echo "Disk Space"
echo "--------------------------------------------------------------------"
echo "$SPACE"
echo "--------------------------------------------------------------------"
echo
