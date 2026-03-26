#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网验证 (新增)
check_wifi() {
    printf "${CYN}[网络监测] 正在检查互联网连接状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未检测到有效网络！请先连接 Wi-Fi 后继续。${NC}\n"
        sleep 5
    done
}

# 2. 序列号验证 (新增)
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}[授权查询] 正在验证序列号: ${NC}$SN\n"
    # 从您的 GitHub 获取 SN 授权列表
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权验证失败！请联系华强北小胡 (微信: huhu-009)。${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 授权验证成功！欢迎使用专家系统。${NC}\n"
}

# 3. 初始化路径探测
find_disks() {
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data"
    fi
    # 自动定位 Data 卷
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    # 自动定位系统卷 (非 Data, 非 Image)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
}

# --- 执行启动验证 ---
check_wifi
verify_sn

# 🚀 还原您最原始的界面布局
echo ""
echo -e "${CYN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYN}║                                                       ║${NC}"
echo -e "${CYN}║${GRN}     欢迎使用 MacBook MDM 绕过工具 - 专业版        ${CYAN}║${NC}"
echo -e "${CYN}║                                                       ║${NC}"
echo -e "${CYN}╠═══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYN}║                                                       ║${NC}"
echo -e "${CYN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
echo -e "${CYN}║${GRN}  🚀 国内最早专售MacBook企业机MDM配置锁           ${CYAN}║${NC}"
echo -e "${CYN}║${GRN}  🌟 最了解MDM，没有之一！                        ${CYAN}║${NC}"
echo -e "${CYN}║                                                       ║${NC}"
echo -e "${CYN}╠═══════════════════════════════════════════════════════╣${NC}"
echo -e "${CYN}║                                                       ║${NC}"
echo -e "${CYN}║${GRN}  📱 微信: huhu-009      🛒 闲鱼搜: 福田吴彦祖       ${CYAN}║${NC}"
echo -e "${CYN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

PS3='Please enter your choice: '
options=("自动绕过（恢复模式）" "屏蔽通知（桌面模式）" "屏蔽通知（恢复模式）" "查看监管状态" "退出")
select opt in "${options[@]}"; do
    case $opt in
    "自动绕过（恢复模式）")
        find_disks
        echo -e "${GRN}正在执行自动绕过...${NC}"
        
        # 1. 还原您最稳的账户创建逻辑
        echo -e "${BLU}请输入用户名 (默认: MacBook):${NC}"
        read username
        username="${username:=MacBook}"
        echo -e "${BLU}请输入密码 (默认: 123456):${NC}"
        read passw
        passw="${passw:=123456}"
        
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
        
        # 2. 还原 5 域名屏蔽
        echo "0.0.0.0 deviceenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
        echo "0.0.0.0 mdmenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
        echo "0.0.0.0 iprofiles.apple.com" >> "$SYS_PATH/etc/hosts"
        echo "0.0.0.0 acmdm.apple.com" >> "$SYS_PATH/etc/hosts"
        echo "0.0.0.0 albert.apple.com" >> "$SYS_PATH/etc/hosts"
        
        # 3. 还原伪装逻辑
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        launchctl disable system/com.apple.ManagedClient.enroll
        
        echo -e "${CYN}------ 成功自动绕过 ------${NC}"
        echo -e "${CYN}------ 手动输入 reboot 重启！ ------${NC}"
        break ;;
        
    "屏蔽通知（桌面模式）")
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        launchctl disable system/com.apple.ManagedClient.enroll
        echo -e "${CYN}------ 成功屏蔽通知，重启即可正常使用！ ------${NC}"
        break ;;
        
    "查看监管状态")
        sudo profiles show -type enrollment
        break ;;
        
    "退出")
        break ;;
    esac
done
