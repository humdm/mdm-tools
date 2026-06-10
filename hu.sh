#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 2026 华强北全能版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhuu-020
# 说明: 国内MacBook MDM专家，支持恢复模式/桌面双兼容
# ============================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 环境检查
is_recovery() {
    if [ -f "/etc/rc.recovery" ] || [ -d "/System/Installation" ]; then
        return 0 
    else
        return 1 
    fi
}

require_recovery_mode() {
    if ! is_recovery; then
        echo -e "${RED}❌ 错误: 此功能必须在恢复模式下运行！${NC}"
        echo -e "${YEL}按任意键返回菜单...${NC}"
        read -n 1
        return 1
    fi
    return 0
}

# 显示欢迎信息
show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 全能版          ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家               ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 国内最早专售MacBook企业机MDM配置锁             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🌟 最了解MDM，没有之一！                          ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${YEL}  📱 微信: ${RED}huhuu-020${CYAN}                               ║${NC}"
    echo -e "${CYAN}║${YEL}  🛒 闲鱼搜: ${RED}福田吴彦祖${CYAN}                             ║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    if is_recovery; then
        echo -e "${YEL}📍 当前状态: [ 恢复模式 - RECOVERY ]${NC}"
    else
        echo -e "${GRN}📍 当前状态: [ 正常系统 - MACOS ]${NC}"
    fi
    echo ""
}

# 1) 一键绕过
auto_bypass_recovery() {
    if ! require_recovery_mode; then return; fi
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data"
    fi
    echo -e "${YEL}👤 创建新管理员用户${NC}"
    read -p "👉 用户名 [默认: Apple]: " username
    username="${username:-Apple}"
    read -p "👉 密码 [默认: 1234]: " passw
    passw="${passw:-1234}"
    dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "Apple"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
    mkdir -p "/Volumes/Data/Users/$username"
    block_mdm_hosts_universal
    disable_notify_recovery
    echo -e "${GRN}🎉 绕过配置完成！${NC}"
}

# 2) 屏蔽Hosts
block_mdm_hosts_universal() {
    if is_recovery; then
        cat >> /Volumes/Macintosh\ HD/etc/hosts << EOF
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 vpp.itunes.apple.com
0.0.0.0 cloudddns.apple.com
0.0.0.0 gg.apple.com
EOF
        echo -e "${GRN}✅ Hosts 屏蔽成功！${NC}"
    else
        sudo bash -c 'cat >> /etc/hosts' << 'EOF'
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 vpp.itunes.apple.com
0.0.0.0 cloudddns.apple.com
0.0.0.0 gg.apple.com
EOF
        echo -e "${GRN}✅ Hosts 屏蔽成功！${NC}"
    fi
}

# 3) 关闭 SIP
disable_sip() {
    if ! require_recovery_mode; then return; fi
    csrutil disable
    echo -e "${GRN}✅ SIP 已关闭${NC}"
}

# 4) 辅助禁用MDM通知
disable_notify_recovery() {
    if ! require_recovery_mode; then return; fi
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
    touch /Volumes/Data/private/var/db/.AppleSetupDone 2>/dev/null
    echo -e "${GRN}✅ 辅助通知禁用完成${NC}"
}

# 5) 终极屏蔽
final_block_normal() {
    if is_recovery; then echo -e "${RED}❌ 请在正常桌面运行${NC}"; return; fi
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    echo -e "${GRN}✅ 终极屏蔽指令执行完毕${NC}"
}

# 6) 检查状态
check_status() {
    if is_recovery; then echo -e "${RED}❌ 请在正常桌面运行${NC}"; return; fi
    sudo profiles show -type enrollment
}

# 7) 开启 SIP
enable_sip() {
    if ! require_recovery_mode; then return; fi
    csrutil enable
    echo -e "${GRN}✅ SIP 已开启${NC}"
}

# 主循环
while true; do
    show_banner
    echo -e "${GRN}1)${NC} 🚀 一键自动绕过MDM ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}2)${NC} 🛡️  屏蔽MDM关键域名 ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}3)${NC} 🛠️  关闭 SIP 系统保护 ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}4)${NC} 🔕 辅助禁用MDM通知 ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}5)${NC} 🏁 进系统后终极屏蔽 ${BLU}(仅正常模式)${NC}"
    echo -e "${GRN}6)${NC} 🔍 检查MDM注册状态 ${BLU}(仅正常模式)${NC}"
    echo -e "${GRN}7)${NC} 🔒 开启 SIP 系统保护 ${YEL}(仅恢复模式)${NC}"
    echo ""
    read -p "请输入选项 [1-7]: " choice
    case $choice in
        1) auto_bypass_recovery ;;
        2) block_mdm_hosts_universal ;;
        3) disable_sip ;;
        4) disable_notify_recovery ;;
        5) final_block_normal ;;
        6) check_status ;;
        7) enable_sip ;;
        *) echo -e "${RED}无效选项${NC}" ; sleep 1 ;;
    esac
    echo -e "\n${YEL}按回车键继续...${NC}"
    read -n 1
done
