#!/bin/bash

# 指定配置文件路径
CONFIG_FILE="/etc/XrayR/config.yml"
JQ_IN="/etc/XrayR/route.json"
JQ_OUT="/etc/XrayR/route_tmp.json"

# 开始更新配置
echo "Starting configuration updates..."

# 日志登记 - 将日志级别更改为info
echo "Updating log level to 'info'..."
sed -i 's|Level: none # Log level: none, error, warning, info, debug|Level: info # Log level: none, error, warning, info, debug|g' $CONFIG_FILE
sed -i 's|Level: error # Log level: none, error, warning, info, debug|Level: info # Log level: none, error, warning, info, debug|g' $CONFIG_FILE
sed -i 's|Level: warning # Log level: none, error, warning, info, debug|Level: info # Log level: none, error, warning, info, debug|g' $CONFIG_FILE
echo "Log level updated."

# 访问日志 - 启用访问日志路径
echo "Enabling access log path..."
sed -i 's|AccessPath: # /etc/XrayR/access.Log|AccessPath: /etc/XrayR/access.Log|g' $CONFIG_FILE
echo "Access log path enabled."

# 错误日志 - 启用错误日志路径
echo "Enabling error log path..."
sed -i 's|ErrorPath: # /etc/XrayR/error.log|ErrorPath: /etc/XrayR/error.log|g' $CONFIG_FILE
echo "Error log path enabled."

# 审计规则 - 启用规则列表路径
echo "Enabling rule list path..."
sed -i 's|RuleListPath: # /etc/XrayR/rulelist Path to local rulelist file|RuleListPath: /etc/XrayR/rulelist # Path to local rulelist file|g' $CONFIG_FILE
echo "Rule list path enabled."

# 更新完毕
echo "Configurations updated in $CONFIG_FILE"

# 安装 jq 且格式化 route.json
echo "$JQ_IN: Before"
cat $JQ_IN 

apt install jq -y && jq . $JQ_IN > $JQ_OUT && mv $JQ_OUT $JQ_IN
echo "----------------------------------------------------------"
echo "$JQ_IN: After"
cat $JQ_IN 