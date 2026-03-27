#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 4.0 专家整合版
# 开发者：华强北小胡 (Xiao Hu) | 微信：huhu-019
# ==================================================

# 基础颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 你的远程授权链接
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 1. 抬头展示与 SN 提取
printf "\033c"
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}       欢迎使用Macbook 绕过工具-4.0专业版            ${NC}"
echo -e "${RED}           售后微信：huhu-019                      ${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# 提取并显示本机序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo -e "${YEL}本机序列号 (SN): ${CYAN}$SN${NC}"
echo -e "${YEL}正在验证授权状态...${NC}"

# 2. 核心授权验证
AUTH_LIST=$(curl -skL --retry 2 --connect-timeout 5 "$GITHUB_URL")

if echo "$AUTH_LIST" | grep -qi "$SN"; then
    echo -e "${GRN}✅ 授权验证成功！进入专家模式...${NC}"
    sleep 1
else
    echo -e "${RED}***************************************************${NC}"
    echo -e "${RED}* 错误：当前序列号未获授权！                      *${NC}"
    echo -e "${RED}* 请联系华强北小胡进行授权：huhu-019               *${NC}"
    echo -e "${RED}***************************************************${NC}"
    exit 1
fi

# 3. 功能菜单逻辑
while true; do
    printf "\033c"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${YEL}        华强北小胡 - 4.0 自动化专家工具箱           ${NC}"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${GRN} 1. [恢复模式] 自动绕过 (创建用户+屏蔽域名)${NC}"
    echo -e " 2. [恢复模式] 开启/关闭 SIP 服务"
    echo -e "${GRN} 3. [桌面模式] 终极屏蔽 (执行5条命令屏蔽通知)${NC}"
    echo -e " 4. [通用模式] 检查监管锁状态 (验证是否成功)"
    echo -e " 5. 立即重启电脑"
    echo -e " 6. 退出脚本"
    echo -e "${CYAN}===================================================${NC}"
    read -p "请输入指令 [1-6]: " opt

    case $opt in
    1)
        echo -e "${YEL}正在执行恢复模式绕过...${NC}"
        DISK="/Volumes/Macintosh HD"
        DATA_DISK="/Volumes/Macintosh HD - Data"
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UserShell /bin/zsh
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook RealName "MacBook"
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UniqueID 501
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook PrimaryGroupID 20
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook NFSHomeDirectory /Users/MacBook
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -passwd /Local/Default/Users/MacBook 1234
        dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -append /Local/Default/Groups/admin GroupMembership MacBook
        for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com albert.apple.com; do
            echo "0.0.0.0 $d" >> "$DISK/etc/hosts"
        done
        touch "$DATA_DISK/private/var/db/.AppleSetupDone"
        rm -rf "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        touch "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        echo -e "${GRN}操作完成！请重启电脑。${NC}"
        sleep 3
        ;;
    2)
        echo -e "1) 关闭 SIP | 2) 开启 SIP | 3) 返回"
        read -p "选择: " sip_opt
        [ "$sip_opt" = "1" ] && csrutil disable
        [ "$sip_opt" = "2" ] && csrutil enable
        sleep 2
        ;;
    3)
        echo -e "${YEL}正在执行桌面模式终极屏蔽 (5条核心命令)...${NC}"
        # 依次执行你要求的 5 条命令
        sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
        sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
        sudo launchctl disable system/com.apple.ManagedClient.enroll 2>/dev/null
        echo -e "${GRN}5条屏蔽命令已全部执行完毕！${NC}"
        sleep 2
        ;;
    4)
        echo -e "${YEL}正在检查监管锁状态...${NC}"
        echo -e "${CYAN}---------------------------------------------------${NC}"
        # 执行检查命令
        CHECK_RESULT=$(sudo profiles show -type enrollment 2>&1)
        echo "$CHECK_RESULT"
        echo -e "${CYAN}---------------------------------------------------${NC}"
        
        # 自动判断是否匹配成功文字
        if echo "$CHECK_RESULT" | grep -q "Error fetching Device Enrollment configuration"; then
            echo -e "${GRN}✅ 恭喜！反馈结果匹配，绕过监管锁已成功搞定！${NC}"
        else
            echo -e "${YEL}提示：如果显示具体机构名称，说明尚未屏蔽成功。${NC}"
        fi
        read -p "按回车键继续..."
        ;;
    5)
        reboot
        ;;
    6)
        exit 0
        ;;
    *)
        echo "无效指令"
        sleep 1
        ;;
    esac
done
