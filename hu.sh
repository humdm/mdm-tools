#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT (V45)
# ==========================================================

# 1. 颜色与视觉 (完整保留您的招牌风格)
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 进度条逻辑 (胡师傅要求保留)
show_progress() {
    local label=$1
    echo -e "${BLU}[$label]${NC}"
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

# 🚀 循环体开始 (保证是 done 结尾)
while true; do
    # 修复：不直接用 clear，改用 printf 彻底清屏
    printf "\033c" 
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 微信: huhu-009      🛒 闲鱼: 福田吴彦祖        ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"

    echo -e "\n${YEL}📋 请选择功能序号并回车：${NC}"
    echo -e "${GRN}1)${NC} 一键全自动绕过 (恢复模式专用)"
    echo -e "${GRN}2)${NC} 屏蔽通知补救 (桌面模式专用)"
    echo -e "${GRN}3)${NC} 查看监管状态 (显示Error为成功)"
    echo -e "${GRN}4)${NC} 重启电脑"
    echo -e "${GRN}5)${NC} 退出"
    echo ""
    printf "${YEL}请输入数字 [1-5]: ${NC}"
    
    # 关键修改：使用 read -r 并去掉可能报错的参数
    read -r choice

    # 关键修改：去掉输入内容里的多余空格或换行符
    choice=$(echo "$choice" | tr -d '[:space:]')

    case "$choice" in
        1)
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
            
            show_progress "第二阶段：执行 6 域名屏蔽 (含VPN补丁)"
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n0.0.0.0 deviceservices-external.apple.com\n" >> "$SYS_PATH/etc/hosts"
            
            show_progress "第三阶段：注入绕过标记"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            echo -e "${GRN}✅ 操作成功！按回车键返回菜单...${NC}"
            read
            ;;
        2)
            show_progress "执行 5 条暴力指令与 VPN 防护补丁"
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            sudo launchctl disable system/com.apple.ManagedClient.enroll
            sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
            echo -e "${GRN}✅ 补救完成！按回车键返回菜单...${NC}"
            read
            ;;
        3)
            echo -e "${BLU}监管状态查询：${NC}"
            sudo profiles show -type enrollment
            echo -e "${YEL}按回车返回菜单...${NC}"
            read
            ;;
        4)
            reboot
            ;;
        5)
            exit 0
            ;;
        *)
            # 如果输入不符合，直接刷新，不报错，防止卡死
            continue
            ;;
    esac
done
