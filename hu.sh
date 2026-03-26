#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

# 1. 获取序列号并清理
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

echo "----------------------------------------------------------"
echo "  [正在连接云端] ............................ OK"
echo "  [检查当前设备] ............................ $SN"

# 2. 授权验证 (强制刷新缓存)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    echo "  [授权状态] ................................ ❌ 未授权"
    echo "----------------------------------------------------------"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  该设备 SN: $SN 未在后台登记！"
    echo "  咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机"
    echo "  官方微信：huhu-019 | 电话：186 8233 3383"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
fi

echo "  [授权状态] ................................ ✅ 已通过"
echo "----------------------------------------------------------"

# 磁盘挂载函数
prep_disk() {
    diskutil mount "Macintosh HD" >/dev/null 2>&1
    mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
    fi
}

# 3. 专家选单 (修复循环逻辑)
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
    
    # 关键修复：清除可能的缓冲区干扰
    read -r opt
    
    # 彻底解决空值导致无限刷屏的问题
    if [ -z "$opt" ]; then 
        echo "  [提示] 请输入数字后按回车"
        continue 
    fi

    case $opt in
        1)
            prep_disk
            echo "  >>> 正在启动全自动流程..."
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
            # 屏蔽域名
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            # 清理残留
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* >/dev/null 2>&1
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            echo ""
            echo "  ✅ 一键绕过成功！请选 [5] 重启系统。"
            ;;
        2)
            prep_disk
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$H"
            done
            echo "  域名屏蔽完成。" ;;
        3)
            prep_disk
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig* >/dev/null 2>&1
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            echo "  通知残留清理完成。" ;;
        4)
            profiles show -type enrollment ;;
        5)
            echo "  正在重启..."
            reboot ;;
        q)
            exit 0 ;;
        *)
            echo "  ❌ 指令有误，请输入数字 1-5 或 q。"
            ;;
    esac
done
