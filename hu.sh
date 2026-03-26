#!/bin/zsh
# ============================================
# 华强北小胡 - 恢复模式 MDM 终极自动化工具
# 微信: huhu-009 | 备用: 18682333383
# ============================================

# 颜色定义
C='\033[0;36m'; G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; W='\033[1;37m'; B='\033[1;44m'; N='\033[0m'

# 1. 云端授权验证 (已更新为你的 Pages 专用地址)
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}')
echo -e "${Y}正在调取云端授权库...${N}"
CHECK=$(curl -fsSL https://humdm.github.io/mdm-tools/sn.txt | grep -w "$SN")

if [ -z "$CHECK" ]; then
    clear
    echo -e "${R}╔══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${R}║                ❌  该设备未获得胡师傅授权  ❌                ║${N}"
    echo -e "${R}╚══════════════════════════════════════════════════════════════╝${N}"
    echo -e "\n${W}当前 SN: ${Y}$SN${N}"
    echo -e "${W}请联系胡师傅获取授权：${G}18682333383${N}"
    exit 1
fi

# 2. 恢复模式磁盘准备
prep_disk() {
    # 挂载主磁盘并解锁写权限
    diskutil mount "Macintosh HD" >/dev/null 2>&1
    mount -uw /Volumes/Macintosh\ HD >/dev/null 2>&1
    # 自动重命名 Data 卷，防止 dscl 路径报错
    if [ -d "/Volumes/Macintosh HD - Data" ]; then
        diskutil rename "Macintosh HD - Data" "Data" >/dev/null 2>&1
    fi
}

bar(){ echo -ne "${Y}[专家处理]${N} $1: ["; for i in {1..20}; do sleep 0.02; echo -ne "${G}#${N}"; done; echo -e "] ${G}100%${N}"; }

# 3. 主菜单
while true; do
    clear
    echo -e "${C}╔══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${B}${W}      华  强  北  小  胡  -  深  度  M  D  M  专  家  版      ${N}${C}║${N}"
    echo -e "${C}╠══════════════════════════════════════════════════════════════╣${N}"
    echo -e "  ${G}1)${N} ${W}自动绕过 + 创建用户 (默认密码 1234)${N}"
    echo -e "  ${G}2)${N} ${W}查看监管状态 (验证效果)${N}"
    echo -e "  ${R}q)${N} ${W}退出并重启电脑${N}"
    echo -e "${C}──────────────────────────────────────────────────────────────${N}"
    echo -ne "${Y}授权 SN [$SN] 已通过，请选择功能: ${N}"
    read -r opt
    case $opt in
        1)
            prep_disk
            echo -e "\n${G}>>> 正在配置新账户...${N}"
            echo -ne "${W}显示全名 (直接回车为 MacBook): ${N}"; read rName; rName="${rName:=MacBook}"
            echo -ne "${W}登录账号 (直接回车为 mac): ${N}"; read uName; uName="${uName:=mac}"
            echo -ne "${W}登录密码 (直接回车为 1234): ${N}"; read psw; psw="${psw:=1234}"
            
            # --- 核心 A: 底层创建用户 ---
            D="/Volumes/Data/private/var/db/dslocal/nodes/Default"
            mkdir -p "/Volumes/Data/Users/$uName"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName" UserShell "/bin/zsh"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName" RealName "$rName"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName" UniqueID "501"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName" PrimaryGroupID "20"
            dscl -f "$D" localhost -create "/Local/Default/Users/$uName" NFSHomeDirectory "/Users/$uName"
            dscl -f "$D" localhost -passwd "/Local/Default/Users/$uName" "$psw"
            dscl -f "$D" localhost -append "/Local/Default/Groups/admin" GroupMembership "$uName"
            
            # --- 核心 B: 汇总屏蔽 Apple 监管服务器 (防 VPN 开启后反弹) ---
            H="/Volumes/Macintosh\ HD/etc/hosts"
            for domain in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $domain" >> $H
            done
            
            # --- 核心 C: 注入跳过激活标志 ---
            touch /Volumes/Data/private/var/db/.AppleSetupDone
            rm -rf /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfig*
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
            touch /Volumes/Data/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound
            
            bar "全自动绕过完成"
            echo -e "${G}>>> 已成功为 [$uName] 开启专家级防护。${N}"
            echo -e "${Y}>>> 处理完毕，请在终端输入 reboot 重启！${N}";;
        2)
            profiles show -type enrollment;;
        q) reboot;;
    esac
    echo -ne "\n${C}按任意键返回菜单...${N}"; read -k 1
done
