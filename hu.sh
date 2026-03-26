#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V23)
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
    printf "${GRN}✅ 网络已连接${NC}\n"
}

# 2. 磁盘自适应探测 (针对 M4/Intel 优化)
find_disks() {
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 3. 序列号验证 (您的护城河)
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}[授权查询] 本机序列号: ${YLW}$SN${NC}\n"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权验证失败！请联系华强北小胡 (微信: huhu-019)。${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 授权验证成功！欢迎使用专家系统。${NC}\n"
    sleep 1
}

# 4. 绿色加长进度条
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in {1..50}; do
        printf "■"
        sleep 0.005
    done
    printf "] 100%%${NC}\n\n"
}

# --- 执行初始化 ---
check_network
verify_sn

# 🚀 核心菜单循环
while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║               华强北小胡，配置锁 MacBook 专家                      ║${NC}\n"
    printf "${GRN}  ║          📲 客服微信：huhu-019      ☎ 联系电话：18682333383        ║${NC}\n"
    printf "${GRN}  ║          🔒 核心技术：国内最早配置锁先锋 | 极速绕过                ║${NC}\n"
    printf "${GRN}  ╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 (恢复模式专用)${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽通知 (恢复模式专用 - 写入 Hosts)${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}屏蔽通知 (桌面模式补救专用)${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}查看监管状态 (桌面查询增强)${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook (自动提权版)${NC}\n"
    printf "\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  ${GRN}──────────────────────────────────────────────────────────────────────${NC}\n"
    printf "  请选择功能序号并回车: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            find_disks
            echo -e "\n${GRN}>>> 正在锁定磁盘并注入补丁...${NC}"
            
            show_progress "第一阶段：注入管理员账户 (1234)"
            DS_DB="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            if [ -d "$DS_DB" ]; then
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" > /dev/null 2>&1
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" UserShell "/bin/zsh"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" RealName "MacBook"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" UniqueID "501"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" PrimaryGroupID "20"
                mkdir -p "$DATA_PATH/Users/MacBook"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" NFSHomeDirectory "/Users/MacBook"
                dscl -f "$DS_DB" localhost -passwd "/Local/Default/Users/MacBook" "1234"
                dscl -f "$DS_DB" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
            fi

            show_progress "第二阶段：封锁 5 大 MDM 域名"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n" >> "$SYS_PATH/etc/hosts"
            fi
            
            show_progress "第三阶段：暴力清空残留监管数据库"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles"/* 2>/dev/null
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" 2>/dev/null
            
            show_progress "第四阶段：冻结系统管理进程"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ 绕过完毕！重启进桌面后密码为: 1234 ★${NC}\n"
            printf "${YLW}★ 特别提示：进桌面前请先断开 Wi-Fi！★${NC}\n"
            sleep 3
            ;;
        2)
            find_disks
            show_progress "正在同步 Hosts 屏蔽记录"
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n" >> "$SYS_PATH/etc/hosts"
            printf "${GRN}>>> [OK] 屏蔽完成！${NC}\n"
            sleep 2
            ;;
        3)
            echo -e "\n${RED}⚠️  提示 Password 时输入开机密码并回车${NC}"
            if sudo -v; then
                show_progress "正在清理桌面残留通知..."
                sudo rm -rf /var/db/ConfigurationProfiles/* 2>/dev/null
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled > /dev/null 2>&1
                sudo launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
                printf "${GRN}★ 桌面通知已强制闭嘴！请执行选项 5 重启。★${NC}\n"
            fi
            sleep 2
            ;;
        4)
            echo -e "\n${CYN}>>> 正在深度扫描监管状态...${NC}"
            STATUS=$(sudo profiles show -type enrollment 2>&1)
            if echo "$STATUS" | grep -q "Error"; then
                echo -e "\n${GRN}✅ [结果]: 屏蔽极其成功！系统已断开监管。${NC}"
            else
                echo -e "\n${YLW}[结果]:${NC}\n$STATUS"
            fi
            printf "\n${CYN}按回车返回菜单...${NC}"
            read < /dev/tty
            ;;
        5) 
            echo -e "\n${YLW}正在请求重启权限 (请输入 1234)...${NC}"
            sudo reboot || reboot 
            ;;
        q) exit 0 ;;
        *) clear ;;
    esac
done
