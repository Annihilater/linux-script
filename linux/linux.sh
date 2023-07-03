#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

check_sys

check_sys(){
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    #bit=`uname -m`
}


root_pwd()
{
clear
echo -e "${Green_font_prefix}修改Root密码${Font_color_suffix} "
echo -e "${Green_font_prefix}需在root/sudo -i 状态下运行${Font_color_suffix} "
echo -e "${Green_font_prefix}By.SKN${Font_color_suffix} "
sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
passwd root
sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
echo -e "${red_font_prefix}修改成功${Font_color_suffix}"
stty erase '^H' && read -p "重启 ? [Y/n] :" yn
    [ -z "${yn}" ] && yn="y"
    if [[ $yn == [Yy] ]]; then
        echo -e "${red_font_prefix}REBOOT${Font_color_suffix}"
        reboot
    fi
}
speedtest()
{
    wget sh.debian11.com/speedtest -O /usr/bin/speedtest && chmod +x /usr/bin/speedtest
}
nf()
{
    bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
}
start_menu()
{
clear
echo && echo -e "
 COO NETWORK                           
 ${Green_font_prefix}1.${Font_color_suffix}  一键 Root 适用于所有服务器
 ${Green_font_prefix}2.${Font_color_suffix}  一键检测流媒体解锁情况
 ${Green_font_prefix}3.${Font_color_suffix}  一键安装speedtest
" &&

read -e -p " 请输入数字:" num
case "$num" in
    1)
  check_sys
  root_pwd
  ;;
    2)
  check_sys
  nf
  ;;  
    3)
  check_sys
  speedtest
  ;;  
    *)
    echo -e "輸入錯誤"
sleep 1
clear
start_menu
    ;;
esac
}

check_sys
start_menu