#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 整合进化版
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhu-009 | 2026-03-27 更新
# 说明: 整合恢复模式绕过 + 桌面模式屏蔽
# ============================================

# 颜色定义
RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'; BLU='\033[1;34m'; CYAN='\033[1;36m'; NC='\033[0m'

# 显示欢迎横幅
show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}      欢迎使用 MacBook MDM 绕过工具 - 整合版         ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内最早专售企业机配置锁专家     ${CYAN}║${NC}"
    echo -e "${CYAN}║${RED}  📱 微信: huhu-009    🛒 闲鱼: 福田吴彦祖         ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

# 环境检查
check_recovery() {
    [ -d "/Volumes/Macintosh HD" ] || [ -d "/Volumes/Data" ]
}

# 自动寻找磁盘路径 (比 rename 更稳，适配所有系统版本)
get_paths() {
    # 自动寻找 Data 卷路径
    DATA_VOL=$(find /Volumes -maxdepth 2 -path "*/private/var/db/dslocal" | head -n 1 | sed 's|/private/var/db/dslocal||')
    # 自动寻找系统卷路径 (包含 etc 的那个)
    SYS_VOL=$(find /Volumes -maxdepth 2 -name "etc" | grep -v "Data" | head -n 1 | sed 's|/etc||')
}

# --- 功能模块 ---

# 1. 恢复模式：自动绕过 (一键完成)
do_recovery_bypass() {
    get_paths
    if [ -z "$DATA_VOL" ]; then
        echo -e "${RED}❌ 错误: 未能识别到 Data 磁盘，请确认磁盘已解锁。${NC}"
        return
    fi

    echo -e "\n${YEL}🚀 正在执行恢复模式一键绕过...${NC}"
    
    # 创建用户逻辑 (默认 MacBook / 123456)
    echo -e "${BLU}👤 正在创建管理员用户: MacBook...${NC}"
    dscl_path="$DATA_VOL/private/var/db/dslocal/nodes/Default"
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook UserShell /bin/zsh
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook RealName "MacBook"
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook UniqueID 501
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook PrimaryGroupID 20
    dscl -f "$dscl_path" localhost -create /Local/Default/Users/MacBook NFSHomeDirectory /Users/MacBook
    dscl -f "$dscl_path" localhost -passwd /Local/Default/Users/MacBook 123456
    dscl -f "$dscl_path" localhost -append /Local/Default/Groups/admin GroupMembership MacBook
    mkdir -p "$DATA_VOL/Users/MacBook"

    # 屏蔽 Hosts
    echo -e "${BLU}🛡️  正在封锁 MDM 服务器域名...${NC}"
    for d in acmdm.apple.com mdmenrollment.apple.com deviceenrollment.apple.com iprofiles.apple.com albert.apple.com; do
        echo "0.0.0.0 $d" >> "$SYS_VOL/etc/hosts"
    done

    # 写入激活标记
    echo -e "${BLU}⚙️  清理激活残留记录...${NC}"
    touch "$DATA_VOL/private/var/db/.AppleSetupDone"
    rm -rf "$SYS_VOL/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord" 2>/dev/null
    rm -rf "$SYS_VOL/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound" 2>/dev/null
    touch "$SYS_VOL/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
    touch "$SYS_VOL/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"

    echo -e "${GRN}✅ 恢复模式操作成功！请在终端输入 reboot 重启进入系统。${NC}"
}

# 2. 正常模式：桌面屏蔽 (整合那 5 条命令)
do_desktop_block() {
    echo -e "\n${YEL}🚀 正在执行桌面模式终极屏蔽...${NC}"
    echo -e "${RED}⚠️  注意: 请输入系统登录密码并回车 (输入时不显示):${NC}"
    
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
    sudo rm -f /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
    sudo launchctl disable system/com.apple.ManagedClient.enroll
    
    echo -e "${GRN}✅ 屏蔽命令执行完毕。${NC}"
    echo -e "${YEL}🔍 正在验证监管状态...${NC}"
    
    RES=$(sudo profiles show -type enrollment 2>&1)
    echo -e "${CYAN}$RES${NC}"
    
    if echo "$RES" | grep -q "Error"; then
        echo -e "\n${GRN}✨ 恭喜！验证结果匹配，MDM 锁已成功绕过！${NC}"
    else
        echo -e "\n${RED}⚠️  提示: 仍能查到监管信息，请检查网络是否已连通。${NC}"
    fi
}

# --- 主循环 ---
show_banner
while true; do
    if check_recovery; then
        MODE="${YEL}[恢复模式]${NC}"
    else
        MODE="${GRN}[桌面模式]${NC}"
    fi

    echo -e "\n${CYAN}════════════ 当前环境: $MODE ════════════${NC}"
    echo -e " 1) 🚀 一键自动绕过 (仅限恢复模式运行)"
    echo -e " 2) 🛡️  终极屏蔽通知 (仅限进入桌面后运行)"
    echo -e " 3) 🔍 查看监管状态 (验证是否成功)"
    echo -e " 4) 🔄 立即重启电脑"
    echo -e " 5) ❌ 退出脚本"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    
    echo -ne "👉 请输入数字 [1-5]: "
    read -r choice < /dev/tty

    case $choice in
        1) 
            if check_recovery; then do_recovery_bypass; else echo -e "${RED}❌ 请在恢复模式运行此项！${NC}"; fi 
            ;;
        2) 
            if ! check_recovery; then do_desktop_block; else echo -e "${RED}❌ 请进入系统桌面后再运行此项！${NC}"; fi
            ;;
        3) 
            echo -e "${YEL}正在查询...${NC}"
            sudo profiles show -type enrollment
            ;;
        4) reboot ;;
        5) exit 0 ;;
        *) echo -e "${RED}无效输入，请重新选择。${NC}" ;;
    esac
    echo -ne "\n${BLU}按回车键返回菜单...${NC}"
    read -r < /dev/tty
done
