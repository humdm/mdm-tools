#!/bin/sh
# ============================================
# 华强北小胡 - MDM 终极全兼容版
# ============================================

# 1. 云端授权验证
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo "正在验证序列号: $SN ..."

# 核心：增加 -L 追踪重定向，确保读取到最新的 sn.txt
CHECK=$(curl -fsSL https://humdm.github.io/mdm-tools/sn.txt | grep "$SN")

if [ -z "$CHECK" ]; then
    echo "------------------------------------------------"
    echo "❌ 授权失败！当前 SN: $SN 未入库"
    echo "请联系胡师傅开通：18682333383"
    echo "------------------------------------------------"
    exit 1
fi

echo "✅ 授权成功！正在进入专家模式..."

# 2. 磁盘准备
diskutil mount "Macintosh HD" >/dev/null 2>&1
mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
if [ -d "/Volumes/Macintosh HD - Data" ]; then
    diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
fi

# 3. 自动化绕过逻辑 (默认密码 1234)
D="/Volumes/Data/private/var/db/dslocal/nodes/Default"
mkdir -p "/Volumes/Data/Users/mac"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" UserShell "/bin/zsh"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" RealName "MacBook"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" UniqueID "501"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" PrimaryGroupID "20"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" NFSHomeDirectory "/Users/mac"
dscl -f "$D" localhost -passwd "/Local/Default/Users/mac" "1234"
dscl -f "$D" localhost -append "/Local/Default/Groups/admin" GroupMembership "mac"

# 屏蔽域名
H="/Volumes/Macintosh\ HD/etc/hosts"
for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
    echo "127.0.0.1 $d" >> $H
done

# 注入标志
touch /Volumes/Data/private/var/db/.AppleSetupDone
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig*
touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

echo "🎉 处理完成！请直接输入 reboot 重启电脑。"
