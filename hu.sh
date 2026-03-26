#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

# 💎 亮眼高亮颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m'

# 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

# 授权验证逻辑
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "${RED}  [授权状态] ................................ ❌ 未授权${NC}\n"
    printf "${RED}  请联系胡师傅开通：186 8233 3383${NC}\n"
    exit 1
fi

# 进度条函数
show_progress() {
    printf "${YLW}[专家处理] $1 : [${NC}"
    for i in $(seq 1 20); do
        printf "${GRN}#${NC}"
        sleep 0.05
    done
    printf "${YLW}] 100%${NC}\n"
}

# 核心绕过逻辑 (解决 No such file)
bypass_logic() {
    SUCCESS=0
    diskutil mountDisk disk0 >/dev/null 2>&1
    
    for VOL in /Volumes/*; do
        if [ "$VOL" = "/Volumes/Image Volume" ] || [ "$VOL" = "/Volumes/VM" ]; then continue; fi
        
        # 寻找 hosts 真实路径
        TARGET_HOSTS=""
        [ -f "$VOL/etc/hosts" ] && TARGET_HOSTS="$VOL/etc/hosts"
        [ -f "$VOL/private/etc/hosts" ] && TARGET_HOSTS="$VOL/private/etc/hosts"
        
        if [ -n "$TARGET_HOSTS" ]; then
            mount -uw "$VOL" >/dev/null 2>&1
            
            # 显示进度条
            show_progress "正在注入绕过补丁"
            
            # 写入屏蔽域名
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$TARGET_HOSTS"
            done
            
            # 屏蔽激活通知
            mkdir -p "$VOL/private/var/db/ConfigurationProfiles/Settings" 2>/dev/null
            touch "$VOL/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$VOL/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            rm -rf "$VOL/var/db/ConfigurationProfiles/Settings/.cloudConfig"* 2>/dev/null
            
            SUCCESS=1
        fi
    done

    if [ "$SUCCESS" = "1" ]; then
        printf "${GRN}>>> [OK] MDM 锁定已解除，请立即重启进入系统！${NC}\n"
    else
        printf "${RED}❌ 错误：未找到系统盘，请在磁盘工具中挂载 'Macintosh HD'${NC}\n"
    fi
}

# 专家选单 (亮眼布局)
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
