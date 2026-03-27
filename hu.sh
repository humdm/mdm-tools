#!/bin/bash

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# --- 远程配置 (填入你的 GitHub Raw 链接) ---
GITHUB_URL="https://raw.githubusercontent.com/你的用户名/仓库名/main/sn.txt"

# --- 严格维持 4.0 抬头 ---
clear
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}       欢迎使用Macbook 绕过工具-专业版              ${NC}"
echo -e "${RED}           售后微信：huhu-019                      ${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# --- 1. 验证 Wi-Fi ---
if ! ping -c 1 -W 2 apple.com > /dev/null 2>&1; then
    echo -e "${RED}错误：Wi-Fi 未连接！${NC}"
    echo -e "${YEL}请先连接 Wi-Fi 后再运行脚本。${NC}"
    exit 1
fi

# --- 2. 验证序列号 (GitHub 实时校验) ---
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo -e "${YEL}本机序列号 (SN): ${CYAN}$CURRENT_SN${NC}"

# 从 GitHub 获取名单并实时匹配
AUTH_LIST=$(curl -s -f -L "$GITHUB_URL")

if [ $? -ne 0 ]; then
    echo -e "${RED}访问授权失败，请检查网络！${NC}"
    exit 1
fi

if echo "$AUTH_LIST" | grep -qi "$CURRENT_SN"; then
    echo -e "${GRN}授权验证成功！${NC}"
else
    echo -e "${RED}***************************************************${NC}"
    echo -e "${RED}* 错误：当前序列号未授权！                     *${NC}"
    echo -e "${RED}* 请联系华强北小胡开通：huhu-019               *${NC}"
    echo -e "${RED}***************************************************${NC}"
    exit 1
fi

# --- 3. 自动定位硬盘分区 ---
SYS_PATH=$(find /Volumes -maxdepth 2 -name "hosts" -path "*/etc/hosts" | sed 's|/etc/hosts||' | head -n 1)
DATA_PATH=$(find /Volumes -maxdepth 4 -name "dslocal" -path "*/private/var/db/dslocal" | sed 's|/private/var/db/dslocal||' | head -n 1)

if [ -z "$SYS_PATH" ] || [ -z "$DATA_PATH" ]; then
    echo -e "${RED}无法定位硬盘！请确保已挂载并解锁分区。${NC}"
    exit 1
fi

# --- 4. 功能菜单 ---
PS3='Please enter your choice: '
options=("自动绕过 (Recovery 模式)" "开启/关闭 SIP 服务" "屏蔽通知 (桌面模式)" "查看监管状态" "重启电脑" "退出")

select opt in "${options[@]}"; do
    case $opt in
    "自动绕过 (Recovery 模式)")
        echo -e "${GRN}执行绕过逻辑...${NC}"
        realName="MacBook"
        username="MacBook"
        passw="1234"
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

        for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
            echo "0.0.0.0 $domain" >> "$SYS_PATH/etc/hosts"
        done

        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        
        launchctl disable system/com.apple.ManagedClient.enroll
        launchctl disable system/com.apple.CloudConfigurationManager

        echo -e "${CYAN}------ 执行成功！请退出并重启 ------${NC}"
        break
        ;;

    "开启/关闭 SIP 服务")
        echo -e "1) 关闭 SIP | 2) 开启 SIP | 3) 返回"
        read -p "选择: " sip_opt
        [ "$sip_opt" = "1" ] && csrutil disable && echo "已执行关闭，请重启生效。"
        [ "$sip_opt" = "2" ] && csrutil enable && echo "已执行开启，请重启生效。"
        ;;

    "屏蔽通知 (桌面模式)")
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo launchctl disable system/com.apple.CloudConfigurationManager
        echo -e "${GRN}Done!${NC}"
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

    *) echo "Invalid option $REPLY" ;;
    esac
done
