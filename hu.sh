#!/bin/bash

# ==================================================
# MacBook 绕过工具 - 4.0 专业版
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

# --- 远程配置 (已更新为你的真实链接) ---
GITHUB_URL="https://raw.githubusercontent.com/humdm/mdm-tools/refs/heads/main/sn.txt"

# 修复恢复模式清屏报错
alias clear='printf "\033c"'

# --- 1. 严格抬头展示 ---
clear
echo -e "${CYAN}***************************************************${NC}"
echo -e "${YEL}       欢迎使用Macbook 绕过工具-4.0专业版            ${NC}"
echo -e "${RED}           售后微信：huhu-019                      ${NC}"
echo -e "${CYAN}***************************************************${NC}"
echo ""

# --- 2. 增强型网络验证 ---
echo -e "${YEL}正在检测网络连接...${NC}"
# 使用 curl 探测 apple.com，比 ping 在恢复模式下更准
if ! curl -I -s --connect-timeout 5 https://www.apple.com > /dev/null; then
    echo -e "${RED}错误：Wi-Fi 未连接或网络不可用！${NC}"
    echo -e "${YEL}请点击右上角图标连接 Wi-Fi 后再运行。${NC}"
    exit 1
fi

# --- 3. 序列号 (SN) 实时校验 ---
CURRENT_SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo -e "${YEL}本机序列号 (SN): ${CYAN}$CURRENT_SN${NC}"
echo -e "${YEL}正在调取远程授权信息...${NC}"

# 优化后的 curl 参数：-s(静默) -k(忽略证书) -L(跟随重定向) --retry(失败重试)
AUTH_LIST=$(curl -skL --retry 3 --connect-timeout 10 "$GITHUB_URL")

# 检查下载内容是否为空
if [ -z "$AUTH_LIST" ]; then
    echo -e "${RED}❌ 访问授权失败！请确认当前环境可访问 GitHub。${NC}"
    echo -e "${YEL}提示：部分地区 Recovery 模式下 DNS 解析 GitHub 较慢，请重试。${NC}"
    exit 1
fi

if echo "$AUTH_LIST" | grep -qi "$CURRENT_SN"; then
    echo -e "${GRN}✅ 授权验证成功！欢迎进入专家模式。${NC}"
    sleep 1
else
    echo -e "${RED}***************************************************${NC}"
    echo -e "${RED}* 错误：当前序列号未获 4.0 版授权！               *${NC}"
    echo -e "${RED}* 请联系华强北小胡开通：huhu-019                  *${NC}"
    echo -e "${RED}***************************************************${NC}"
    exit 1
fi

# --- 4. 自动定位硬盘分区 ---
# 这一步是关键，确保后续修改的是用户硬盘而不是启动盘
SYS_PATH=$(find /Volumes -maxdepth 2 -name "hosts" -path "*/etc/hosts" | sed 's|/etc/hosts||' | head -n 1)
DATA_PATH=$(find /Volumes -maxdepth 4 -name "dslocal" -path "*/private/var/db/dslocal" | sed 's|/private/var/db/dslocal||' | head -n 1)

if [ -z "$SYS_PATH" ] || [ -z "$DATA_PATH" ]; then
    echo -e "${RED}无法定位硬盘分区！请先在磁盘工具中解锁 Data 分区。${NC}"
    exit 1
fi

# --- 5. 功能菜单 ---
while true; do
    printf "\033c"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${YEL}        华强北小胡 - 4.0 自动化专家工具箱           ${NC}"
    echo -e "${CYAN}===================================================${NC}"
    echo -e "${GRN} 1. 自动绕过 (一键创建用户+屏蔽域名)${NC}"
    echo -e " 2. 开启/关闭 SIP 服务"
    echo -e " 3. 屏蔽通知 (针对已入桌面机型)"
    echo -e " 4. 查看当前监管状态"
    echo -e " 5. 立即重启电脑"
    echo -e " 6. 退出脚本"
    echo -e "${CYAN}===================================================${NC}"
    read -p "请输入指令 [1-6]: " opt

    case $opt in
    1)
        echo -e "${GRN}正在执行 4.0 核心绕过逻辑...${NC}"
        username="MacBook"
        passw="1234"
        dscl_path="$DATA_PATH/private/var/db/dslocal/nodes/Default"
        
        # 底层创建用户
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UserShell "/bin/zsh"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" RealName "MacBook"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" UniqueID "501"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" PrimaryGroupID "20"
        mkdir -p "$DATA_PATH/Users/$username"
        dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$username" NFSHomeDirectory "/Users/$username"
        dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/$username" "$passw"
        dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "$username"

        # 写入屏蔽 Host
        for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
            echo "0.0.0.0 $domain" >> "$SYS_PATH/etc/hosts"
        done

        # 伪造设置状态
        touch "$DATA_PATH/private/var/db/.AppleSetupDone"
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
        
        echo -e "${GRN}------ 绕过成功！请退出重启 ------${NC}"
        sleep 3
        ;;

    2)
        echo -e "1) 关闭 SIP | 2) 开启 SIP | 3) 返回"
        read -p "选择: " sip_opt
        [ "$sip_opt" = "1" ] && csrutil disable && echo "已禁用 SIP，重启生效。"
        [ "$sip_opt" = "2" ] && csrutil enable && echo "已启用 SIP，重启生效。"
        sleep 2
        ;;

    3)
        echo -e "${YEL}正在下发屏蔽指令...${NC}"
        # 针对当前挂载分区的屏蔽逻辑
        rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord" 2>/dev/null
        touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
        echo -e "${GRN}操作完成。${NC}"
        sleep 2
        ;;

    4)
        echo -e "${YEL}当前系统监管状态：${NC}"
        profiles show -type enrollment 2>/dev/null || echo "未发现监管信息"
        read -p "按回车继续..."
        ;;

    5)
        echo -e "${YEL}正在重启...${NC}"
        reboot
        ;;

    6)
        exit 0
        ;;

    *) echo "指令无效" ; sleep 1 ;;
    esac
done
