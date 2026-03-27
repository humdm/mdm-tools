#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 最终版 (2026-03-27)
# 开发者：华强北小胡 (Xiao Hu) | 微信：huhu-019
# ==================================================

# 基础显示配置
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 1. 抬头与 SN 提取
printf "\n${CYAN}***************************************************${NC}\n"
printf "${YEL}       欢迎使用Macbook 绕过工具 - 最终版             ${NC}\n"
printf "${YEL}             日期：2026-03-27                      ${NC}\n"
printf "${RED}           售后微信：huhu-019                      ${NC}\n"
printf "${CYAN}***************************************************${NC}\n\n"

SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
printf "${YEL}本机序列号 (SN): ${CYAN}$SN${NC}\n"

# 2. 授权验证 (增加连接时长限制)
printf "${YEL}正在连接服务器验证...${NC}\n"
AUTH_LIST=$(curl -skL --retry 2 --connect-timeout 10 --max-time 20 "$GITHUB_URL")

if [ -z "$AUTH_LIST" ]; then
    printf "${RED}❌ 无法访问授权名单，请检查 Wi-Fi 是否连接。${NC}\n"
    exit 1
fi

if ! echo "$AUTH_LIST" | grep -qi "$SN"; then
    printf "${RED}❌ SN: $SN 未获授权。请联系微信：huhu-019${NC}\n"
    exit 1
fi

printf "${GRN}✅ 验证通过！按一次回车键显示功能菜单...${NC}\n"
# 强制挂起，直到用户按下回车
read -r -n 1

# 3. 功能主循环 (去掉清屏，防止闪烁)
while true; do
    printf "\n${CYAN}===================================================${NC}\n"
    printf "${YEL}       华强北小胡 - 自动化专家工具箱 (最终版)        ${NC}\n"
    printf "${CYAN}===================================================${NC}\n"
    printf "${GRN} 1. [恢复模式] 自动绕过 (一键执行)${NC}\n"
    printf " 2. [恢复模式] 开启/关闭 SIP 服务\n"
    printf "${GRN} 3. [桌面模式] 终极屏蔽 (执行5条屏蔽命令)${NC}\n"
    printf " 4. [通用模式] 检查监管锁状态 (验证反馈)\n"
    printf " 5. 立即重启电脑\n"
    printf " 6. 退出脚本\n"
    printf "${CYAN}===================================================${NC}\n"
    
    # 核心修复：使用最原始的 read 捕获方式
    printf "请输入数字 [1-6] 并按回车: "
    read -r opt

    case "$opt" in
        1)
            printf "\n${YEL}正在执行恢复模式绕过...${NC}\n"
            DISK="/Volumes/Macintosh HD"
            DATA_DISK="/Volumes/Macintosh HD - Data"
            
            # 创建用户
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UserShell /bin/zsh
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook RealName "MacBook"
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UniqueID 501
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook PrimaryGroupID 20
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook NFSHomeDirectory /Users/MacBook
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -passwd /Local/Default/Users/MacBook 1234
            dscl -f "$DATA_DISK/private/var/db/dslocal/nodes/Default" localhost -append /Local/Default/Groups/admin GroupMembership MacBook
            
            # 屏蔽域名
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com albert.apple.com acmdm.apple.com; do
                echo "0.0.0.0 $d" >> "$DISK/etc/hosts"
            done
            
            # 标记位
            touch "$DATA_DISK/private/var/db/.AppleSetupDone"
            rm -rf "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            touch "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            
            printf "\n${GRN}✅ 操作成功！按回车返回。${NC}\n"
            read -r
            ;;
        2)
            printf "\n1) 关闭 SIP | 2) 开启 SIP | 3) 返回: "
            read -r sip_opt
            [ "$sip_opt" = "1" ] && csrutil disable
            [ "$sip_opt" = "2" ] && csrutil enable
            ;;
        3)
            printf "\n${YEL}执行桌面模式 5 条屏蔽命令...${NC}\n"
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
            sudo launchctl disable system/com.apple.ManagedClient.enroll 2>/dev/null
            printf "\n${GRN}✅ 命令已执行完毕！按回车返回。${NC}\n"
            read -r
            ;;
        4)
            printf "\n${YEL}检查状态中...${NC}\n"
            RES=$(sudo profiles show -type enrollment 2>&1)
            printf "${CYAN}$RES${NC}\n"
            if echo "$RES" | grep -q "Error fetching Device Enrollment configuration"; then
                printf "\n${GRN}✅ 验证成功：We can't determine if this machine is DEP enabled.${NC}\n"
            fi
            printf "按回车返回菜单..."
            read -r
            ;;
        5)
            reboot
            ;;
        6)
            exit 0
            ;;
        *)
            if [ -n "$opt" ]; then
                printf "${RED}无效输入，请只输入数字 1-6。${NC}\n"
                sleep 1
            fi
            ;;
    esac
done
