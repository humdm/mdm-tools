#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM M4 EXPERT (V19)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m'

# 1. 获取 SN 并验证
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    printf "\n${RED}❌ 序列号 $SN 未授权！${NC}\n"
    exit 1
fi

# 🚀 核心菜单
while true; do
    printf "\n${GRN}--- 华强北小胡 M4 专用工具箱 ---${NC}\n"
    printf "1) 一键自动绕过 (M4 强力推荐)\n"
    printf "2) 重启电脑\n"
    printf "q) 退出\n"
    printf "请选择: "
    read opt < /dev/tty

    case $opt in
        1)
            echo -e "\n${YLW}正在搜寻 M4 磁盘路径...${NC}"
            # 暴力搜寻路径
            SYS_PATH=$(df | grep -v "Data" | grep "/Volumes/" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)
            DATA_PATH=$(df | grep "Data" | grep "/Volumes/" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)
            
            # 默认路径兜底
            [ -z "$SYS_PATH" ] && SYS_PATH="/Volumes/Macintosh HD"
            [ -z "$DATA_PATH" ] && DATA_PATH="/Volumes/Data"

            echo -e "${GRN}发现磁盘: $SYS_PATH${NC}"
            
            # 第一步：建用户
            echo -e "${BLU}正在注入管理员账户 (默认密码: 1234)...${NC}"
            DS_DB="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            if [ -d "$DS_DB" ]; then
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" > /dev/null 2>&1
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" UserShell "/bin/zsh"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" RealName "MacBook"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" UniqueID "501"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" PrimaryGroupID "20"
                mkdir -p "$DATA_PATH/Users/MacBook"
                dscl -f "$DS_DB" localhost -create "/Local/Default/Users/MacBook" NFSHomeDirectory "/Users/MacBook"
                dscl -f "$DS_DB" localhost -passwd "/Local/Default/Users/MacBook" "1234"
                dscl -f "$DS_DB" localhost -append "/Local/Default/Groups/admin" GroupMembership "MacBook"
                echo -e "${GRN}[OK] 用户创建成功${NC}"
            fi

            # 第二步：屏蔽域名 (核心步骤)
            echo -e "${BLU}正在封锁 5 大 MDM 域名...${NC}"
            if [ -d "$SYS_PATH/etc" ]; then
                chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
                echo "0.0.0.0 deviceenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
                echo "0.0.0.0 mdmenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
                echo "0.0.0.0 iprofiles.apple.com" >> "$SYS_PATH/etc/hosts"
                echo "0.0.0.0 acmdm.apple.com" >> "$SYS_PATH/etc/hosts"
                echo "0.0.0.0 albert.apple.com" >> "$SYS_PATH/etc/hosts"
                echo -e "${GRN}[OK] 域名屏蔽成功${NC}"
            fi

            # 第三步：伪装标志
            echo -e "${BLU}正在注入跳过设置向导标志...${NC}"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" 2>/dev/null
            
            echo -e "${GRN}★ M4 绕过成功！请重启并使用密码 1234 登录 ★${NC}"
            sleep 3
            ;;
        2) reboot ;;
        q) exit 0 ;;
    esac
done
