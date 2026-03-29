#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 2026 华强北全能版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhu-019
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

# 检查环境函数 (精确判断桌面还是恢复模式)
is_recovery() {
    if [ -f "/etc/rc.recovery" ] || [ -d "/System/Installation" ]; then
        return 0 # 恢复模式
    else
        return 1 # 正常桌面
    fi
}

# 必须在恢复模式的检查
require_recovery_mode() {
    if ! is_recovery; then
        echo -e "${RED}❌ 错误: 此功能必须在恢复模式下运行！${NC}"
        echo -e "${YEL}💡 提示: 请重启Mac并按住 Command+R 进入恢复模式后再运行。${NC}"
        echo ""
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
    echo -e "${CYAN}║${YEL}  📱 微信: ${RED}huhu-019${CYAN}                               ║${NC}"
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

# 重命名磁盘卷
rename_volume() {
    echo -e "${BLU}📀 检查磁盘卷名称...${NC}"
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        echo -e "${YEL}🔄 正在重命名磁盘卷...${NC}"
        diskutil rename "Macintosh HD - Data" "Data"
        echo -e "${GRN}✅ 磁盘卷重命名完成${NC}"
    fi
}

# 创建新用户
create_user() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YEL}👤 创建新管理员用户${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GRN}请输入用户显示名称 [默认: Apple]:${NC}"
    read -p "👉 " realName
    realName="${realName:-Apple}"
    echo -e "${GRN}请输入登录用户名 [默认: Apple]:${NC}"
    read -p "👉 " username
    username="${username:-Apple}"
    echo -e "${GRN}请输入登录密码 [默认: 1234]:${NC}"
    read -p "👉 " passw
    passw="${passw:-1234}"

    dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
    echo -e "${YEL}🔨 正在创建用户...${NC}"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
    mkdir -p "/Volumes/Data/Users/$username"
    echo -e "${GRN}✅ 用户创建成功！${NC}"
}

# --- 核心逻辑：全自动适配屏蔽Hosts (选项2) ---
block_mdm_hosts_universal() {
    if is_recovery; then
        echo -e "${YEL}正在恢复模式下，直接修改磁盘Hosts文件...${NC}"
        # 写入10大顶级域名
        cat >> /Volumes/Macintosh\ HD/etc/hosts << EOF

# ============================================
# MDM 顶级屏蔽规则 - 华强北小胡 (huhu-019)
# ============================================
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 vpp.itunes.apple.com
0.0.0.0 gdmf.apple.com
0.0.0.0 cloudddns.apple.com
0.0.0.0 gg.apple.com
0.0.0.0 appldnld.apple.com
# ============================================
EOF
        echo -e "${GRN}✅ 恢复模式下磁盘 Hosts 屏蔽成功！${NC}"
    else
        echo -e "${YEL}正在桌面环境下，通过sudo修改系统Hosts文件...${NC}"
        echo -e "${RED}⚠️ 请输入您的开机密码并回车：${NC}"
        sudo bash -c 'cat >> /etc/hosts' << 'EOF'

# ============================================
# MDM 顶级屏蔽规则 - 华强北小胡 (huhu-019)
# ============================================
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 vpp.itunes.apple.com
0.0.0.0 gdmf.apple.com
0.0.0.0 cloudddns.apple.com
0.0.0.0 gg.apple.com
0.0.0.0 appldnld.apple.com
# ============================================
EOF
        echo -e "${GRN}✅ 桌面环境下系统 Hosts 屏蔽成功！${NC}"
    fi
}

# --- 核心逻辑：终极屏蔽指令 (选项3) ---
final_block_normal() {
    if is_recovery; then
        echo -e "${RED}❌ 错误: 此功能需在正常系统桌面运行！${NC}"
        return
    fi
    echo ""
    echo -e "${YEL}🚀 执行进入系统后的终极屏蔽 (5个指令)...${NC}"
    echo -e "${RED}⚠️ 请输入您的开机密码并回车：${NC}"
    
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    
    echo -e "${GRN}✅ 5条屏蔽指令执行完毕！正在检查状态...${NC}"
    echo ""
    sudo profiles show -type enrollment
    echo ""
    echo -e "${PUR}💡 看到 'Error fetching...' 字样即表示成功搞定！${NC}"
}

# 禁用通知 (恢复模式辅助)
disable_notify_recovery() {
    if ! require_recovery_mode; then return; fi
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound 2>/dev/null
    touch /Volumes/Data/private/var/db/.AppleSetupDone 2>/dev/null
    echo -e "${GRN}✅ 恢复模式预设屏蔽完成${NC}"
}

# 一键绕过 (仅恢复模式)
auto_bypass_recovery() {
    if ! require_recovery_mode; then return; fi
    rename_volume
    create_user
    # 调用通用的屏蔽函数
    block_mdm_hosts_universal
    disable_notify_recovery
    echo -e "${GRN}🎉 恢复模式配置完成！请重启进入系统执行最后一步(选项3)。${NC}"
}

# 主循环
while true; do
    show_banner
    echo -e "${GRN}1)${NC} 🚀 一键自动绕过MDM ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}2)${NC} 🛡️  顶级屏蔽10大域名 ${BLU}(全环境通用)${NC}"
    echo -e "${GRN}3)${NC} 🏁 进系统后终极屏蔽 ${RED}(最后一步必做)${NC}"
    echo -e "${GRN}4)${NC} 🔕 辅助禁用MDM通知 ${YEL}(仅恢复模式)${NC}"
    echo -e "${GRN}5)${NC} 🔍 检查MDM注册状态"
    echo -e "${GRN}6)${NC} 🔄 重启系统"
    echo -e "${GRN}7)${NC} ❌ 退出"
    echo ""
    read -p "请输入选项 [1-7]: " choice
    case $choice in
        1) auto_bypass_recovery ;;
        2) block_mdm_hosts_universal ;;
        3) final_block_normal ;;
        4) disable_notify_recovery ;;
        5) sudo profiles show -type enrollment ;;
        6) reboot ;;
        7) exit 0 ;;
        *) echo -e "${RED}无效选项${NC}" ; sleep 1 ;;
    esac
    echo -e "\n${YEL}按回车键返回菜单...${NC}"
    read -n 1
done
