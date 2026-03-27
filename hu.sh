#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
CYAN='\033[0;36m'
YEL='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}* 华强北小胡 - Mac 专家工具箱 v4.3           *${NC}"
echo -e "${RED}* 售后微信：huhu-019                          *${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# --- 1. 第一步：验证 Wi-Fi 是否连接 ---
echo -e "${BLU}[1/2] 正在检测 Wi-Fi 连接状态...${NC}"
# 获取 Wi-Fi 网络名称，如果为空则视为未连接
WIFI_INFO=$(networksetup -getairportnetwork en0 2>/dev/null | grep "Current Wi-Fi Network")

if [ -z "$WIFI_INFO" ]; then
    echo -e "${RED}错误：Wi-Fi 未连接！${NC}"
    echo -e "${YEL}请先连接 Wi-Fi 后再运行此脚本。${NC}"
    echo ""
    exit 1
else
    echo -e "${GRN}Wi-Fi 已连接：$WIFI_INFO${NC}"
fi

# --- 2. 第二步：验证序列号授权 ---
echo -e "${BLU}[2/2] 正在验证序列号授权...${NC}"
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
SN_FILE="sn.txt"

if [ ! -f "$SN_FILE" ]; then
    echo -e "${RED}错误：未找到授权文件 sn.txt！${NC}"
    echo -e "${YEL}请联系华强北小胡获取授权：huhu-019${NC}"
    exit 1
fi

if grep -q "$CURRENT_SN" "$SN_FILE"; then
    echo -e "${GRN}序列号 [ $CURRENT_SN ] 验证通过！${NC}"
else
    echo -e "${RED}***************************************************${NC}"
    echo -e "${RED}* 错误：序列号 [ $CURRENT_SN ] 未授权！        *${NC}"
    echo -e "${RED}* 请联系华强北小胡处理：huhu-019               *${NC}"
    echo -e "${RED}***************************************************${NC}"
    exit 1
fi

echo ""
echo -e "${GRN}环境检查完毕，欢迎回来，小胡！${NC}"
echo -e "${CYAN}---------------------------------------------------${NC}"

# --- 3. 功能菜单 ---
PS3='请选择操作编号 (Enter choice): '
options=("自动绕过 (Recovery 模式)" "屏蔽通知 (桌面模式)" "查看监管状态" "重启电脑" "退出")

select opt in "${options[@]}"; do
    case $opt in
    "自动绕过 (Recovery 模式)")
        echo -e "${GRN}正在执行绕过逻辑...${NC}"
        
        # 磁盘挂载点处理
        if [ -d "/Volumes/Macintosh HD - Data" ]; then
            diskutil rename "Macintosh HD - Data" "Data"
        fi

        # 固定创建用户信息 (密码 1234)
        realName="MacBook"
        username="MacBook"
        passw="1234"
        
        dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "/Volumes/Data/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

        # 域名屏蔽
        for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
            echo "0.0.0.0 $domain" >> /Volumes/Macintosh\ HD/etc/hosts
        done

        # 清理标记文件
        touch /Volumes/Data/private/var/db/.AppleSetupDone
        rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        
        # 禁用服务
        launchctl disable system/com.apple.ManagedClient.enroll
        launchctl disable system/com.apple.CloudConfigurationManager

        echo -e "${GRN}操作成功！请手动输入 reboot 重启电脑。${NC}"
        break
        ;;

    "屏蔽通知 (桌面模式)")
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo launchctl disable system/com.apple.CloudConfigurationManager
        echo -e "${GRN}桌面屏蔽补丁已完成！${NC}"
        break
        ;;

    "查看监管状态")
        sudo profiles show -type enrollment
        break
        ;;

    "重启电脑")
        reboot
        break
        ;;

    "退出")
        exit 0
        ;;

    *) echo "无效选项 $REPLY" ;;
    esac
done
