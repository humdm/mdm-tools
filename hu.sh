#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 中文版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhu-009
# 说明: 国内MacBook MDM专家，最了解MDM
# ============================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 清屏
clear

# 显示欢迎信息
show_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${YEL}      欢迎使用 MacBook MDM 绕过工具 - 专业版         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家              ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 国内最早专售MacBook企业机MDM配置锁            ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🌟 最了解MDM，没有之一！                         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${YEL}   📱 微信: ${RED}huhu-009${CYAN}                               ║${NC}"
    echo -e "${CYAN}║${YEL}   🛒 闲鱼搜: ${RED}福田吴彦祖${CYAN}                             ║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${PUR}💡 发掘MacBook潜力，尽在我们店铺${NC}"
    echo -e "${PUR}🎯 让我们一起探索MacBook的未来，解锁你的技术世界！${NC}"
    echo ""
}

# 检查是否在恢复模式
check_recovery_mode() {
    if [ -d "/Volumes/Macintosh HD" ] || [ -d "/Volumes/Data" ]; then
        return 0
    else
        return 1
    fi
}

# 检查是否在恢复模式(严格检查)
require_recovery_mode() {
    if ! check_recovery_mode; then
        echo -e "${RED}❌ 错误: 此功能必须在恢复模式下运行！${NC}"
        echo -e "${YEL}💡 提示: 重启Mac并按住 Command + R 进入恢复模式${NC}"
        echo ""
        echo -e "${YEL}按任意键返回菜单...${NC}"
        read -n 1
        return 1
    fi
    return 0
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
    echo -e "${BLU}📝 请输入用户信息 (直接回车使用默认值)${NC}"
    echo ""
    echo -e "${GRN}请输入用户显示名称 [默认: Apple]:${NC}"
    read -p "👉 " realName
    realName="${realName:-Apple}"
    echo -e "${GRN}请输入登录用户名 (不含空格) [默认: Apple]:${NC}"
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

# 屏蔽MDM域名 (恢复模式 - 已补全 6 域名)
block_mdm_hosts_recovery() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YEL}🛡️  屏蔽MDM服务器域名 (恢复模式)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${YEL}🔒 正在添加hosts屏蔽规则...${NC}"
    cat >> /Volumes/Macintosh\ HD/etc/hosts << EOF

# ============================================
# MDM 屏蔽规则 - 由华强北小胡配置
# 微信: huhu-009
# ============================================
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 deviceservices-external.apple.com
# ============================================
EOF
    echo -e "${GRN}✅ MDM域名屏蔽完成！${NC}"
}

# 屏蔽MDM域名 (正常模式 - 已补全 6 域名)
block_mdm_hosts_normal() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YEL}🛡️  屏蔽MDM服务器域名 (正常模式)${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}⚠️  此操作需要管理员密码${NC}"
    echo ""
    if sudo grep -q "华强北小胡配置" /etc/hosts 2>/dev/null; then
        echo -e "${YEL}⚠️  检测到已存在MDM屏蔽规则${NC}"
        read -p "是否要重新添加? (y/n): 👉 " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then return; fi
        sudo sed -i.bak '/华强北小胡配置/,/============================================/d' /etc/hosts
    fi
    sudo bash -c 'cat >> /etc/hosts' << 'EOF'

# ============================================
# MDM 屏蔽规则 - 由华强北小胡配置
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 deviceservices-external.apple.com
# ============================================
EOF
    echo -e "${GRN}✅ MDM域名屏蔽完成！${NC}"
}

# 配置MDM设置
configure_mdm_settings() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YEL}⚙️  配置MDM设置${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    touch /Volumes/Data/private/var/db/.AppleSetupDone
    echo -e "${GRN}✅ 配置完成${NC}"
}

# 显示完成信息
show_completion() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${GRN}           🎉 MDM绕过配置完成！                      ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${BLU}  1. 关闭终端窗口                                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${BLU}  2. 重启您的MacBook                                 ${CYAN}║${NC}"
    echo -e "${CYAN}║${BLU}  3. 使用新创建的用户登录                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${BLU}  4. 尽情享受您的MacBook！                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

# 禁用MDM通知 (合并后的功能)
disable_mdm_notification() {
    echo ""
    echo -e "${YEL}🔕 禁用MDM通知...${NC}"
    if check_recovery_mode; then
        rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    else
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    fi
    echo -e "${GRN}✅ MDM通知已禁用${NC}"
}

# 检查MDM注册状态
check_mdm_enrollment() {
    sudo profiles show -type enrollment
}

# 一键自动绕过
auto_bypass_recovery() {
    rename_volume
    create_user
    block_mdm_hosts_recovery
    configure_mdm_settings
    show_completion
}

# 主菜单
show_menu() {
    if check_recovery_mode; then
        mode_text="${YEL}[当前: 恢复模式]${NC}"
    else
        mode_text="${GRN}[当前: 正常模式]${NC}"
    fi
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${YEL}📋 请选择操作: ${mode_text}${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GRN}1)${NC} 🚀 一键自动绕过MDM (仅恢复模式)"
    echo -e "${GRN}2)${NC} 🛡️  屏蔽MDM域名 (正常模式)"
    echo -e "${GRN}3)${NC} 🔕 禁用MDM通知"
    echo -e "${GRN}4)${NC} 🔍 检查MDM注册状态"
    echo -e "${GRN}5)${NC} 🔄 重启系统"
    echo -e "${GRN}6)${NC} ❌ 退出"
    echo ""
}

# 主程序
main() {
    show_banner
    while true; do
        show_menu
        read -p "请输入选项 [1-6]: " choice
        case $choice in
            1) require_recovery_mode && auto_bypass_recovery ;;
            2) block_mdm_hosts_normal ;;
            3) disable_mdm_notification ;;
            4) check_mdm_enrollment ;;
            5) reboot ;;
            6) exit 0 ;;
            *) echo -e "${RED}❌ 无效选项${NC}" ; sleep 1 ;;
        esac
        echo -e "\n按任意键返回菜单..."
        read -n 1
        clear
        show_banner
    done
}

main
