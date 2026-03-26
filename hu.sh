#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

# 颜色定义 (兼容模式)
RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m' 

# 1. 获取设备序列号并清理前后空格
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

echo "----------------------------------------------------------"
echo "  [正在连接云端] ............................ OK"
echo "  [检查当前设备] ............................ $SN"

# 2. 授权验证 (加入随机数后缀绕过缓存，并剔除回车符)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    echo -e "${RED}  [授权状态] ................................ ❌ 未授权${NC}"
    echo "----------------------------------------------------------"
    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
    echo -e "${RED}  该设备 SN: $SN 未在后台登记！${NC}"
    echo -e "${RED}  请联系胡师傅开通：186 8233 3383 | 微信: huhu-019${NC}"
    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
    exit 1
fi

echo -e "  [授权状态] ................................ ${GRN}✅ 已通过${NC}"
echo "----------------------------------------------------------"

# 进度条函数
bar(){
    echo -n "  $1: ["
    for i in 1 2 3 4 5 6 7 8 9 10; do
        sleep 0.05
        echo -n "##"
    done
    echo "] 100%"
}

# 磁盘挂载函数
prep_disk() {
    diskutil mount "Macintosh HD" >/dev/null 2>&1
    mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
    fi
}

# 3. 专家选单
while true; do
    echo ""
    echo "  +----------------------------------------------------+"
    echo "  |         华 强 北 小 胡 - MDM 自动绕过系统          |"
    echo "  +----------------------------------------------------+"
    echo "    ➤ 1) 一键全自动绕过MDM (推荐)"
    echo "    ➤ 2) 屏蔽 MDM 监管域名 (手工加固)"
    echo "    ➤ 3) 禁用 MDM 注册通知 (深度清理)"
    echo "    ➤ 4) 检测 MDM 监管状态 (验证效果)"
    echo "    ➤ 5) 立即重启 MacBook"
    echo "    ➤ q) 退出"
    echo "  +----------------------------------------------------+"
    echo -n "  请输入指令数字并回车: "
    
    # 读取输入，增加判断防止死循环
    read opt
    if [ -z "$opt" ]; then continue; fi

    case $opt in
        1)
            prep_disk
            echo "  >>> 正在启动全自动绕过流程..."
            # 创建用户
            D="/Volumes/Data/private/var/db/dslocal/nodes/Default"
            mkdir -p "/Volumes/Data/Users/mac"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" UserShell "/bin/zsh" >/dev/null 2>&1
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" RealName "MacBook" >/dev/null 2>&1
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" UniqueID "501" >/dev/null 2>&1
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" PrimaryGroupID "20" >/dev/null 2>&1
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" NFSHomeDirectory "/Users/mac" >/dev/null 2>&1
            dscl -f "$D" localhost -passwd "/Local/Default/Users/mac" "1234" >/dev/null 2>&1
            dscl -f "$D" localhost -append "/Local/Default/Groups/admin" GroupMembership "mac" >/dev/null 2>&1
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            bar "步骤 [1/3] 账户配置"

            # 屏蔽域名
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            bar "步骤 [2/3] 域名封锁"

            # 清理残留
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* >/dev/null 2>&1
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            bar "步骤 [3/3] 深度清理"
            
            echo -e "  ${GRN}✅ 一键全自动绕过成功！请选择 [5] 重启电脑。${NC}"
            ;;
        2)
            prep_disk
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            bar "域名封锁"
            ;;
        3)
            prep_disk
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* >/dev/null 2>&1
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            bar "清理残留"
            ;;
        4)
            echo "  [当前状态]:"
            profiles show -type enrollment
            ;;
        5)
            echo "  正在重启系统..."
            reboot
            ;;
        q)
            echo "  退出程序。"
            exit 0
            ;;
        *)
            echo -e "  ${RED}❌ 指令错误，请输入数字 1-5 或 q${NC}"
            ;;
    esac
done
