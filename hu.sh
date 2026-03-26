#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT (V43)
# ==========================================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 进度条逻辑
show_progress() {
    local label=$1
    echo -e "${BLU}[$label]${NC}"
    printf "${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.01; done
    printf "] 100%%${NC}\n\n"
}

# 1. 验证逻辑
check_verify() {
    echo -e "${CYAN}正在验证环境与授权...${NC}"
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        echo -e "${RED}❌ 授权失败！联系微信: huhu-009${NC}"
        exit 1
    fi
}

# 2. 磁盘探测
find_disks() {
    [ -d "/Volumes/Macintosh HD - Data" ] && diskutil rename "Macintosh HD - Data" "Data"
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 🚀 循环主程序开始
check_verify

while true; do
    printf "\033c" # 兼容性清屏
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 微信: huhu-009      🛒 闲鱼: 福田吴彦祖        ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"

    echo -e "\n${YEL}请选择功能序号：${NC}"
    echo -e "1) 一键全自动绕过 (恢复模式)"
    echo -e "2) 屏蔽通知补救 (桌面模式)"
    echo -e "3) 查看监管状态 (Error为成功)"
    echo -e "4) 重启系统"
    echo -e "5) 退出脚本"
    echo ""
    echo -n "请输入 [1-5] 并回车: "
    read choice

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
        
        show_progress "第三阶段：注入绕过伪装标记"
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        echo -e "${GRN}✅ 绕过完成！按任意键返回菜单...${NC}"
        read -n 1

    elif [ "$choice" = "2" ]; then
        show_progress "执行 5 条暴力补救与 VPN 防护补丁"
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
        echo -e "${GRN}✅ 补救完成！按任意键返回菜单...${NC}"
        read -n 1

    elif [ "$choice" = "3" ]; then
        sudo profiles show -type enrollment
        echo -e "${YEL}按任意键返回菜单...${NC}"
        read -n 1

    elif [ "$choice" = "4" ]; then
        reboot
    elif [ "$choice" = "5" ]; then
        break
    else
        echo -e "${RED}❌ 无效选项，请重新选择。${NC}"
        sleep 2
    fi
done

echo "脚本已退出。"
