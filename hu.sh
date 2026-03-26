#!/bin/sh
# ============================================
# 华强北小胡 - MDM 终极全兼容版 (无乱码)
# ============================================

# 1. 云端授权验证
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo "------------------------------------------------"
echo "正在验证序列号: $SN ..."

# 核心：直接读取 Pages 上的 sn.txt 进行对比
CHECK=$(curl -fsSL https://humdm.github.io/mdm-tools/sn.txt | grep "$SN")

if [ -z "$CHECK" ]; then
    echo "❌ 授权失败！当前序列号未入库"
    echo "请联系胡师傅开通：18682333383"
    echo "------------------------------------------------"
    exit 1
fi

echo "✅ 授权成功！正在进入专家模式..."

# 2. 磁盘准备
echo "正在解锁并挂载磁盘..."
diskutil mount "Macintosh HD" >/dev/null 2>&1
mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
if [ -d "/Volumes/Macintosh HD - Data" ]; then
    diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
fi

# 3. 核心绕过逻辑 (默认密码 1234)
echo "正在创建用户并注入配置..."
D="/Volumes/Data/private/var/db/dslocal/nodes/Default"
mkdir -p "/Volumes/Data/Users/mac"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" UserShell "/bin/zsh"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" RealName "MacBook"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" UniqueID "501"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" PrimaryGroupID "20"
dscl -f "$D" localhost -create "/Local/Default/Users/mac" NFSHomeDirectory "/Users/mac"
dscl -f "$D" localhost -passwd "/Local/Default/Users/mac" "1234"
dscl -f "$D" localhost -append "/Local/Default/Groups/admin" GroupMembership "mac"

# 4. 汇总屏蔽 Apple 服务器 (防 VPN 开启后反弹)
echo "正在拉黑监管服务器..."
H="/Volumes/Macintosh\ HD/etc/hosts"
for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
    echo "127.0.0.1 $d" >> "$H"
done

# 5. 注入跳过激活标志
touch /Volumes/Data/private/var/db/.AppleSetupDone
rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig*
touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound

echo "------------------------------------------------"
echo "🎉 所有操作已完成！"
echo "请直接在终端输入 reboot 重启电脑。"
echo "------------------------------------------------"
