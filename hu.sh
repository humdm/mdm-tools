#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 2026 华强北全能版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhuu-020
# 说明: 国内MacBook MDM专家，支持恢复模式/桌面双兼容
# ============================================

RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 核心：自动获取系统数据分区挂载点
get_data_mount() {
    local mount=$(df | grep -E "Data|Macintosh HD" | awk '{print $NF}' | head -n 1)
    echo "${mount:-/Volumes/Data}"
}

# 环境检查
is_recovery() {
    [ -f "/etc/rc.recovery" ] || [ -d "/System/Installation" ]
}

# 1) 一键绕过
auto_bypass_recovery() {
    if ! is_recovery; then echo -e "${RED}❌ 仅限恢复模式${NC}"; return; fi
    local sys_path=$(get_data_mount)
    echo -e "${YEL}📍 正在定位磁盘: $sys_path${NC}"
    
    echo -e "${YEL}👤 创建新管理员用户${NC}"
    read -p "👉 用户名 [默认: Apple]: " username < /dev/tty
    username="${username:-Apple}"
    read -p "👉 密码 [默认: 1234]: " passw < /dev/tty
    passw="${passw:-1234}"
    
    local dscl_path="$sys_path/private/var/db/dslocal/nodes/Default"
    if [ ! -d "$dscl_path" ]; then
        echo -e "${RED}❌ 错误: 找不到路径 $dscl_path，请确保已在“磁盘工具”中挂载了磁盘！${NC}"
        return
    fi

    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "Apple"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"
    echo -e "${GRN}🎉 绕过配置完成！${NC}"
}

# 2) 屏蔽Hosts
block_mdm_hosts_universal() {
    if ! is_recovery; then echo -e "${RED}❌ 仅限恢复模式${NC}"; return; fi
    local hosts_path="$(get_data_mount)/etc/hosts"
    cat >> "$hosts_path" << EOF
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 vpp.itunes.apple.com
0.0.0.0 cloudddns.apple.com
0.0.0.0 gg.apple.com
EOF
    echo -e "${GRN}✅ Hosts 已屏蔽${NC}"
}

# 3) 关闭 SIP
disable_sip_fixed() {
    if ! is_recovery; then echo -e "${RED}❌ 仅限恢复模式${NC}"; return; fi
    echo -e "${YEL}⚠️  准备执行 SIP 关闭，请在出现提示时手动输入 y 并回车...${NC}"
    csrutil disable
}

# 4) 辅助禁用通知
disable_notify_recovery() {
    if ! is_recovery; then return; fi
    rm -rf /Volumes/*/var/db/ConfigurationProfiles/Settings/.cloudConfig* 2>/dev/null
    touch /Volumes/Data/private/var/db/.AppleSetupDone 2>/dev/null
    echo -e "${GRN}✅ 辅助通知禁用完成${NC}"
}

# 主循环
while true; do
    printf "\033c"
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 全能版          ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家               ${CYAN}║${NC}"
    echo -e "${CYAN}║${YEL}  📱 微信: ${RED}huhuu-020${CYAN}                               ║${NC}"
    echo -e "${CYAN}║${YEL}  🛒 闲鱼搜: ${RED}福田吴彦祖${CYAN}                             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    
    echo -e "${GRN}1)${NC} 🚀 一键绕过MDM (请先手动挂载磁盘)"
    echo -e "${GRN}2)${NC} 🛡️  屏蔽MDM关键域名 (仅恢复模式)"
    echo -e "${GRN}3)${NC} 🛠️  关闭 SIP 系统保护 (手动输入y)"
    echo -e "${GRN}4)${NC} 🔕 辅助禁用MDM通知"
    echo ""
    read -p "👉 请输入选项 [1-4]: " choice < /dev/tty
    
    case $choice in
        1) auto_bypass_recovery ;;
        2) block_mdm_hosts_universal ;;
        3) disable_sip_fixed ;;
        4) disable_notify_recovery ;;
        *) echo -e "${RED}无效选项${NC}" ;;
    esac
    echo -e "\n${YEL}按回车键继续...${NC}"
    read -n 1 < /dev/tty
done
