#!/bin/bash

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
PUR='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
SN_FILE="$SCRIPT_DIR/sn.txt"

# --- 严格维持 4.0 抬头 ---
clear
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}       欢迎使用Macbook 绕过工具-专业版              ${NC}"
echo -e "${RED}           售后微信：huhu-019                      ${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# --- 1. 验证 Wi-Fi 连接 (第一步) ---
echo -e "${BLU}正在检测网络连接状态...${NC}"
if ! ping -c 1 -W 2 apple.com > /dev/null 2>&1; then
    echo -e "${RED}错误：Wi-Fi 未连接！${NC}"
    echo -e "${YEL}请先连接 Wi-Fi 后再运行脚本。${NC}"
    exit 1
fi

# --- 2. 验证序列号授权 (第二步) ---
echo -e "${BLU}正在验证序列号授权...${NC}"
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')

if [ ! -f "$SN_FILE" ]; then
    echo -e "${RED}未找到授权文件 sn.txt，请联系华强北小胡：huhu-019${NC}"
    exit 1
fi

if ! grep -qi "$CURRENT_SN" "$SN_FILE"; then
    echo -e "${RED}***************************************************${NC}"
    echo -e "${RED}* 错误：序列号 [ $CURRENT_SN ] 未备案！        *${NC}"
    echo -e "${RED}* 请联系华强北小胡处理：huhu-019               *${NC}"
    echo -e "${RED}***************************************************${NC}"
    exit 1
fi

# --- 3. 自动定位硬盘分区 (核心智能逻辑) ---
echo -e "${BLU}正在自动定位硬盘分区...${NC}"
SYS_PATH=$(find /Volumes -maxdepth 2 -name "hosts" -path "*/etc/hosts" | sed 's|/etc/hosts||' | head -n 1)
DATA_PATH=$(find /Volumes -maxdepth 4 -name "dslocal" -path "*/private/var/db/dslocal" | sed 's|/private/var/db/dslocal||' | head -n 1)

if [ -z "$SYS_PATH" ] || [ -z "$DATA_PATH" ]; then
    echo -e "${RED}错误：无法自动识别硬盘！请确保已在磁盘工具中挂载并解锁分区。${NC}"
    exit 1
fi

echo -e "${GRN}验证通过！正在进入功能菜单...${NC}"
echo ""

# --- 4. 功能菜单 (已整合 SIP 管理) ---
PS3='Please enter your choice: '
options=("自动绕过 (Recovery 模式)" "开启/关闭 SIP 服务" "屏蔽通知 (桌面模式)" "查看监管状态" "重启电脑" "退出")

select opt in "${options[@]}"; do
    case $opt in
    "自动绕过 (Recovery 模式)")
        echo -e "${GRN}开始执行自动绕过逻辑...${NC}"
        realName="MacBook"
        username="MacBook"
        passw="1234"
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "$realName"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

        for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
            echo "0.0.0.0 $domain" >> "$SYS_PATH/etc/hosts"
        done

        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
        
        launchctl disable system/com.apple.ManagedClient.enroll
        launchctl disable system/com.apple.CloudConfigurationManager

        echo -e "${CYAN}------ 自动绕过执行成功！ ------${NC}"
        echo -e "${CYAN}------ 请退出终端手动重启电脑！ ------${NC}"
        break
        ;;

    "开启/关闭 SIP 服务")
        echo -e "${YEL}--- SIP (系统完整性保护) 管理 ---${NC}"
        echo -e "1) 关闭 SIP (处理 MDM 推荐)"
        echo -e "2) 开启 SIP (恢复官方状态)"
        echo -e "3) 返回主菜单"
        read -p "请选择 (1-3): " sip_opt
        case $sip_opt in
            1)
                echo -e "${RED}正在关闭 SIP...${NC}"
                csrutil disable
                echo -e "${GRN}SIP 已关闭，请务必手动重启电脑以使更改生效！${NC}"
                ;;
            2)
                echo -e "${BLU}正在开启 SIP...${NC}"
                csrutil enable
                echo -e "${GRN}SIP 已开启，请重启电脑。${NC}"
                ;;
            *)
                echo "已返回。"
                ;;
        esac
        ;;

    "屏蔽通知 (桌面模式)")
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord
        sudo rm -rf /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordFound
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
        sudo touch /var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
        sudo launchctl disable system/com.apple.ManagedClient.enroll
        sudo launchctl disable system/com.apple.CloudConfigurationManager
        echo -e "${GRN}屏蔽任务执行完毕！${NC}"
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
