#!/bin/bash

# Check if address is provided
if [ -z "$1" ]
then
    echo -e "\e[31mError: No address provided.\e[0m"
    echo -e "\e[33mUsage: ./script.sh [ADDRESS]\e[0m"
    exit 1
fi

ADDRESS=$1

# Output details with color
echo -e "\e[34mWriting JSON to dns.json...\e[0m"

# Write JSON to dns.json
cat <<EOF > dns.json
{
    "servers": [
      "1.1.1.1",
      "8.8.8.8",
      {
        "address": "$ADDRESS",
        "port": 53,
        "domains": [
          "geosite:netflix",
          "geosite:disney",
          "geosite:bahamut",
          "geosite:bilibili",
          "geosite:dmm",
          "geosite:abema",
          "geosite:niconico",
          "domain:openai.com",
          "domain:chat.openai.com.cdn.cloudflare.net",
          "domain:openaiapi-site.azureedge.net",
          "domain:openaicom-api-bdcpf8c6d2e9atf6.z01.azurefd.net",
          "domain:openaicomproductionae4b.blob.core.windows.net",
          "domain:production-openaicom-storage.azureedge.net",
          "domain:o33249.ingest.sentry.io",
          "domain:openaicom.imgix.net",
          "domain:bard.google.com",
          "geosite:dazn",
          "geosite:hbo",
          "geosite:mytvsuper",
          "domain:byteoversea.com",
          "domain:muscdn.com",
          "domain:musical.ly",
          "domain:tik-tokapi.com",
          "domain:tiktok.com",
          "domain:tiktokcdn.com",
          "domain:tiktokv.com",
          "domain:p16-tiktokcdn-com.akamaized.net"
        ]
      }
    ]
}
EOF

echo -e "\e[32mDone writing to dns.json\e[0m"

echo -e "\e[34mWriting JSON to custom_outbound.json...\e[0m"

# Write JSON to custom_outbound.json
cat <<EOF > custom_outbound.json
[
    {
        "tag": "IPv4_out",
        "protocol": "freedom",
        "settings": {
            "domainStrategy": "UseIPv4"
        }
    },
    {
        "protocol": "blackhole",
        "tag": "block"
    }
]
EOF

echo -e "\e[32mDone writing to custom_outbound.json\e[0m"

echo -e "\e[34mWriting JSON to route.json...\e[0m"

# Write JSON to route.json
cat <<EOF > route.json
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
            "protocol": [
                "bittorrent"
            ]
        }
    ]
}
EOF

echo -e "\e[32mDone writing to route.json\e[0m"

echo -e "\e[34mModifying config.yml...\e[0m"

# Modify config.yml
sed -i 's/EnableDNS: false/EnableDNS: true/g' config.yml
sed -i 's/DNSType: AsIs/DNSType: UseIPv4/g' config.yml

echo -e "\e[32mDone modifying config.yml\e[0m"

echo -e "\e[34mChecking the changes...\e[0m"

# Check the changes
cat config.yml | grep EnableDNS
cat config.yml | grep DNSType
cat config.yml | grep SendIP

echo -e "\e[32mDone checking the changes\e[0m"
