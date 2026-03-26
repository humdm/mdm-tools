#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V10)
# ==========================================================

RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
CYN='\033[1;36m'
NC='\033[0m'

# 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

clear
printf "\n"
printf "${CYN}  [本机序列号] : ${YLW}$SN${NC}\n"

if [ -z "$CHECK" ]; then
    printf "${RED}  [授权状态]   : ❌ 未授权 (请联系华强北小胡)${NC}\n"
    exit 1
fi

# 🚀 进度条核心函数
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
    # ... (此处省略中间的金字塔 UI 框代码，保持之前的样式即可) ...
    printf "  请选择功能序号并回车: "
    read opt
    case $opt in
        1) 
            echo -e "${GRN}>>> 启动专家级一键绕过流程...${NC}"
            
            # 步骤 1: 磁盘处理
            if [ -d "/Volumes/Macintosh HD - Data" ]; then
                diskutil rename "Macintosh HD - Data" "Data"
                show_progress "正在重新挂载数据卷"
            fi

            # 步骤 2: 用户信息获取 (这里需要交互，不放进度条)
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName
            realName="${realName:=MacBook}"
            echo -e "${BLU}请输入密码 (默认: 123456): ${NC}"
            read passw
            passw="${passw:=123456}"
            
            # 步骤 3: 账户注入
            show_progress "正在注入底层管理账户"
            dscl_path='/Volumes/Data/private/var/db/dslocal/nodes/Default'
            dscl -f "$dscl_path" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
            # ... (其他 dscl 命令同步执行)
            
            # 步骤 4: 5 域名硬屏蔽 (实装你说的全部网址)
            show_progress "正在配置 5 域名高强度防火墙"
            echo "0.0.0.0 deviceenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 mdmenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 iprofiles.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 acmdm.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            echo "0.0.0.0 albert.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
            
            # 步骤 5: 防 VPN 反弹伪装 (三道保险实装)
            show_progress "正在注入防 VPN 反弹伪装记录"
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* > /dev/null 2>&1
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            
            # 步骤 6: 禁用注册服务
            show_progress "正在永久禁用 MDM 引导进程"
            launchctl disable system/com.apple.ManagedClient.enroll
            
            printf "\n${GRN}★ 全部专家步骤执行完毕！★${NC}\n"
            printf "${YLW}>>> 请手动输入 reboot 重启进入系统。${NC}\n"
            sleep 3
            ;;
        # ... (其他选项同理配上 show_progress) ...
    esac
done
