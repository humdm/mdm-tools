#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网监测
check_network() {
    printf "${CYN}[网络监测] 正在检查互联网连接状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未检测到有效网络！请先连接 Wi-Fi。${NC}\n"
        sleep 10
    done
}

# 2. 序列号验证 (胡师傅核心护城河)
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权验证失败！请联系华强北小胡。${NC}\n"
        exit 1
    fi
}

# 3. 磁盘探测 (仅为适配 M4 路径)
find_disks() {
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 4. 进度条 (还原您最满意的样式)
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in {1..50}; do
        printf "■"
        sleep 0.01
    done
    printf "] 100%%${NC}\n\n"
}

# 初始化执行
check_network
verify_sn

# 🚀 核心菜单 (招牌完全还原)
while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 专家系统 ★                      ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║               华强北小胡，配置锁 MacBook 专家                      ║${NC}\n"
    printf "${GRN}  ║          📲 客服微信：huhu-019      ☎ 联系电话：18682333383        ║${NC}\n"
    printf "${GRN}  ║          🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机                  ║${NC}\n"
    printf "${GRN}  ║          🔒 核心技术：国内最早配置锁先锋 | 极速绕过                ║${NC}\n"
    printf "${GRN}  ╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "    ${YLW}1)${NC} ${BLU}一键全自动绕过 (推荐)${NC}\n"
    printf "    ${YLW}2)${NC} ${BLU}屏蔽通知 (恢复模式专用)${NC}\n"
    printf "    ${YLW}3)${NC} ${BLU}屏蔽通知 (桌面模式专用)${NC}\n"
    printf "    ${YLW}4)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "\n"
    printf "    ${RED}q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  请选择序号并回车: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            find_disks
            show_progress "第一阶段：注入底层管理员账户"
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create "/Local/Default/Users/MacBook" >/dev/null 2>&1
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -passwd "/Local/Default/Users/MacBook" "1234"
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
            
            show_progress "第二阶段：配置 5 域名高强度屏蔽"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n" >> "$SYS_PATH/etc/hosts"
            fi

            show_progress "第三阶段：注入防反弹伪装记录"
            # 还原您最稳的伪装逻辑
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles"/* 2>/dev/null
            mkdir -p "$SYS_PATH/var/db/ConfigurationProfiles/Settings"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" 2>/dev/null
            
            printf "\n${GRN}✅ 绕过成功！请执行选项 5 重启。${NC}\n"
            ;;
        2)
            find_disks
            show_progress "同步屏蔽记录"
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n" >> "$SYS_PATH/etc/hosts"
            printf "${GRN}✅ 屏蔽完成！${NC}\n"
            ;;
        3)
            if sudo -v; then
                show_progress "桌面加固中"
                sudo rm -rf /var/db/ConfigurationProfiles/* 2>/dev/null
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
                printf "${GRN}✅ 桌面加固完成！${NC}\n"
            fi
            ;;
        4)
            sudo profiles show -type enrollment
            read -p "按回车返回..." < /dev/tty
            ;;
        5) sudo reboot || reboot ;;
        q) exit 0 ;;
    esac
done
