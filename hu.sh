#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V16)
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
        printf "${YLW}当前可用 Wi-Fi 列表:${NC}\n"
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s | awk '{print $1}' | sed '1d'
        printf "${CYN}等待网络就绪... (10秒后重试)${NC}\n"
        sleep 10
    done
    printf "${GRN}✅ 网络已连接，正在进入专家系统...${NC}\n"
}

# 2. 磁盘自适应探测 (解决 Intel 读不到盘)
find_disks() {
    SYS_PATH=$(df | grep -E "Macintosh HD$" | awk '{print $6}')
    DATA_PATH=$(df | grep -E "Macintosh HD - Data$|Data$" | awk '{print $6}')
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
}

# 3. 授权验证
check_network
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "\n${CYN}[本机序列号] : ${YLW}$SN${NC}\n"
    printf "${RED}[授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    exit 1
fi

# 4. 绿色加长进度条 (50格)
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in $(seq 1 50); do
        printf "■"
        sleep 0.01
    done
    printf "] 100%%${NC}\n\n"
}

# 🚀 核心循环开始
while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║               华强北小胡，配置锁 MacBook 专家                      ║${NC}\n"
    printf "${GRN}  ║          📲 客服微信：huhu-019      ☎ 联系电话：18682333383        ║${NC}\n"
    printf "${GRN}  ║          🎵 抖音搜索：华强北小胡    📺 哔哩哔哩：华强北小胡        ║${NC}\n"
    printf "${GRN}  ║          🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机                  ║${NC}\n"
    printf "${GRN}  ║          🔒 核心技术：国内最早配置锁先锋 | 极速绕过                ║${NC}\n"
    printf "${GRN}  ╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 (密码:1234 & 5域名 & 伪装)${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽通知 (恢复模式专用 - 写入 Hosts)${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}屏蔽通知 (桌面模式专用 - 需输密码)${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  ${GRN}──────────────────────────────────────────────────────────────────────${NC}\n"
    printf "  请选择功能序号并回车: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            find_disks
            echo -e "\n${GRN}>>> 启动全兼容绕过流程 (Intel/Apple)...${NC}"
            if [ -d "$DATA_PATH" ]; then
                diskutil rename "$DATA_PATH" "Data" > /dev/null 2>&1
                DATA_PATH="/Volumes/Data"
            fi
            
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName < /dev/tty
            realName="${realName:=MacBook}"
            echo -e "${BLU}请输入密码 (默认: 1234): ${NC}"
            read passw < /dev/tty
            passw="${passw:=1234}"
            
            show_progress "第一阶段：注入底层管理账户"
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -passwd "/Local/Default/Users/$realName" "$passw"
            dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -append "/Local/Default/Groups/admin" GroupMembership "$realName"

            show_progress "第二阶段：配置 5 域名高强度屏蔽"
            chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
            echo "0.0.0.0 deviceenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 mdmenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 iprofiles.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 acmdm.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 albert.apple.com" >> "$SYS_PATH/etc/hosts"
            
            show_progress "第三阶段：注入防反弹伪装记录"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfig"* > /dev/null 2>&1
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            
            show_progress "第四阶段：彻底禁用 MDM 引导进程"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ 全部步骤执行完毕！密码为: $passw ★${NC}\n"
            sleep 2
            ;;
        2)
            find_disks
            show_progress "正在同步 Hosts 屏蔽记录"
            echo "0.0.0.0 deviceenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 mdmenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 iprofiles.apple.com" >> "$SYS_PATH/etc/hosts"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            printf "${GRN}>>> [OK] 屏蔽完成！${NC}\n"
            sleep 2
            ;;
        3)
            echo -e "\n${RED}⚠️  注意：提示 Password 时输入开机密码并回车${NC}"
            if sudo -v; then
                show_progress "清理系统残留描述符"
                sudo profiles remove -all > /dev/null 2>&1
                show_progress "注入桌面级防反弹伪装"
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled > /dev/null 2>&1
                show_progress "封锁后台管理进程"
                sudo launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
                printf "${GRN}★ 桌面加固完成！★${NC}\n"
            fi
            sleep 2
            ;;
        4)
            sudo profiles show -type enrollment
            sleep 3
            ;;
        5) reboot ;;
        q) exit 0 ;;
        *) clear ;;
    esac
done
# ==========================================================
# END OF SCRIPT - HUA QIANG BEI XIAO HU
# ==========================================================
