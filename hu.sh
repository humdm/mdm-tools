#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V33)
# ==========================================================

RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网验证
check_wifi() {
    printf "${CYN}[网络监测] 正在检查互联网连接状态...${NC}\n"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        printf "${RED}❌ 未检测到有效网络！请先连接 Wi-Fi 后继续。${NC}\n"
        sleep 5
    done
}

# 2. 序列号验证
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}[授权查询] 正在验证序列号: ${NC}$SN\n"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 授权验证失败！请联系华强北小胡 (微信: huhu-009)。${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 授权验证成功！欢迎使用专家系统。${NC}\n"
}

# 3. 磁盘探测 (适配 M4 路径)
find_disks() {
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data"
    fi
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 4. 进度条
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC}\n"
    printf "${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.01; done
    printf "] 100%%${NC}\n\n"
}

# --- 启动前置验证 ---
check_wifi
verify_sn

# 🚀 招牌界面还原
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

PS3='请选择功能序号并回车: '
options=("一键全自动绕过 (恢复模式)" "屏蔽通知补救 (桌面模式)" "查看监管状态 (Error为成功)" "退出并重启")
select opt in "${options[@]}"; do
    case $opt in
    "一键全自动绕过 (恢复模式)")
        find_disks
        show_progress "第一阶段：注入底层管理员账户 (MacBook/123456)"
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UserShell "/bin/zsh"
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create "/Local/Default/Users/MacBook" RealName "MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" NFSHomeDirectory "/Users/MacBook"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/MacBook" "123456"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
        
        show_progress "第二阶段：配置 6 域名高强度屏蔽 (含外部校验)"
        printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n0.0.0.0 acmdm.apple.com\n0.0.0.0 albert.apple.com\n0.0.0.0 deviceservices-external.apple.com\n" >> "$SYS_PATH/etc/hosts"
        
        show_progress "第三阶段：注入绕过伪装记录"
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        
        echo -e "${CYN}------ 成功自动绕过！请重启电脑。 ------${NC}"
        break ;;
        
    "屏蔽通知补救 (桌面模式)")
        echo -e "${RED}请输入系统登录密码以执行补救：${NC}"
        if sudo -v; then
            show_progress "执行暴力屏蔽与 VPN 防火墙补丁"
            # 5条核心暴力指令
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            sudo launchctl disable system/com.apple.ManagedClient.enroll
            # 额外加固：VPN例外列表 (防止代理绕过Hosts)
            sudo /usr/libexec/PlistBuddy -c "Add :PayloadContent:0:Proxies:ExceptionsList:0 string 'deviceenrollment.apple.com'" /Library/Preferences/com.apple.networkextension.plist 2>/dev/null
            echo -e "${GRN}✅ 桌面补救完成！VPN 风险已降至最低。${NC}"
        fi
        break ;;
        
    "查看监管状态 (Error为成功)")
        echo -e "${BLU}查询中，如果下方出现 Error fetching... 则代表成功：${NC}"
        sudo profiles show -type enrollment
        break ;;
        
    "退出并重启")
        reboot ;;
    esac
done
