#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GRN='\033[0;32m'
BLU='\033[0;34m'
CYAN='\033[0;36m'
YEL='\033[1;33m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
SN_FILE="$SCRIPT_DIR/sn.txt"

clear
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}* 华强北小胡 - Mac 专家工具箱 v4.6 (磁盘自适应版) *${NC}"
echo -e "${RED}* 售后微信：huhu-019                          *${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# --- 1. 验证 Wi-Fi 连接 ---
echo -e "${BLU}[1/2] 正在检测网络连接状态...${NC}"
if ! ping -c 1 -W 2 apple.com > /dev/null 2>&1; then
    echo -e "${RED}错误：网络未连接！${NC}"
    echo -e "${YEL}请在菜单栏点击 Wi-Fi 图标连接网络后再运行脚本。${NC}"
    exit 1
else
    echo -e "${GRN}网络连接正常！${NC}"
fi

# --- 2. 验证序列号授权 ---
echo -e "${BLU}[2/2] 正在验证序列号授权...${NC}"
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')

if [ ! -f "$SN_FILE" ]; then
    echo -e "${RED}错误：未找到授权文件 sn.txt！${NC}"
    exit 1
fi

if grep -qi "$CURRENT_SN" "$SN_FILE"; then
    echo -e "${GRN}序列号 [ $CURRENT_SN ] 验证通过！${NC}"
else
    echo -e "${RED}错误：序列号 [ $CURRENT_SN ] 未备案！请联系：huhu-019${NC}"
    exit 1
fi

# --- 3. 智能磁盘扫描逻辑 ---
echo -e "${BLU}正在扫描有效磁盘分区...${NC}"
# 查找包含 etc/hosts 的作为系统盘 (SYS_PATH)
SYS_PATH=$(find /Volumes -maxdepth 2 -name "hosts" -path "*/etc/hosts" | sed 's|/etc/hosts||' | head -n 1)
# 查找包含 dslocal 的作为数据盘 (DATA_PATH)
DATA_PATH=$(find /Volumes -maxdepth 4 -name "dslocal" -path "*/private/var/db/dslocal" | sed 's|/private/var/db/dslocal||' | head -n 1)

if [ -z "$SYS_PATH" ] || [ -z "$DATA_PATH" ]; then
    echo -e "${RED}错误：无法自动定位系统或数据分区！${NC}"
    echo -e "${YEL}请确保磁盘已挂载（可以在磁盘工具中手动解锁 FileVault）。${NC}"
    exit 1
fi

echo -e "${GRN}系统盘定位: $SYS_PATH${NC}"
echo -e "${GRN}数据盘定位: $DATA_PATH${NC}"
echo ""

# --- 4. 核心功能菜单 ---
PS3='请选择操作编号: '
options=("自动绕过 (Recovery 模式)" "屏蔽通知 (桌面模式)" "查看监管状态" "重启电脑" "退出")

select opt in "${options[@]}"; do
    case $opt in
    "自动绕过 (Recovery 模式)")
        echo -e "${GRN}正在执行绕过逻辑...${NC}"
        
        # 固定创建用户信息 (密码 1234)
        realName="MacBook"
        username="MacBook"
        passw="1234"
        
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        
        # 注入用户
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

        # 域名屏蔽
        for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
            echo "0.0.0.0 $domain" >> "$SYS_PATH/etc/hosts"
        done

        # 清理标记文件
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        
        # 禁用关键服务
        launchctl disable system/com.apple.ManagedClient.enroll
        launchctl disable system/com.apple.CloudConfigurationManager

        echo -e "${GRN}操作成功！请重启电脑。${NC}"
        break
        ;;

    "屏蔽通知 (桌面模式)")
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo launchctl disable system/com.apple.CloudConfigurationManager
        echo -e "${GRN}桌面屏蔽已完成！${NC}"
        break
        ;;

    "查看监管状态")
        sudo profiles show -type enrollment
        break
        ;;

    "重启电脑")
        reboot
        break
        ;;

    "退出")
        exit 0
        ;;

    *) echo "无效选项 $REPLY" ;;
    esac
done
