#!/bin/sh
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM
# ==========================================================

# 定义标准颜色 (兼容恢复模式)
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
NC='\033[0m' # 重置颜色

# 1. 获取序列号
SN=$(ioreg -l | grep IOPlatformSerialNumber | awk -F'"' '{print $4}' | xargs)

echo "----------------------------------------------------------"
echo -e "  [正在连接云端] ............................ ${GRN}OK${NC}"
echo -e "  [检查当前设备] ............................ ${YLW}$SN${NC}"

# 2. 授权验证 (加入随机数绕过缓存)
CHECK=$(curl -fsSL "https://humdm.github.io/mdm-tools/sn.txt?$(date +%s)" | tr -d '\r' | grep -w "$SN")

if [ -z "$CHECK" ]; then
    echo -e "  [授权状态] ................................ ${RED}❌ 未授权${NC}"
    echo "----------------------------------------------------------"
    echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "  该设备 SN: $SN 未在后台登记！"
    echo "  咸鱼店铺：福田吴彦祖 / 胡师傅爱卖手机"
    echo "  官方微信：huhu-019 | 电话：186 8233 3383"
    echo -e "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
    exit 1
fi

echo -e "  [授权状态] ................................ ${GRN}✅ 已通过${NC}"
echo "----------------------------------------------------------"

# --- 磁盘智能识别 ---
auto_mount() {
    echo -e "${BLU}>>> 正在检索系统盘...${NC}"
    # 优先找包含 Macintosh 或 Data 的卷
    DISK_NAME=$(ls /Volumes | grep -E "Macintosh HD|Data" | head -n 1)
    
    if [ -z "$DISK_NAME" ]; then
        diskutil mountDisk disk0 >/dev/null 2>&1
        DISK_NAME=$(ls /Volumes | grep -v "Image Volume" | head -n 1)
    fi
    
    mount -uw "/Volumes/$DISK_NAME" >/dev/null 2>&1
    TARGET="/Volumes/$DISK_NAME"
    
    if [ ! -d "$TARGET/etc" ]; then
        echo -e "${RED}❌ 找不到系统盘，请确认是否已抹机或加密。${NC}"
        return 1
    fi
    echo -e "${GRN}✅ 目标路径: $TARGET${NC}"
    return 0
}

# 3. 专家选单 (彩色加固版)
while true; do
    echo ""
    echo -e "${GRN}  +----------------------------------------------------+${NC}"
    echo -e "${GRN}  |         华 强 北 小 胡 - MDM 自动绕过系统          |${NC}"
    echo -e "${GRN}  +----------------------------------------------------+${NC}"
    echo -e "    ${YLW}➤ 1)${NC} 一键全自动绕过MDM ${GRN}(推荐)${NC}"
    echo -e "    ${YLW}➤ 2)${NC} 屏蔽 MDM 监管域名"
    echo -e "    ${YLW}➤ 3)${NC} 禁用 MDM 注册通知"
    echo -e "    ${YLW}➤ 4) 检测 MDM 状态${NC}"
    echo -e "    ${YLW}➤ 5)${NC} 立即重启 MacBook"
    echo -e "    ${YLW}➤ q)${NC} 退出系统"
    echo -e "${GRN}  +----------------------------------------------------+${NC}"
    echo -n "  请输入指令数字并回车: "
    
    # 强制读取硬件终端输入，防止死循环
    exec < /dev/tty
    read opt
    if [ -z "$opt" ]; then continue; fi

    case $opt in
        1)
            if auto_mount; then
                echo -e "${BLU}>>> 正在注入配置...${NC}"
                # 域名屏蔽
                for d in deviceenrollment.apple.com mdmenrollment.apple.com iprofiles.apple.com acmdm.apple.com albert.apple.com; do
                    echo "127.0.0.1 $d" >> "$TARGET/etc/hosts"
                done
                # 屏蔽配置
                mkdir -p "$TARGET/private/var/db/ConfigurationProfiles/Settings" >/dev/null 2>&1
                touch "$TARGET/private/var/db/.AppleSetupDone" >/dev/null 2>&1
                touch "$TARGET/private/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled" >/dev/null 2>&1
                touch "$TARGET/private/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound" >/dev/null 2>&1
                rm -rf "$TARGET/var/db/ConfigurationProfiles/Settings/.cloudConfig"* >/dev/null 2>&1
                echo -e "${GRN}✅ 一键绕过成功！请选 [5] 重启进入系统。${NC}"
            fi ;;
        2) if auto_mount; then echo "127.0.0.1 deviceenrollment.apple.com" >> "$TARGET/etc/hosts"; echo "已屏蔽"; fi ;;
        3) if auto_mount; then touch "$TARGET/private/var/db/.AppleSetupDone"; echo "已禁用"; fi ;;
        4) profiles show -type enrollment ;;
        5) echo "正在重启..."; reboot ;;
        q) exit 0 ;;
        *) echo -e "${RED}无效输入，请输入数字 1-5。${NC}" ;;
    esac
done
