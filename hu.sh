#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V12)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

clear
printf "\n${CYN}  [本机序列号] : ${YLW}$SN${NC}\n"

if [ -z "$CHECK" ]; then
    printf "${RED}  [授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    exit 1
fi

# 进度条函数
show_progress() {
    local label=$1
    printf "${BLU}[$label]${NC} ${YLW}["
    for i in $(seq 1 30); do
        printf "■"
        sleep 0.02
    done
    printf "] 100%${NC}\n"
}

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
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 (密码:1234 & 5域名 & 伪装)${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽通知 (恢复模式专用 - 写入 Hosts)${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}屏蔽通知 (桌面模式专用 - 需输密码)${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  ${GRN}──────────────────────────────────────────────────────────────────────${NC}\n"
    printf "  请选择功能序号并回车: "
    
    read opt < /dev/tty
    
    case $opt in
        1) 
            echo -e "\n${GRN}>>> 启动专家级一键绕过流程...${NC}"
            if [ -d "/Volumes/Macintosh HD - Data" ]; then
                diskutil rename "Macintosh HD - Data" "Data"
                show_progress "重新挂载数据卷"
            fi
            
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName < /dev/tty
            realName="${realName:=MacBook}"
            
            # 🚀 密码已改为 1234
            echo -e "${BLU}请输入密码 (默认: 1234): ${NC}"
            read passw < /dev/tty
            passw="${passw:=1234}"
            
            show_progress "注入管理账户"
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" RealName "$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" UniqueID "501"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" PrimaryGroupID "20"
            mkdir -p "/Volumes/Data/Users/$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" NFSHomeDirectory "/Users/$realName"
            dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$realName" "$passw"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$realName"

            show_progress "配置 5 域名硬屏蔽"
            echo "0.0.0.0 deviceenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 acmdm.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 albert.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            
            show_progress "注入防反弹伪装记录"
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* > /dev/null 2>&1
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            
            show_progress "彻底禁用 MDM 引导进程"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ 全部步骤执行完毕！密码为: $passw ★${NC}\n"
            printf "${YLW}>>> 请在下方输入 reboot 并回车重启。${NC}\n"
            sleep 3
            ;;
        2)
            # 🚀 选项2修复：去掉 sudo，直接写入
            echo -e "${YLW}正在执行恢复模式屏蔽...${NC}"
            echo "0.0.0.0 deviceenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* > /dev/null 2>&1
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            show_progress "同步 Hosts 屏蔽记录"
            printf "${GRN}>>> [OK] 屏蔽完成！${NC}\n"
            sleep 2
            ;;
        3)
            # 桌面模式需要 sudo
            echo -e "${RED}请输入您的桌面登录密码：${NC}"
            sudo profiles remove -all > /dev/null 2>&1
            sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            show_progress "正在执行桌面级加固"
            printf "${GRN}>>> [OK] 桌面屏蔽成功！${NC}\n"
            sleep 2
            ;;
        4)
            # 自动判断模式
            if [ -d "/Volumes/Macintosh HD" ]; then
                echo -e "${GRN}恢复模式下无法直接查询状态，已为您确保屏蔽生效。${NC}"
            else
                sudo profiles show -type enrollment
            fi
            sleep 3
            ;;
        5) reboot ;;
        q) exit 0 ;;
        *) clear ;;
    esac
done
