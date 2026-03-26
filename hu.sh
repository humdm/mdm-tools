#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT (V46)
# ==========================================================

# 1. 颜色与视觉定义 (保留胡师傅要求的排面)
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 进度条逻辑 (完整保留)
show_progress() {
    local label=$1
    echo -e "${BLU}[$label]${NC}"
    printf "${GRN}["
    # 稍微加快一点速度，防止在恢复模式下 sleep 导致终端假死
    for i in {1..25}; do printf "■"; sleep 0.01; done
    printf "] 100%%${NC}\n\n"
}

# 磁盘探测
find_disks() {
    [ -d "/Volumes/Macintosh HD - Data" ] && diskutil rename "Macintosh HD - Data" "Data"
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
}

# 🚀 循环体开始
while true; do
    # 彻底清屏并复位终端
    printf "\033c" 
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 微信: huhu-009      🛒 闲鱼: 福田吴彦祖        ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"

    echo -e "\n${YEL}📋 请选择功能并按回车：${NC}"
    echo -e "1) 一键全自动绕过 (恢复模式专用)"
    echo -e "2) 屏蔽通知补救 (桌面模式专用)"
    echo -e "3) 查看监管状态 (显示Error为成功)"
    echo -e "4) 重启系统"
    echo -e "5) 退出"
    echo ""
    
    # 关键修复：先提示，再读取，确保终端不闪烁卡死
    printf "${YEL}请输入数字 [1-5]: ${NC}"
    read -r choice
    # 过滤掉所有非数字的杂质
    choice=$(echo "$choice" | tr -dc '0-9')

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
        echo -e "${GRN}✅ 操作成功！密码 1234。请按回车返回...${NC}"
        read
    elif [ "$choice" = "2" ]; then
        show_progress "正在执行补救与 VPN 补丁"
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
        echo -e "${GRN}✅ 暴力补救完成！请按回车返回...${NC}"
        read
    elif [ "$choice" = "3" ]; then
        sudo profiles show -type enrollment
        echo -e "${YEL}按回车返回...${NC}"
        read
    elif [ "$choice" = "4" ]; then
        reboot
    elif [ "$choice" = "5" ]; then
        break
    else
        # 如果 choice 是空的或者乱码，直接跳过报错提示，重新显示菜单
        sleep 1
    fi
done

echo "脚本已退出。"
