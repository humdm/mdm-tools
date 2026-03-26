#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT (V40)
# ==========================================================

# 颜色定义 - 完整保留您的视觉风格
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 修复报错：定义底层清屏函数，替代会报错的 clear 命令
clean_screen() {
    printf "\033c" 2>/dev/null || printf "\033[2J\033[H" 2>/dev/null
}

# 进度条逻辑 - 胡师傅要求的专业效果，完整保留
show_progress() {
    local label=$1
    echo -e "${BLU}[$label]${NC}"
    printf "${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.01; done
    printf "] 100%%${NC}\n\n"
}

# 1. 网络与授权验证
check_verify() {
    echo -e "${CYAN}[网络监测] 正在检查连接状态...${NC}"
    while ! ping -c 1 -W 2 google.com >/dev/null 2>&1 && ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; do
        echo -e "${RED}❌ 未检测到网络！请连接 Wi-Fi 后重试。${NC}"
        sleep 5
    done
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    echo -e "${CYAN}[授权查询] 正在验证序列号: ${NC}$SN"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        echo -e "${RED}❌ 授权验证失败！请联系小胡 (微信: huhu-009)${NC}"
        exit 1
    fi
    echo -e "${GRN}✅ 授权验证成功！欢迎使用专家系统。${NC}"
    sleep 1
}

# 2. 磁盘探测
find_disks() {
    [ -d "/Volumes/Macintosh HD - Data" ] && diskutil rename "Macintosh HD - Data" "Data"
    DATA_PATH=$(find /Volumes -maxdepth 1 -name "*Data*" | head -n 1)
    SYS_PATH=$(find /Volumes -maxdepth 1 -not -name "*Data*" -not -name "Image Volume" -not -name "Volumes" -not -name ".*" | grep "/Volumes/" | head -n 1)
    [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"
    [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
}

# 🚀 招牌 Banner - 胡师傅的广告必须保住
show_banner() {
    clean_screen
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${YEL}     欢迎使用 MacBook MDM 绕过工具 - 通杀版       ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内MacBook MDM专家             ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 国内最早专售MacBook企业机MDM配置锁           ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🌟 最了解MDM，最硬核的MDM商家！                   ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${YEL}  📱 微信: huhu-009      🛒 闲鱼搜: 福田吴彦祖       ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

# 运行主逻辑
check_verify
show_banner

echo -e "\n${YEL}📋 请选择功能序号并回车：${NC}"
echo -e "${GRN}1)${NC} 一键全自动绕过 (恢复模式专用)"
echo -e "${GRN}2)${NC} 屏蔽通知补救 (桌面模式专用)"
echo -e "${GRN}3)${NC} 查看监管状态 (Error为成功)"
echo -e "${GRN}4)${NC} 重启系统"
echo ""
printf "请输入 [1-4]: "
# 使用底层变量读取，解决输入锁死问题
read user_choice

case "$user_choice" in
    1)
        find_disks
        show_progress "第一阶段：创建专家账户 (MacBook / 1234)"
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" RealName "MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/MacBook" NFSHomeDirectory "/Users/MacBook"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/MacBook" "
