#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 华强北小胡专用版
# 专门适配磁盘名: Macintosh HD - 数据
# ============================================

# 颜色
GRN='\033[1;32m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

clear
echo -e "${CYAN}华强北小胡专用版 - 正在处理：Macintosh HD - 数据${NC}"

# 1. 挂载磁盘并解除只读
echo -e "${YEL}🔄 正在解除磁盘只读限制...${NC}"
mount -uw "/Volumes/Macintosh HD" 2>/dev/null
mount -uw "/Volumes/Macintosh HD - 数据" 2>/dev/null

# 2. 屏蔽域名
echo -e "${YEL}🛡️  正在屏蔽MDM域名...${NC}"
cat >> "/Volumes/Macintosh HD/etc/hosts" << EOF
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 deviceservices-external.apple.com
EOF

# 3. 写入绕过标记 (关键：使用你的准确路径)
echo -e "${YEL}📝 写入绕过标记...${NC}"
rm -f "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord" 2>/dev/null
touch "/Volumes/Macintosh HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
touch "/Volumes/Macintosh HD - 数据/private/var/db/.AppleSetupDone"

# 4. 创建管理员用户 (解决 Not a known DirStatus)
echo -e "${CYAN}👤 正在创建用户 Apple (密码1234)...${NC}"
DS_PATH="/Volumes/Macintosh HD - 数据/private/var/db/dslocal/nodes/Default"

dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple
dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple UserShell /bin/zsh
dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple RealName "Apple"
dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple UniqueID "501"
dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple PrimaryGroupID "20"
dscl -f "$DS_PATH" localhost -create /Local/Default/Users/Apple NFSHomeDirectory /Users/Apple
dscl -f "$DS_PATH" localhost -passwd /Local/Default/Users/Apple "1234"
dscl -f "$DS_PATH" localhost -append /Local/Default/Groups/admin GroupMembership Apple

mkdir -p "/Volumes/Macintosh HD - 数据/Users/Apple"

echo -e "\n${GRN}✅ 全部搞定！胡师傅，这下路径绝对准了。${NC}"
echo -e "${YEL}请直接重启电脑，登录 Apple 账户即可。${NC}"
