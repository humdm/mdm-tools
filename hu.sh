#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 华强北小胡定制版
# 微信: huhu-019 | 闲鱼: 福田吴彦祖 (胡师傅爱卖手机)
# ============================================

# 颜色定义
RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'; BLU='\033[1;34m'; CYAN='\033[1;36m'; NC='\033[0m'

# 显示横幅
show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}      欢迎使用 MacBook MDM 绕过工具 - 3.27版         ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🚀 华强北小胡 - 专业 MDM 配置锁绕过专家             ${CYAN}║${NC}"
    echo -e "${CYAN}║${RED}  📱 微信: huhu-019   🛒 闲鱼: 福田吴彦祖 /胡师傅爱卖手机 ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

# 1. 恢复模式：自动绕过 (一键完成)
do_recovery_bypass() {
    echo -e "\n${YEL}正在准备磁盘环境...${NC}"
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data"
    fi

    if [ ! -d "/Volumes/Data/private/var/db/dslocal/nodes/Default" ]; then
        echo -e "${RED}❌ 报错: 找不到 Data 卷，请在磁盘工具中挂载磁盘后再运行。${NC}"
        return
    fi

    echo -e "${BLU}👤 正在创建管理员用户: Apple (密码: 1234)...${NC}"
    DSCL_PATH="/Volumes/Data/private/var/db/dslocal/nodes/Default"
    
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple UserShell /bin/zsh
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple RealName "Apple"
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple UniqueID 501
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple PrimaryGroupID 20
    dscl -f "$DSCL_PATH" localhost -create /Local/Default/Users/Apple NFSHomeDirectory /Users/Apple
    dscl -f "$DSCL_PATH" localhost -passwd /Local/Default/Users/Apple 1234
    dscl -f "$DSCL_PATH" localhost -append /Local/Default/Groups/admin GroupMembership Apple
    mkdir -p "/Volumes/Data/Users/Apple"

    echo -e "${BLU}🛡️  正在封锁 MDM 服务器域名...${NC}"
    echo "0.0.0.0 acmdm.apple.com" >> "/Volumes/Macintosh HD/etc/hosts"
    echo "0.0.0.0 mdmenrollment.apple.com" >> "/Volumes/Macintosh HD/etc/hosts"
    echo "0.0.0.0 deviceenrollment.apple.com" >> "/Volumes/Macintosh HD/etc/hosts"
    echo "0.0.0.0 iprofiles.apple.com" >> "/Volumes/Macintosh HD/etc/hosts"
    echo "0.0.0.0 albert.apple.com" >> "/Volumes/Macintosh HD/etc/hosts"

    echo -e "${BLU}⚙️  正在清理激活残留记录...${NC}"
    touch "/Volumes/Data/private/var/db/.AppleSetupDone"
    rm -rf "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord" 2>/dev/null
    rm -rf "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound" 2>/dev/null
    touch "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
    touch "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"

    echo -e "${GRN}✅ 恢复模式一键绕过完成！请输入 reboot 重启。${NC}"
}

# 2. 正常模式：桌面终极加固 (5 条核心命令)
do_desktop_block() {
    echo -e "\n${YEL}正在执行桌面模式加固命令...${NC}"
    echo -e "${RED}请输入系统密码并按回车 (1234):${NC}"
    
    sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    
    echo -e "\n${GRN}✅ 加固命令执行完毕。${NC}"
}

# 3. 正常模式：检查状态
do_check_status() {
    echo -e "\n${YEL}🔍 正在验证监管状态 (Error Fetching 即代表成功):${NC}"
    sudo profiles show -type enrollment
}

# 4. 恢复模式：SIP 操作说明
do_sip_info() {
    echo -e "\n${PUR}══════════ SIP 系统完整性保护操作 ══════════${NC}"
    echo -e "${YEL}此操作必须在【恢复模式】终端直接输入命令：${NC}"
    echo -e ""
    echo -e "${GRN}关闭 SIP:${NC} csrutil disable"
    echo -e "${GRN}开启 SIP:${NC} csrutil enable"
    echo -e ""
    echo -e "${CYAN}提示：某些深度绕过操作需要先关闭 SIP 才能修改系统文件。${NC}"
    echo -e "${PUR}════════════════════════════════════════════${NC}"
}

# --- 主循环菜单 ---
show_banner
while true; do
    echo -e "\n${CYAN}══════════════ 操作菜单 ══════════════${NC}"
    echo -e " 1) 🚀 一键自动绕过 ${YEL}(仅限恢复模式)${NC}"
    echo -e " 2) 🛡️  终极屏蔽通知 ${GRN}(仅限正常模式)${NC}"
    echo -e " 3) 🔍 检查监管状态 ${GRN}(仅限正常模式)${NC}"
    echo -e " 4) 🔐 开启/关闭 SIP ${YEL}(仅限恢复模式)${NC}"
    echo -e " 5) ❌ 退出脚本"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    echo -ne "👉 请选择 [1-5]: "
    read -r choice < /dev/tty

    case $choice in
        1) do_recovery_bypass ;;
        2) do_desktop_block ;;
        3) do_check_status ;;
        4) do_sip_info ;;
        5) exit 0 ;;
        *) echo -e "${RED}无效选项，请重新选择。${NC}" ;;
    esac
    echo -ne "\n${BLU}按回车键返回菜单...${NC}"
    read -r < /dev/tty
done
