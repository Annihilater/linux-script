#!/bin/bash

# 停止Docker服务
sudo systemctl stop docker

# 卸载Docker软件包
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io

# 删除所有相关的Docker目录和文件
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# 删除Docker的官方仓库源信息（如果有的话）
sudo rm -f /etc/apt/sources.list.d/docker.list
