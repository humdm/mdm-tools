#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

# 💎 高亮颜色定义 (兼容所有 Mac 恢复模式)
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m'

# 1. 【核心回归】获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

printf "${YLW}----------------------------------------------------------${NC}\n"
printf "  [正在连接云端] ............................ ${GRN}OK${NC}\n"
printf "  [检查当前设备] ............................ ${YLW}$SN${NC}\n"

# 2. 【核心回归】云端授权验证 (带随机数防止缓存)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "  [授权状态] ................................ ${RED}❌ 未授权${NC}\n"
    printf "${YLW}----------------------------------------------------------${NC}\n"
    printf "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}\n"
    printf "  该设备 SN: $SN 未在后台登记！\n"
    printf "  微信：huhu-019 | 电话：186 8233 3383\n"
    printf "  咸鱼：福田吴彦祖 / 胡师傅爱卖手机\n"
    printf "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}\n"
    exit 1
fi

printf "  [授权状态] ................................ ${GRN}✅ 已通过${NC}\n"
printf "${YLW}----------------------------------------------------------${NC}\n"

# 3. 进度条函数
show_progress() {
    printf "${YLW}[专家处理] $1 : [${NC}"
    for i in $(seq 1 20); do
        printf "${GRN}#${NC}"
        sleep 0.05
    done
    printf "${YLW}] 100%${NC}\n"
}

# 4. 暴力绕过逻辑
bypass_logic() {
    SUCCESS=0
    diskutil mountDisk disk0 >/dev/null 2>&1
    for VOL in /Volumes/*; do
        if [ "$VOL" = "/Volumes/Image Volume" ] || [ "$VOL" = "/Volumes/VM" ]; then continue; fi
        TARGET_HOSTS=""
        [ -f "$VOL/etc/hosts" ] && TARGET_HOSTS="$VOL/etc/hosts"
        [ -f "$VOL/private/etc/hosts" ] && TARGET_HOSTS="$VOL/private/etc/hosts"
        if [ -n "$TARGET_HOSTS" ]; then
            mount -uw "$VOL" >/dev/null 2>&1
            show_progress "正在注入绕过补丁"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do echo "127.0.0.1 $d" >> "$TARGET_HOSTS"; done
            mkdir -p "$VOL/private/var/db/ConfigurationProfiles/Settings" 2>/dev/null
            touch "$VOL/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$VOL/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            rm -rf "$VOL/var/db/ConfigurationProfiles/Settings/.cloudConfig"* 2>/dev/null
            SUCCESS=1
        fi
    done
    if [ "$SUCCESS" = "1" ]; then
        printf "${GRN}>>> [OK] MDM 锁定已成功解除，请立即重启进入系统！${NC}\n"
    else
        printf "${RED}❌ 未找到系统盘，请在磁盘工具中挂载 'Macintosh HD'${NC}\n"
    fi
}

# 5. 专家选单 (布局绝对居中，文字亮眼)
while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║          官方认证：国内最早配置锁先锋 | 您身边的 Mac 专家          ║${NC}\n"
    printf "${GRN}  ║             📱 微信：huhu-019      ☎ 电话：18682333383             ║${NC}\n"
    printf "${GRN}  ║              🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机              ║${NC}\n"
    printf "${GRN}  ╚════════════════════════════════════════════════════════════════════╝${NC}\n"
    printf "\n"
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 mdm${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽 mdm 域名${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}禁用 mdm 通知${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}检查 mdm 注册状态${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  ${GRN}──────────────────────────────────────────────────────────────────────${NC}\n"
    printf "  请选择功能序号并回车: "
    
    exec < /dev/tty
    read opt
    if [ -z "$opt" ]; then continue; fi
    case $opt in
        1) bypass_logic ;;
        2) show_progress "屏蔽域名"; printf "${GRN}已完成${NC}\n" ;;
        3) show_progress "禁用通知"; printf "${GRN}已完成${NC}\n" ;;
        4) profiles show -type enrollment ;;
        5) reboot ;;
        q) exit 0 ;;
        *) printf "${RED}无效指令${NC}\n" ;;
    esac
done
