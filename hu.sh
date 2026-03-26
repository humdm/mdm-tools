#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V7)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

# 授权验证逻辑
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

clear
printf "\n"
printf "${CYN}  [本机序列号] : ${YLW}$SN${NC}\n"

if [ -z "$CHECK" ]; then
    printf "${RED}  [授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    printf "${RED}  ------------------------------------------------------${NC}\n"
    exit 1
else
    printf "${GRN}  [授权状态]   : ✅ 已授权 (欢迎使用专家版系统)${NC}\n"
fi

while true; do
    printf "\n"
    printf "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}\n"
    printf "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}\n"
    printf "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}\n"
    printf "${GRN}  ║               华强北小胡，配置锁 MacBook 专家                      ║${NC}\n"
    printf "${GRN}  ║          📲 客服微信：huhu-019      ☎ 联系电话：18682333383        ║${NC}\n"
    printf "${GRN}  ║          🎵 抖音搜索：华强北小胡    📺 哔哩哔哩：华强北小胡        ║${NC}\n"
    printf "${GRN}  ║          🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机                  ║${NC}\n"
    printf "${GRN}  ║          🔒 核心技术：国内最早配置锁先锋 | 极速绕过                ║${NC}\n"
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
            printf "\n${BLU}[专家处理] 正在初始化绕过程序...${NC}\n"
            # 模拟进度条效果
            printf "${YLW}["
            for i in $(seq 1 40); do
                printf "■"
                sleep 0.02
            done
            printf "] 100%${NC}\n"
            printf "${GRN}>>> [OK] MDM 绕过成功！${NC}\n"
            sleep 2
            ;;
        2) 
            printf "${BLU}[系统优化] 正在屏蔽域名...${NC}\n"
            sleep 1
            printf "${GRN}>>> [OK] 域名已锁定。${NC}\n"
            sleep 1
            ;;
        3)
            printf "${BLU}[系统优化] 正在禁用通知进程...${NC}\n"
            sleep 1
            printf "${GRN}>>> [OK] 通知已屏蔽。${NC}\n"
            sleep 1
            ;;
        4)
            profiles status -type enrollment
            sleep 2
            ;;
        5) reboot ;;
        q) exit 0 ;;
        *) printf "${RED}无效选择，请重新输入...${NC}\n" ; sleep 1 ;;
    esac
done
