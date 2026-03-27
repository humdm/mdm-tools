#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 终极版 3.27
# 开发者：华强北小胡 (Xiao Hu) | 微信：huhu-019
# ==================================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 远程配置
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 1. 抬头与授权验证
printf "\033c"
printf "${CYAN}***************************************************${NC}\n"
printf "${YEL}       欢迎使用Macbook 终极版 3.27             ${NC}\n"
printf "${RED}           售后微信：huhu-019                      ${NC}\n"
printf "${CYAN}***************************************************${NC}\n\n"

# 提取 SN
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
printf "${YEL}本机序列号 (SN): ${CYAN}$SN${NC}\n"
printf "${YEL}正在从服务器调取授权状态...${NC}\n"

# 授权校验
AUTH_LIST=$(curl -skL --retry 2 --connect-timeout 5 "$GITHUB_URL")

if ! echo "$AUTH_LIST" | grep -qi "$SN"; then
    printf "\n${RED}❌ 授权失败！该序列号未获得 4.0 授权。${NC}\n"
    printf "${RED}请联系华强北小胡：huhu-019${NC}\n"
    exit 1
fi

printf "${GRN}✅ 授权验证通过！即将进入菜单...${NC}\n"
sleep 1

# 2. 功能主循环
while true; do
    printf "\n${CYAN}===================================================${NC}\n"
    printf "${YEL}        自动绕过MDM - 终极版。26.3.27.               ${NC}\n"
    printf "${CYAN}===================================================${NC}\n"
    printf "${GRN} 1. [恢复模式] 自动绕过 (创建用户+屏蔽域名)${NC}\n"
    printf " 2. [恢复模式] 开启/关闭 SIP 服务\n"
    printf "${GRN} 3. [桌面模式] 终极屏蔽 (执行5条命令屏蔽通知)${NC}\n"
    printf " 4. [通用模式] 检查监管锁状态 (验证是否成功)\n"
    printf " 5. 立即重启电脑\n"
    printf " 6. 退出脚本\n"
    printf "${CYAN}===================================================${NC}\n"
    
    # 修复：在 Bash 3.2 下最稳健的输入方式
    printf "请输入数字 [1-6] 后按回车: "
    read opt

    case "$opt" in
        1)
            printf "\033c${YEL}正在执行恢复模式绕过...${NC}\n"
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
            
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com albert.apple.com acmdm.apple.com; do
                echo "0.0.0.0 $d" >> "$DISK/etc/hosts"
            done
            
            touch "$DATA_DISK/private/var/db/.AppleSetupDone"
            rm -rf "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            touch "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            
            printf "\n${GRN}✅ 操作成功！按回车键返回菜单。${NC}\n"
            read
            ;;
        2)
            printf "\n1) 关闭 SIP | 2) 开启 SIP | 3) 返回: "
            read sip_opt
            [ "$sip_opt" = "1" ] && csrutil disable
            [ "$sip_opt" = "2" ] && csrutil enable
            ;;
        3)
            printf "\033c${YEL}正在执行桌面模式终极屏蔽 (5条核心命令)...${NC}\n"
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
            sudo launchctl disable system/com.apple.ManagedClient.enroll 2>/dev/null
            printf "\n${GRN}✅ 5条屏蔽命令已执行！按回车键返回。${NC}\n"
            read
            ;;
        4)
            printf "\033c${YEL}检查状态中...${NC}\n"
            RES=$(sudo profiles show -type enrollment 2>&1)
            printf "${CYAN}$RES${NC}\n"
            if echo "$RES" | grep -q "Error fetching Device Enrollment configuration"; then
                printf "\n${GRN}✅ 提示：绕过监管锁已搞定！${NC}\n"
            fi
            printf "按回车返回菜单..."
            read
            ;;
        5)
            reboot
            ;;
        6)
            exit 0
            ;;
        *)
            if [ ! -z "$opt" ]; then
                printf "${RED}无效选项: $opt${NC}\n"
                sleep 1
            fi
            ;;
    esac
done
