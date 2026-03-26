#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V9)
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
    exit 1
else
    printf "${GRN}  [授权状态]   : ✅ 已授权 (欢迎使用专家版系统)${NC}\n"
fi

show_progress() {
    local duration=$1
    local label=$2
    printf "${BLU}[$label]${NC} ${YLW}["
    for i in $(seq 1 30); do
        printf "■"
        sleep 0.03
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
    printf "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 (含伪装 & 5 域名屏蔽)${NC}\n"
    printf "    ${YLW}▶ 2)${NC} ${BLU}屏蔽通知 (恢复模式 - 写入 Hosts)${NC}\n"
    printf "    ${YLW}▶ 3)${NC} ${BLU}屏蔽通知 (桌面模式 - 需输入密码)${NC}\n"
    printf "    ${YLW}▶ 4)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}▶ 5)${NC} ${BLU}立即重启 MacBook${NC}\n"
    printf "\n"
    printf "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}\n"
    printf "  ${GRN}──────────────────────────────────────────────────────────────────────${NC}\n"
    printf "  请选择功能序号并回车: "
    
    read opt
    case $opt in
        1) 
            # 1. 挂载与磁盘重命名
            if [ -d "/Volumes/Macintosh HD - Data" ]; then
                diskutil rename "Macintosh HD - Data" "Data"
            fi

            # 2. 用户创建逻辑
            echo -e "${BLU}请输入新用户名 (默认: MacBook): ${NC}"
            read realName
            realName="${realName:=MacBook}"
            username="${realName}"
            echo -e "${BLU}请输入密码 (默认: 123456): ${NC}"
            read passw
            passw="${passw:=123456}"
            
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            show_progress 1 "正在创建本地专家账户"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
            mkdir -p "/Volumes/Data/Users/$username"
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
            dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
            dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership $username
            
            # 3. 核心屏蔽：5 个域名全部写入
            show_progress 1 "正在封锁 5 个 MDM 核心域名"
            echo "0.0.0.0 deviceenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 acmdm.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 albert.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            
            # 4. 核心伪装：让系统以为已经安装了配置
            show_progress 1 "正在注入伪装记录以防止 VPN 开启反弹"
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
            # 🚀 关键：注入“已安装”和“未发现记录”伪装
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            
            # 5. 禁用服务
            launchctl disable system/com.apple.ManagedClient.enroll
            
            printf "${GRN}>>> [OK] 自动绕过完成！即使开启 VPN 也会因已存伪装而不反弹。${NC}\n"
            printf "${YLW}>>> 请输入 reboot 重启进入桌面。${NC}\n"
            sleep 2
            ;;
        5) reboot ;;
        q) exit 0 ;;
        *) echo "选错了，再选一次" ;;
    esac
done
