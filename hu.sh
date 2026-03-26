#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V18)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网监测 (保持原样)
check_network() {
    printf "${CYN}[网络监测] 正在检查互联网连接状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未检测到有效网络！请先连接 Wi-Fi。${NC}\n"
        printf "${YLW}当前可用 Wi-Fi 列表:${NC}\n"
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk '{print $1}' | sed '1d'
        printf "${CYN}等待网络就绪... (10秒后重试)${NC}\n"
        sleep 10
    done
    printf "${GRN}✅ 网络已连接，正在进入专家系统...${NC}\n"
}

# 2. 授权验证 (保持原样)
check_network
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "\n${CYN}[本机序列号] : ${YLW}$SN${NC}\n"
    printf "${RED}[授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    exit 1
fi

# 3. 绿色加长进度条 (50格)
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in $(seq 1 50); do
        printf "■"
        sleep 0.005
    done
    printf "] 100%%${NC}\n\n"
}

# 🚀 核心菜单循环
while true; do
    printf "\n${GRN}  ★ 华强北小胡 - MDM 终极全兼容版 (M4 适配) ★${NC}\n"
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 (密码:1234 & 5域名 & 伪装)${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽通知 (恢复模式专用)${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}屏蔽通知 (桌面模式专用)${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  请选择功能序号并回车: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            # 针对 M4 磁盘路径深度探测
            DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
            SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
            
            [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
            [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"

            echo -e "\n${GRN}>>> 正在锁定磁盘: $SYS_PATH${NC}"
            
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName < /dev/tty
            realName="${realName:=MacBook}"
            
            show_progress "第一阶段：注入底层管理账户"
            DS_DB="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            if [ -d "$DS_DB" ]; then
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" UserShell "/bin/zsh"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" RealName "$realName"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" UniqueID "501"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" PrimaryGroupID "20"
                mkdir -p "$DATA_PATH/Users/$realName"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" NFSHomeDirectory "/Users/$realName"
                dscl -f "$DS_DB" localhost -passwd "/Local/Default/Users/$realName" "1234"
                dscl -f "$DS_DB" localhost -append "/Local/Default/Groups/admin" GroupMembership "$realName"
            fi

            show_progress "第二阶段：配置 5 域名高强度屏蔽"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                printf "\n0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n" >> "$SYS_PATH/etc/hosts"
            fi
            
            show_progress "第三阶段：注入防反弹伪装记录"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" 2>/dev/null
            
            show_progress "第四阶段：彻底禁用 MDM 引导进程"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ M4 绕过完毕！密码统一为: 1234 ★${NC}\n"
            sleep 2
            ;;
        2)
            # 快速屏蔽
            DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
            SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" | grep "/Volumes/" | head -n 1)
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n" >> "$SYS_PATH/etc/hosts"
            printf "${GRN}>>> [OK] 屏蔽完成！${NC}\n"
            sleep 2
            ;;
        3)
            if sudo -v; then
                sudo profiles remove -all > /dev/null 2>&1
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled > /dev/null 2>&1
                printf "${GRN}★ 桌面加固完成！★${NC}\n"
            fi
            sleep 2
            ;;
        5) reboot ;;
        q) exit 0 ;;
        *) clear ;;
    esac
done
