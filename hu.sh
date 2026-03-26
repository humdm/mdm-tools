#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V35)
# ==========================================================

RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 网络与序列号验证
check_verify() {
    printf "${CYN}[网络监测] 正在检查互联网连接状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未检测到有效网络！请先连接 Wi-Fi 后继续。${NC}\n"
        sleep 5
    done
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}[授权查询] 正在验证序列号: ${NC}$SN\n"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权验证失败！请联系华强北小胡 (微信: huhu-009)。${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 授权验证成功！欢迎使用专家系统。${NC}\n"
}

# 2. 磁盘探测
find_disks() {
    [ -d "/Volumes/Macintosh HD - Data" ] && diskutil rename "Macintosh HD - Data" "Data"
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 🚀 招牌界面
show_banner() {
    echo -e "${CYN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYN}║${GRN}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}"
    echo -e "${CYN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
    echo -e "${CYN}║${GRN}  🚀 国内最早专售MacBook企业机MDM配置锁           ${CYAN}║${NC}"
    echo -e "${CYN}║${GRN}  🌟 最了解MDM，没有之一！                        ${CYAN}║${NC}"
    echo -e "${CYN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYN}║${GRN}  📱 微信: huhu-009      🛒 闲鱼搜: 福田吴彦祖       ${CYAN}║${NC}"
    echo -e "${CYN}╚═══════════════════════════════════════════════════════╝${NC}"
}

# 执行主逻辑
main_loop() {
    check_verify
    show_banner
    echo -e "\n1) 一键全自动绕过 (恢复模式)"
    echo -e "2) 屏蔽通知补救 (桌面模式)"
    echo -e "3) 查看监管状态 (Error为成功)"
    echo -e "4) 退出并重启"
    printf "\n请选择功能序号并回车: "
    read choice

    case $choice in
        1)
            find_disks
            # 还原核心账户创建逻辑，默认密码改为 1234
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
            
            # 6域名高强度屏蔽 (含外部校验)
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n0.0.0.0 deviceservices-external.apple.com\n" >> "$SYS_PATH/etc/hosts"
            
            # 伪装记录
            touch "$DATA_PATH/private/var/db/.AppleSetupDone"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            echo -e "${CYN}------ 成功自动绕过！默认密码: 1234。请重启。 ------${NC}"
            ;;
        2)
            # 整合5条暴力指令
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            sudo launchctl disable system/com.apple.ManagedClient.enroll
            # VPN 补丁 (锁定强制直连)
            sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
            echo -e "${GRN}✅ 桌面暴力补救完成！VPN风险已锁死。${NC}"
            ;;
        3)
            sudo profiles show -type enrollment
            ;;
        4)
            reboot
            ;;
        *)
            echo "无效选项"
            ;;
    esac
}

main_loop
