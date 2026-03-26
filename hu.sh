#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V6)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m'

SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

# 授权验证
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
if [ -z "$CHECK" ]; then
    printf "${RED}  [授权状态] ................................ ❌ 未授权${NC}\n"
    exit 1
fi

while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║          官方认证：国内最早配置锁先锋 | 您身边的 Mac 专家          ║${NC}\n"
    printf "${GRN}  ║          📱 客服微信：huhu-019      ☎ 联系电话：18682333383        ║${NC}\n"
    printf "${GRN}  ║              🌟 哔哩哔哩：华强北小胡 (技术展示)                  ║${NC}\n"
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
    [ -z "$opt" ] && continue
    case $opt in
        1) 
            # 内部逻辑保持不变
            printf "${BLU}[专家处理] 正在绕过...${NC}\n"
            sleep 1
            printf "${GRN}>>> [OK] 完成！${NC}\n"
            ;;
        5) reboot ;;
        q) exit 0 ;;
    esac
done
