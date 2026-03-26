#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V5)
# ==========================================================

C_RED='\033[1;31m'
C_GRN='\033[1;32m'
C_YLW='\033[1;33m'
C_BLU='\033[1;34m'
C_NC='\033[0m'

say() { printf "${1}${2}${C_NC}\n"; }

SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

# 授权检测
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")
if [ -z "$CHECK" ]; then
    say "${C_RED}" "❌ 未授权！请联系胡师傅：18682333383"
    exit 1
fi

# 核心：全盘扫描 hosts 文件
bypass_mdm() {
    say "${C_BLU}" ">>> 正在深度检索磁盘文件系统..."
    
    # 强制挂载所有磁盘
    diskutil mountDisk disk0 >/dev/null 2>&1
    
    # 遍历所有挂载的磁盘（排除恢复镜像）
    for VOL in /Volumes/*; do
        if [ "$VOL" = "/Volumes/Image Volume" ] || [ "$VOL" = "/Volumes/VM" ]; then continue; fi
        
        say "${C_YLW}" "正在检查卷宗: $VOL"
        
        # 寻找 hosts 文件的真实位置 (兼容 Catalina/Big Sur/Monterey 及以上)
        TARGET_HOSTS=""
        [ -f "$VOL/etc/hosts" ] && TARGET_HOSTS="$VOL/etc/hosts"
        [ -f "$VOL/private/etc/hosts" ] && TARGET_HOSTS="$VOL/private/etc/hosts"
        
        if [ -n "$TARGET_HOSTS" ]; then
            mount -uw "$VOL" >/dev/null 2>&1
            say "${C_GRN}" "✅ 发现系统路径: $TARGET_HOSTS"
            
            # 写入屏蔽域名
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                echo "127.0.0.1 $d" >> "$TARGET_HOSTS"
            done
            
            # 屏蔽激活通知
            mkdir -p "$VOL/private/var/db/ConfigurationProfiles/Settings" 2>/dev/null
            touch "$VOL/private/var/db/.AppleSetupDone" 2>/dev/null
            touch "$VOL/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" 2>/dev/null
            rm -rf "$VOL/var/db/ConfigurationProfiles/Settings/.cloudConfig"* 2>/dev/null
            
            say "${C_GRN}" "🚀 已成功注入屏蔽补丁！"
            SUCCESS=1
        fi
    done

    if [ "$SUCCESS" != "1" ]; then
        say "${C_RED}" "❌ 错误：未找到有效的系统文件。请先在磁盘工具里解锁 'Macintosh HD'！"
    fi
}

# 界面展示
while true; do
    printf "\n"
    say "${C_GRN}" "  ╔══════════════════════════════════════════════════════════════╗"
    say "${C_GRN}" "  ║              ★ 华强北小胡 - MDM 终极全兼容版 ★              ║"
    say "${C_GRN}" "  ╠══════════════════════════════════════════════════════════════╣"
    say "${C_GRN}" "  ║  官方认证：国内最早配置锁先锋 | 您身边的 Mac 专家             ║"
    say "${C_GRN}" "  ║         📱 微信：huhu-019      ☎ 电话：18682333383          ║"
    say "${C_GRN}" "  ║          🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机             ║"
    say "${C_GRN}" "  ╚══════════════════════════════════════════════════════════════╝"
    printf "\n"
    say "${C_YLW}" "    ▶ 1)${C_BLU} 一键全自动绕过 mdm"
    say "${C_YLW}" "    ▶ 2)${C_BLU} 立即重启 MacBook"
    say "${C_RED}" "    ✘ q)${C_YLW} 退出工具箱"
    printf "  请选择功能序号并回车: "
    
    exec < /dev/tty
    read opt
    case $opt in
        1) bypass_mdm ;;
        2) reboot ;;
        q) exit 0 ;;
    esac
done
