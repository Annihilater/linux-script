#!/bin/bash

# 显示最近的服务器
echo "Fetching list of nearest servers..."
speedtest -L
echo "--------------------------------------------"

# 获取最近的服务器ID列表
server_ids=$(speedtest -L | grep "^[[:space:]]*[0-9]\+" | awk '{print $1}')

# 遍历每一个服务器ID并进行测试
for id in $server_ids
do
   echo "Testing server ID: $id"
   speedtest -s $id
   echo "--------------------------------------------"
done

echo "All tests completed."