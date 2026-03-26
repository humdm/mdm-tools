#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V3)
# ==========================================================

# 💎 开启高亮（Bold）颜色模式
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m'

# 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

# 授权验证逻辑
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    echo -e "${RED}  [授权状态] ................................ ❌ 未授权${NC}"
    echo -e "${RED}  请联系胡师傅开通：186 8233 3383${NC}"
    exit 1
fi

# 专家选单 (布局：微信+电话同排 | 咸鱼单独一排)
while true; do
    echo ""
    echo -e "${GRN}  ╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GRN}  ║                ★ 华强北小胡 - MDM 终极全兼容版 ★                  ║${NC}"
    echo -e "${GRN}  ╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${GRN}  ║          官方认证：国内最早配置锁先锋 | 您身边的 Mac 专家          ║${NC}"
    echo -e "${GRN}  ║             📱 微信：huhu-019      ☎ 电话：18682333383             ║${NC}"
    echo -e "${GRN}  ║              🌟 咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机              ║${NC}"
    echo -e "${GRN}  ╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "    ${YLW}▶ 1)${NC} ${BLU}一键全自动绕过 mdm${NC}"
    echo -e "    ${YLW}▶ 2)${NC} ${BLU}屏蔽 mdm 域名${NC}"
    echo -e "    ${YLW}▶ 3)${NC} ${BLU}禁用 mdm 通知${NC}"
    echo -e "    ${YLW}▶ 4)${NC} ${BLU}检查 mdm 注册状态${NC}"
    echo ""
    echo -e "    ${RED}✘ q)${NC} ${YLW}退出工具箱${NC}"
    
    echo -e "${GRN}  ──────────────────────────────────────────────────────────────────────${NC}"
    echo -n "  请选择功能序号并回车: "
    
    exec < /dev/tty
    read opt
    if [ -z "$opt" ]; then continue; fi

    case $opt in
        1)
            DISK_NAME=$(ls /Volumes | grep -E "Macintosh HD|Data" | head -n 1)
            if [ -z "$DISK_NAME" ]; then diskutil mountDisk disk0 >/dev/null 2>&1; DISK_NAME=$(ls /Volumes | grep -v "Image Volume" | head -n 1); fi
            mount -uw "/Volumes/$DISK_NAME" >/dev/null 2>&1
            TARGET="/Volumes/$DISK_NAME"

            echo -e "${BLU}[专家处理] 正在智能识别系统盘...${NC}"
            for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do echo "127.0.0.1 $d" >> "$TARGET/etc/hosts"; done
            mkdir -p "$TARGET/private/var/db/ConfigurationProfiles/Settings" >/dev/null 2>&1
            touch "$TARGET/private/var/db/.AppleSetupDone" "$TARGET/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" "$TARGET/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" >/dev/null 2>&1
            rm -rf "$TARGET/var/db/ConfigurationProfiles/Settings/.cloudConfig"* >/dev/null 2>&1
            
            echo -e "${GRN}>>> [OK] MDM 锁定已成功解除，请立即重启！${NC}"
            ;;
        2) 
            # 屏蔽域名逻辑
            ;;
        4) profiles show -type enrollment ;;
        q) exit 0 ;;
        *) echo -e "${RED}无效输入，请输入数字 1-4。${NC}" ;;
    esac
done
