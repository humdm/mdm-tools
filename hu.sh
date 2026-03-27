#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 最终版 (2026-03-27)
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

# 1. 抬头展示
printf "\033c"
printf "${CYAN}***************************************************${NC}\n"
printf "${YEL}       欢迎使用Macbook 绕过工具 - 最终版             ${NC}\n"
printf "${YEL}             日期：2026-03-27                      ${NC}\n"
printf "${RED}           客服微信：huhu-019                      ${NC}\n"
printf "${CYAN}***************************************************${NC}\n\n"

# 提取 SN
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
printf "${YEL}本机序列号 (SN): ${CYAN}$SN${NC}\n"
printf "${YEL}正在尝试连接服务器验证授权...${NC}\n"

# --- 核心改进：快速尝试连接，失败即报 ---
# -skL: 静默、跳过证书、跟随重定向; --connect-timeout: 5秒连不上就撤
AUTH_LIST=$(curl -skL --retry 1 --connect-timeout 5 --max-time 10 "$GITHUB_URL")

if [ -z "$AUTH_LIST" ]; then
    printf "\n${RED}❌ 网络请求超时！无法连接授权服务器。${NC}\n"
    printf "${YEL}请检查右上角 Wi-Fi 是否连接，或尝试更换热点。${NC}\n"
    exit 1
fi

if ! echo "$AUTH_LIST" | grep -qi "$SN"; then
    printf "\n${RED}❌ 授权验证失败！该序列号未获得最终版授权。${NC}\n"
    printf "${RED}请联系华强北小胡：huhu-019${NC}\n"
    exit 1
fi

printf "${GRN}✅ 授权验证通过！${NC}\n"
sleep 1

# 2. 功能主循环
while true; do
    printf "\n${CYAN}===================================================${NC}\n"
    printf "${YEL}       华强北小胡 - 自动化专家工具箱 (最终版)        ${NC}\n"
    printf "${CYAN}===================================================${NC}\n"
    printf "${GRN} 1. [恢复模式] 自动绕过 (一键执行)${NC}\n"
    printf " 2. [恢复模式] 开启/关闭 SIP 服务\n"
    printf "${GRN} 3. [桌面模式] 终极屏蔽 (执行5条屏蔽命令)${NC}\n"
    printf " 4. [通用模式] 检查监管锁状态 (验证反馈)${NC}\n"
    printf " 5. 立即重启电脑\n"
    printf " 6. 退出脚本\n"
    printf "${CYAN}===================================================${NC}\n"
    
    printf "请输入数字 [1-6] 后按回车: "
    read opt

    case "$opt" in
        1)
            printf "\033c${YEL}正在执行恢复模式绕过逻辑...${NC}\n"
            DISK="/Volumes/Macintosh HD"
            DATA_DISK="/Volumes/Macintosh HD - Data"
            
            # 创建账户
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
            
            # 设置标记
            touch "$DATA_DISK/private/var/db/.AppleSetupDone"
            rm -rf "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            touch "$DISK/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            
            printf "\n${GRN}✅ 恢复模式操作成功！按回车返回。${NC}\n"
            read
            ;;
        2)
            printf "\n1) 关闭 SIP | 2) 开启 SIP | 3) 返回: "
            read sip_opt
            [ "$sip_opt" = "1" ] && csrutil disable
            [ "$sip_opt" = "2" ] && csrutil enable
            ;;
        3)
            printf "\033c${YEL}执行桌面模式终极屏蔽 (5条核心命令)...${NC}\n"
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
                printf "\n${GRN}✅ 绕过已搞定：We can't determine if this machine is DEP enabled.${NC}\n"
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
                printf "${RED}无效指令: $opt${NC}\n"
                sleep 1
            fi
            ;;
    esac
done
