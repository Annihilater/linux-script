 #!/bin/bash

 # 检查是否提供了参数
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi

# 提取主机名参数
HOSTNAME=$1

# 修改时区
sudo timedatectl set-timezone Asia/Shanghai
timedatectl status

# 使用sudo确保我们有足够的权限来执行这些命令
sudo hostnamectl set-hostname $HOSTNAME
echo "127.0.0.1 $HOSTNAME" | sudo tee -a /etc/hosts

# 设定颜色代码
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ssh_dir="$HOME/.ssh"
authorized_keys_path="$HOME/.ssh/authorized_keys"
ssh_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRvdkf82cUkGKS1o8yC9hWjxUoJI20rboLpoGpzwSOfw2gHdyLfxdHDZ0+FsMStgIIOkwIAehoSpOjbTyhGwGz9EdyigWMGSm/64XpslHb5GNHDXcHhZCXfGeNjGZwN8srX4uotOvEuW8DX3TE8+MWoJm5LHw+VIdp+RGoEqA1qWDCJO6Afu6RPIFHwuqdOJ0/o2OwaHSBjxG4jWco/XFf229VqEj5VpSeTOpjCnAJfADHBn2KQlMg+pfYeZzBWBm0w5ugstZ+BAhvoQnkM/QKaNJs7+jTPYHHj101Rw90lM6Zq0SBo4WgbOAwBmtR5j5fbvjJPDoeh+aYGLZZ3IX7zpbmNgzOIh0E4Pfw7qA9s2j5Qd2dRLHOtdtD08/4TvibO9wM3i2QJJuwaRoo1opoV3zDIkjuOCLQw50oPjB4MawR3GESgY/wkT/GV3vsnNvUFm/TbSs7FIF14mdEl6MEWjnD7bzNcJ6QRFZMOPOx5eqb13Ph4k3S76imy+Za1LU= vampire"
sshd_config_path="/etc/ssh/sshd_config.d/default.conf"
bash_sshd_config_path="/etc/ssh/sshd_config"

# update 
apt update -y

mkdir /opt/apps

# set alias ll
echo "alias ll='ls -l'" >> /etc/profile && source /etc/profile
source /etc/profile

# check ssh_dir
if [ ! -d "$ssh_dir" ]; then
  mkdir "$ssh_dir"
  echo -e "${GREEN}Created $ssh_dir${NC}"
else
  echo -e "${YELLOW}$ssh_dir already exists${NC}"
fi

# check authorized_keys_file_path
if [ ! -f "$authorized_keys_path" ]; then
  touch "$authorized_keys_path"
  echo -e "${GREEN}Created $authorized_keys_path${NC}"
else
  echo -e "${YELLOW}$authorized_keys_path already exists${NC}"
fi

# add ssh public key 
echo $ssh_public_key  >> $authorized_keys_path

# add my own sshd_config
# check sshd_config_path
if [ ! -f "$sshd_config_path" ]; then
  touch "$sshd_config_path"
  echo -e "${GREEN}Created $sshd_config_path${NC}"
else
  echo -e "${YELLOW}$sshd_config_path already exists${NC}"
fi

# update sshd_config
cat << EOF >> $sshd_config_path
Port 22222
PermitRootLogin yes
MaxAuthTries 200
PasswordAuthentication no
PermitEmptyPasswords no
AllowAgentForwarding yes
AllowTcpForwarding yes
PrintLastLog yes
TCPKeepAlive yes
ClientAliveInterval 60
ClientAliveCountMax 60
EOF

# restart sshd
systemctl restart sshd

echo -e "${GREEN}install vim curl htop zip${NC}"
apt install vim -y
apt install curl -y
apt install htop -y
#apt install sudo -y
apt install jq -y
apt install zip -y
apt install tree -y
apt install p7zip-full -y
apt install httpie -y

# install iperf and iperf3
echo -e "${GREEN}install iperf iperf3${NC}"
apt install iperf -y
apt install iperf3 -y
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
apt install speedtest -y

# install tcping
echo -e "${GREEN}install tcping${NC}"
apt install tcptraceroute -y
wget http://www.vdberg.org/~richard/tcpping -O /usr/bin/tcping
chmod +x /usr/bin/tcping

# # install nexttrace
# echo -e "${GREEN}install nexttrace${NC}"
# bash <(curl -Ls https://raw.githubusercontent.com/sjlleo/nexttrace/main/nt_install.sh)

