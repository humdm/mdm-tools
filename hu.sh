#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 最终版 (2026-03-27)
# 开发者：华强北小胡 (Xiao Hu) | 微信：huhu-019
# ==================================================

# 基础文字显示
RED='\033[1;31m'
GRN='\033[1;32m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 1. 提取并显示 SN
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
printf "\n${CYAN}***************************************************${NC}\n"
printf "${YEL}       Macbook 绕过工具 - 最终版 (2026-03-27)        ${NC}\n"
printf "${YEL}       本机序列号 (SN): ${CYAN}$SN${NC}\n"
printf "${RED}       售后微信：huhu-019                           ${NC}\n"
printf "${CYAN}***************************************************${NC}\n\n"

# 2. 授权验证
printf "${YEL}正在连接服务器验证...${NC}\n"
AUTH_LIST=$(curl -skL --retry 2 --connect-timeout 10 "$GITHUB_URL")

if [ -z "$AUTH_LIST" ]; then
    printf "${RED}❌ 无法访问授权名单，请确认 Wi-Fi 已连通。${NC}\n"
    exit 1
fi

if ! echo "$AUTH_LIST" | grep -qi "$SN"; then
    printf "${RED}❌ SN: $SN 未获授权。请联系微信：huhu-019${NC}\n"
    exit 1
fi

printf "${GRN}✅ 验证通过！${NC}\n"

# 3. 功能菜单 (单次执行模式，不循环，防止乱跳)
function show_menu() {
    printf "\n${CYAN}---------------- 功能菜单 ----------------${NC}\n"
    printf "${GRN} 1. [恢复模式] 自动绕过 (一键执行)${NC}\n"
    printf " 2. [恢复模式] 开启/关闭 SIP 服务\n"
    printf "${GRN} 3. [桌面模式] 终极屏蔽 (执行5条命令)${NC}\n"
    printf " 4. [通用模式] 检查监管锁状态\n"
    printf " 5. 立即重启电脑\n"
    printf " 6. 退出脚本\n"
    printf "${CYAN}------------------------------------------${NC}\n"
    
    # 核心修复：强制从 /dev/tty 获取键盘输入，防止脚本自跑
    printf "请输入数字 [1-6] 并按回车: "
    read -r opt < /dev/tty

    case "$opt" in
        1)
            printf "\n${YEL}执行恢复模式绕过...${NC}\n"
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
            printf "\n${GRN}✅ 操作成功！${NC}\n"
            show_menu
            ;;
        2)
            printf "\n1) 关闭 SIP | 2) 开启 SIP | 3) 返回: "
            read -r sip_opt < /dev/tty
            [ "$sip_opt" = "1" ] && csrutil disable
            [ "$sip_opt" = "2" ] && csrutil enable
            show_menu
            ;;
        3)
            printf "\n${YEL}执行桌面 5 条屏蔽命令...${NC}\n"
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
            sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
            sudo launchctl disable system/com.apple.ManagedClient.enroll 2>/dev/null
            printf "\n${GRN}✅ 命令已下发！${NC}\n"
            show_menu
            ;;
        4)
            printf "\n${YEL}检查状态结果：${NC}\n"
            RES=$(sudo profiles show -type enrollment 2>&1)
            printf "${CYAN}$RES${NC}\n"
            show_menu
            ;;
        5)
            reboot
            ;;
        6)
            exit 0
            ;;
        *)
            printf "${RED}无效输入，请重新运行或选择。${NC}\n"
            show_menu
            ;;
    esac
}

# 启动菜单
show_menu
