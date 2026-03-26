#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT (V49)
# ==========================================================

# 1. 颜色与兼容性定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 进度条逻辑 (胡师傅要求保留)
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.01; done
    printf "] 100%%${NC}\n\n"
}

# 磁盘探测
find_disks() {
    [ -d "/Volumes/Macintosh HD - Data" ] && diskutil rename "Macintosh HD - Data" "Data"
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
}

# 2. 授权验证
printf "${CYAN}正在验证环境与授权...${NC}\n"
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
if [ -z "$CHECK" ]; then
    printf "${RED}❌ 授权失败！联系微信: huhu-009${NC}\n"
    exit 1
fi

# 3. 招牌 Banner (不再循环，彻底解决闪屏)
printf "\033c" 
printf "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}\n"
printf "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}\n"
printf "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}\n"
printf "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}\n"
printf "${CYAN}║${GRN}  🚀 微信: huhu-009      🛒 闲鱼: 福田吴彦祖        ${CYAN}║${NC}\n"
printf "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}\n"

printf "\n${YEL}📋 请选择功能序号：${NC}\n"
printf "1) 一键全自动绕过 (恢复模式专用)\n"
printf "2) 屏蔽通知补救 (桌面模式专用)\n"
printf "3) 查看监管状态 (显示Error为成功)\n"
printf "4) 重启电脑\n\n"

# 关键：彻底弃用 read -p，改为分两行写，强制终端等待
printf "${YEL}请输入数字 [1-4] 并按回车键: ${NC}"
read choice

# 过滤非法字符
choice=$(echo "$choice" | tr -dc '0-9')

# 执行逻辑 (改用 if/else 顺序结构，结尾带 done/exit)
if [ "$choice" = "1" ]; then
    find_disks
    show_progress "第一阶段：创建专家账户 (密码: 1234)"
    dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" RealName "MacBook"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" PrimaryGroupID "20"
    mkdir -p "$DATA_PATH/Users/MacBook"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" NFSHomeDirectory "/Users/MacBook"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/MacBook" "1234"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
    
    show_progress "第二阶段：执行 6 域名屏蔽 (含外验域名)"
    printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n0.0.0.0 deviceservices-external.apple.com\n" >> "$SYS_PATH/etc/hosts"
    
    show_progress "第三阶段：注入绕过标记"
    touch "$DATA_PATH/private/var/db/.AppleSetupDone"
    rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
    rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
    touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
    touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
    printf "${GRN}✅ 绕过成功！默认密码 1234。请输入 reboot 重启。${NC}\n"

elif [ "$choice" = "2" ]; then
    show_progress "正在执行暴力补救与 VPN 补丁"
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
    printf "${GRN}✅ 补救完成！${NC}\n"

elif [ "$choice" = "3" ]; then
    sudo profiles show -type enrollment

elif [ "$choice" = "4" ]; then
    reboot
else
    printf "${RED}❌ 无效输入 [$choice]，请重新运行脚本。${NC}\n"
fi

exit 0
