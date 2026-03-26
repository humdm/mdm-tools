#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V17)
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

# 2. 磁盘精准探测 (针对 Intel 读不到盘优化)
find_disks() {
    # 模糊搜索系统盘和数据盘挂载点
    SYS_PATH=$(df | grep -v "Data" | grep "/Volumes/" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)
    DATA_PATH=$(df | grep "Data" | grep "/Volumes/" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)

    # 兜底方案
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Macintosh HD - Data"
    
    # 如果 Data 盘不存在，尝试用普通磁盘名
    [ ! -d "$DATA_PATH" ] && DATA_PATH="$SYS_PATH"
}

# 3. 初始化验证
check_network
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "\n${CYN}[本机序列号] : ${YLW}$SN${NC}\n"
    printf "${RED}[授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    exit 1
fi

# 4. 绿色加长进度条
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

# 🚀 核心菜单循环
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
            echo -e "\n${GRN}>>> 启动全系列适配流程...${NC}"
            
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName < /dev/tty
            realName="${realName:=MacBook}"
            echo -e "${BLU}请输入密码 (默认: 1234): ${NC}"
            read passw < /dev/tty
            passw="${passw:=1234}"
            
            show_progress "第一阶段：注入底层管理账户"
            # 兼容不同系统的 dscl 路径
            DS_DB="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            if [ -d "$DS_DB" ]; then
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
                dscl -f "$DS_DB" localhost -passwd "/Local/Default/Users/$realName" "$passw"
                dscl -f "$DS_DB" localhost -append "/Local/Default/Groups/admin" GroupMembership "$realName"
            fi

            show_progress "第二阶段：配置 5 域名高强度屏蔽"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n" >> "$SYS_PATH/etc/hosts"
            fi
            
            show_progress "第三阶段：注入防反弹伪装记录"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            
            show_progress "第四阶段：彻底禁用 MDM 引导进程"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ 绕过完毕！密码为: $passw ★${NC}\n"
            sleep 2
            ;;
        2)
            find_disks
            show_progress "正在同步 Hosts 屏蔽记录"
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n" >> "$SYS_PATH/etc/hosts"
            printf "${GRN}>>> [OK] 屏蔽完成！${NC}\n"
            sleep 2
            ;;
        3)
            echo -e "\n${RED}⚠️  提示 Password 时请输入开机密码并回车${NC}"
            if sudo -v; then
                show_progress "桌面加固中..."
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
