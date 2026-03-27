#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 4.0 极简专业版
# 开发者：华强北小胡 (Xiao Hu)
# 售后微信：huhu-019
# ==================================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 远程授权地址
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 1. 抬头展示
printf "\033c"
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}       欢迎使用Macbook 绕过工具-4.0专业版            ${NC}"
echo -e "${RED}           售后微信：huhu-019                      ${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# 2. 提取序列号并强制授权验证
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo -e "${YEL}检查授权状态... (SN: ${CYAN}$CURRENT_SN${YEL})${NC}"

# 仅保留核心下载逻辑，不加网络前置判断
AUTH_LIST=$(curl -skL --retry 2 "$GITHUB_URL")

if echo "$AUTH_LIST" | grep -qi "$CURRENT_SN"; then
    echo -e "${GRN}✅ 授权成功！${NC}"
    sleep 1
else
    echo -e "${RED}❌ 授权失败！请联系：huhu-019${NC}"
    exit 1
fi

# 3. 核心功能菜单 (默认盘符逻辑)
while true; do
    printf "\033c"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${YEL}        华强北小胡 - 4.0 极简工具箱                 ${NC}"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${GRN} 1. 自动绕过 (默认 Macintosh HD)${NC}"
    echo -e " 2. 关闭 SIP 服务"
    echo -e " 3. 开启 SIP 服务"
    echo -e " 4. 查看监管状态"
    echo -e " 5. 立即重启电脑"
    echo -e " 6. 退出脚本"
    echo -e "${CYAN}===================================================${NC}"
    read -p "请输入指令: " opt

    case $opt in
    1)
        echo -e "${YEL}正在执行绕过...${NC}"
        # 默认新机器恢复模式路径
        SYS_PATH="/Volumes/Macintosh HD"
        DATA_PATH="/Volumes/Macintosh HD - Data"
        
        # 1. 创建用户
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UserShell /bin/zsh
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook RealName "MacBook"
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook UniqueID 501
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook PrimaryGroupID 20
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -create /Local/Default/Users/MacBook NFSHomeDirectory /Users/MacBook
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -passwd /Local/Default/Users/MacBook 1234
        dscl -f "$DATA_PATH/private/var/db/dslocal/nodes/Default" localhost -append /Local/Default/Groups/admin GroupMembership MacBook

        # 2. 屏蔽域名
        for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com albert.apple.com; do
            echo "0.0.0.0 $d" >> "$SYS_PATH/etc/hosts"
        done

        # 3. 写入状态
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"

        echo -e "${GRN}执行完毕！请重启。${NC}"
        sleep 3
        ;;
    2)
        csrutil disable && echo "SIP 已关闭" || echo "失败"
        sleep 2
        ;;
    3)
        csrutil enable && echo "SIP 已开启" || echo "失败"
        sleep 2
        ;;
    4)
        profiles show -type enrollment
        read -p "回车继续..."
        ;;
    5)
        reboot
        ;;
    6)
        exit 0
        ;;
    *)
        echo "无效选项"
        sleep 1
        ;;
    esac
done