# 检查Docker是否已安装
if ! command -v docker &> /dev/null; then
    echo "Docker未安装，开始安装..."
    
    # 使用curl命令安装Docker
    curl -fsSL https://get.docker.com | bash
    
    # 检查安装结果
    if command -v docker &> /dev/null; then
        echo -e "执行: ${GREEN}docker -v"
        docker -v
        echo -e "${GREEN}Docker安装成功！"
    else
        echo -e "${YELLOW}Docker安装失败，请检查安装过程中的错误信息。"
    fi
else
    echo -e "${YELLOW}Docker已安装，无需重复安装。"
fi

# 检查Docker Compose是否已安装
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose未安装，开始安装..."
    
    # 安装Docker Compose
    curl -fsSL https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    chmod a+x /usr/local/bin/docker-compose
    # 创建个软链接，以后用 dc 命令来代替 docker-compose
    # 若系统中存在 dc 则删除，这个 dc 就是个计算器，完全没有用
    rm -rf `which dc`
    ln -s /usr/local/bin/docker-compose /usr/bin/dc
    
    # 检查安装结果
    if command -v docker-compose &> /dev/null; then
        echo -e "执行: ${GREEN}dc version"
        dc version
        echo -e "${GREEN}Docker Compose安装成功！"
    else
        echo -e "${YELLOW}Docker Compose安装失败，请检查安装过程中的错误信息。"
    fi
else
    echo -e "${YELLOW}Docker Compose已安装，无需重复安装。"
fi

echo -e "${GREEN}防火墙安装开始: sudo apt install ufw"
# sudo apt purge ufw iptables -y
# sudo apt install iptables -y
# sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
# sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
sudo apt install ufw -y
echo -e "${GREEN}防火墙安装成功: sudo apt install ufw"

echo -e "${GREEN}防火墙状态: sudo ufw status"
sudo ufw status

echo -e "${GREEN}防火墙端口开启: 22/22222/30001/30002/30003/30004/30005/30006/30007/30008"
sudo ufw allow 22
sudo ufw allow 22222
sudo ufw allow 30001
sudo ufw allow 30002
sudo ufw allow 30003
sudo ufw allow 30004
sudo ufw allow 30005
sudo ufw allow 30006
sudo ufw allow 30007
sudo ufw allow 30008

# echo -e "${GREEN}防火墙启动: sudo ufw enable"
# sudo ufw enable

echo -e "${GREEN}防火墙状态: sudo ufw status"
sudo ufw status

# install xrayr
echo -e "${GREEN}安装 XrayR:"
bash <(curl -Ls https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh)

# stop xrayr 
xrayr stop

# 修改 xrayr 的路由，禁止某些操作
# 定义 JSON 数据
ROUTE_DATA=$(cat <<EOL
{
    "domainStrategy": "IPOnDemand",
    "rules": [
        {
            "type": "field",
            "outboundTag": "block",
            "ip": [
                "geoip:private"
            ]
        },
        {
            "type": "field",
            "outboundTag": "block",
            "ip": [
                "127.0.0.1/32",
                "10.0.0.0/8",
                "fc00::/7",
                "fe80::/10",
                "172.16.0.0/12"
            ]
        {
            "type": "field",
            "outboundTag": "IPv4_out",
            "port": "123,8096,22222,30010,41369,50051,54321,60001"
        },
        {
            "type": "field",
            "outboundTag": "block",
            "port": "23,24,25,107,194,445,465,587,992,3389,6665-6669,6679,6697,6881-6999,7000,10000-65535"
        },
        {
            "type": "field",
            "outboundTag": "block",
            "protocol": [
                "bittorrent"
            ]
        },
        {
            "type": "field",
            "outboundTag": "IPv4_out",
            "network": "udp,tcp"
        }
    ]
}
EOL
)

# 写入到 /etc/Xrayr/route.json 文件中
echo "$ROUTE_DATA" > /etc/XrayR/route.json

# Network Optimization
echo -e "${GREEN}网络优化:"
# nnc TCP 优化
bash <(curl -Ls https://raw.githubusercontent.com/Annihilater/linux-script/main/linux/tools-auto.sh)

# pfgo TCP优化
# bash <(curl -sSL "https://scripts.zeroteam.top/PortForwardGo/tcp.sh")