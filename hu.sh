#!/bin/sh
# ============================================
# 华强北小胡 - MDM 终极授权版 (醒目报错)
# ============================================

# 定义红色和绿色（兼容恢复模式终端）
RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m' # 重置颜色

SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo "------------------------------------------------"
echo "正在调取云端授权库..."

# 核心改进：在 URL 后面加个随机数 ?$(date +%s)，强制 GitHub 不使用旧缓存
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | grep "$SN")

if [ -z "$CHECK" ]; then
    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo -e "❌ 授权失败！当前序列号未入库"
    echo -e "当前设备 SN: ${SN}"
    echo -e "请联系胡师傅开通：186 8233 3383"
    echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
    exit 1
fi

echo -e "${GRN}✅ 授权成功！正在进入专家模式...${NC}"

# 进度条函数
bar(){
    echo -n "$1: ["
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
        sleep 0.02
        echo -n "#"
    done
    echo "] 100%"
}

# 磁盘准备
prep_disk() {
    diskutil mount "Macintosh HD" >/dev/null 2>&1
    mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
    fi
}

# 菜单循环
while true; do
    echo ""
    echo "================================================"
    echo "      华强北小胡 - MacBook MDM 自动化方案      "
    echo "================================================"
    echo "  ➤  1) 一键全自动绕过MDM (推荐)"
    echo "  ➤  2) 屏蔽 MDM 监管域名 (手工加固)"
    echo "  ➤  3) 禁用 MDM 注册通知 (深度清理)"
    echo "  ➤  4) 检测 MDM 监管状态 (验证效果)"
    echo "  ➤  5) 立即重启 MacBook"
    echo "  ➤  q) 退出脚本"
    echo "------------------------------------------------"
    echo -n "授权 SN [$SN] 已通过，请输入数字: "
    read opt

    case $opt in
        1)
            prep_disk
            echo ">>> 正在执行全自动绕过流程..."
            D="/Volumes/Data/private/var/db/dslocal/nodes/Default"
            mkdir -p "/Volumes/Data/Users/mac"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" UserShell "/bin/zsh"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" RealName "MacBook"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" UniqueID "501"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" PrimaryGroupID "20"
            dscl -f "$D" localhost -create "/Local/Default/Users/mac" NFSHomeDirectory "/Users/mac"
            dscl -f "$D" localhost -passwd "/Local/Default/Users/mac" "1234"
            dscl -f "$D" localhost -append "/Local/Default/Groups/admin" GroupMembership "mac"
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            bar "1. 账户配置"
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            bar "2. 域名封锁"
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig*
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            bar "3. 通知屏蔽"
            echo -e "${GRN}✅ 一键全自动绕过成功！请按 5 重启。${NC}"
            ;;
        2)
            prep_disk
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            bar "服务器屏蔽完成"
            ;;
        3)
            prep_disk
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig*
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            bar "通知禁用完成"
            ;;
        4)
            profiles show -type enrollment
            ;;
        5)
            echo "正在重启..."
            reboot
            ;;
        q)
            exit 0
            ;;
        *)
            echo "无效选择，请重新输入。"
            ;;
    esac
done
