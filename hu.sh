#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 2026最终版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhu-019
# ============================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 精准检查环境
is_recovery() {
    if [ -f "/etc/rc.recovery" ] || [ -d "/System/Installation" ]; then
        return 0 # 恢复模式
    else
        return 1 # 正常桌面
    fi
}

show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}      欢迎使用 MacBook MDM 绕过工具 - 专业版         ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家              ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 微信: ${RED}huhu-019${NC}${GRN}  | 闲鱼: ${RED}福田吴彦祖${CYAN}      ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    if is_recovery; then
        echo -e "${YEL}📍 当前状态: [ 恢复模式 - RECOVERY ]${NC}"
    else
        echo -e "${GRN}📍 当前状态: [ 正常系统 - MACOS ]${NC}"
    fi
    echo ""
}

# --- 核心功能区 ---

# 功能3：进系统后的终极屏蔽 (正常模式执行)
final_block_normal() {
    if is_recovery; then
        echo -e "${RED}❌ 错误：此功能必须在【进入系统桌面】后运行！${NC}"
        return
    fi
    echo -e "${YEL}正在执行终极屏蔽指令，请输入开机密码并回车：${NC}"
    
    # 依次执行胡师傅要求的5条核心命令
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    
    echo -e "${GRN}✅ 5条指令执行完毕！正在检查状态...${NC}"
    echo ""
    sudo profiles show -type enrollment
    echo ""
    echo -e "${PUR}💡 看到 'Error fetching...' 字样即表示大功告成！${NC}"
}

# 功能4：禁用通知 (恢复模式辅助)
disable_notify_recovery() {
    if ! is_recovery; then
        echo -e "${RED}❌ 错误：此功能仅限在【恢复模式终端】运行。${NC}"
        return
    fi
    echo -e "${YEL}正在恢复模式下预设屏蔽文件...${NC}"
    rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled 2>/dev/null
    echo -e "${GRN}✅ 预设完成！${NC}"
}

# 主程序逻辑
main() {
    while true; do
        show_banner
        echo -e "${GRN}1)${NC} 🚀 一键自动绕过MDM ${YEL}(仅恢复模式)${NC}"
        echo -e "${GRN}2)${NC} 🛡️  屏蔽MDM域名 ${BLU}(仅正常系统)${NC}"
        echo -e "${GRN}3)${NC} 🏁 进系统后终极屏蔽 ${RED}(最后一步必点)${NC}"
        echo -e "${GRN}4)${NC} 🔕 恢复模式辅助屏蔽 ${YEL}(恢复模式)${NC}"
        echo -e "${GRN}5)${NC} 🔍 检查MDM注册状态"
        echo -e "${GRN}6)${NC} 🔄 重启系统"
        echo -e "${GRN}7)${NC} ❌ 退出"
        echo ""
        read -p "请输入选项 [1-7]: " choice

        case $choice in
            1) # 这里保留你原有的自动绕过逻辑... 
               echo -e "${BLU}正在执行一键绕过...${NC}" ;;
            2) # 屏蔽hosts
               if ! is_recovery; then
                   sudo bash -c "cat >> /etc/hosts << EOF
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
EOF"
                   echo -e "${GRN}✅ 域名屏蔽完成！${NC}"
               else
                   echo -e "${RED}❌ 请在正常系统运行此项${NC}"
               fi ;;
            3) final_block_normal ;;
            4) disable_notify_recovery ;;
            5) sudo profiles show -type enrollment ;;
            6) reboot ;;
            7) exit 0 ;;
            *) echo -e "${RED}无效选项${NC}" ;;
        esac
        echo -e "\n${YEL}按回车键返回菜单...${NC}"
        read
    done
}

main
