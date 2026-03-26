#!/bin/bash
# ==========================================================
#        HUA QIANG BEI XIAO HU - MDM EXPERT SYSTEM (V16)
# ==========================================================

# ... (前面的颜色定义、联网监测 check_network、SN验证保持不变) ...

# 🚀 3. 增强版：自动寻找系统盘路径 (解决英特尔读不到盘的问题)
find_disks() {
    # 自动探测 Macintosh HD 所在的挂载点
    SYS_PATH=$(df | grep -E "Macintosh HD$" | awk '{print $6}')
    DATA_PATH=$(df | grep -E "Macintosh HD - Data$|Data$" | awk '{print $6}')

    # 如果没找到默认名，就尝试搜寻包含根文件的卷
    if [ -z "$SYS_PATH" ]; then
        SYS_PATH="/Volumes/Macintosh HD"
    fi
    if [ -z "$DATA_PATH" ]; then
        DATA_PATH="/Volumes/Data"
    fi
}

# ... (进度条函数 show_progress 保持 50格 绿色) ...

while true; do
    # ... (金字塔 UI 代码) ...
    printf "  请选择功能序号并回车: "
    read opt < /dev/tty
    
    case $opt in
        1) 
            echo -e "\n${GRN}>>> 启动全兼容绕过流程 (Intel/Apple Silicon)...${NC}"
            find_disks # 自动定位磁盘
            
            # 兼容性挂载检查
            if [ ! -d "$SYS_PATH/etc" ]; then
                echo -e "${RED}⚠️  未检测到系统盘，尝试强制挂载...${NC}"
                diskutil mountDisk /dev/disk0 > /dev/null 2>&1
                sleep 2
            fi

            # 核心逻辑开始 (路径改用变量)
            show_progress "初始化：磁盘兼容性自适应"
            
            # 用户创建逻辑 (支持 Intel 路径)
            echo -e "${BLU}请输入用户名 (默认: MacBook): ${NC}"
            read realName < /dev/tty
            realName="${realName:=MacBook}"
            
            show_progress "第一阶段：注入底层管理账户"
            # 自动识别 Data 卷下的用户路径
            DSCL_PATH="$DATA_PATH/private/var/db/dslocal/nodes/Default"
            dscl -f "$DSCL_PATH" localhost -create "/Local/Default/Users/$realName" > /dev/null 2>&1
            # ... (其他 dscl 命令均使用变量 $DSCL_PATH)
            mkdir -p "$DATA_PATH/Users/$realName"
            
            show_progress "第二阶段：封锁 5 域名 (Intel 高级适配)"
            # 强制解除 hosts 锁定并写入
            chflags nouchg "$SYS_PATH/etc/hosts" > /dev/null 2>&1
            echo "0.0.0.0 deviceenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 mdmenrollment.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 iprofiles.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 acmdm.apple.com" >> "$SYS_PATH/etc/hosts"
            echo "0.0.0.0 albert.apple.com" >> "$SYS_PATH/etc/hosts"
            
            show_progress "第三阶段：注入防反弹伪装 (全系列通用)"
            touch "$DATA_PATH/private/var/db/.AppleSetupDone"
            rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfig*" > /dev/null 2>&1
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"
            touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigRecordNotFound"
            
            show_progress "第四阶段：硬件指纹关联优化"
            launchctl disable system/com.apple.ManagedClient.enroll > /dev/null 2>&1
            
            printf "\n${GRN}★ 绕过完毕！密码: 1234 ★${NC}\n"
            printf "${YLW}★ 提示：Intel 芯片如无法录指纹，请重启后再试 ★${NC}\n"
            sleep 3
            ;;
        # ... (其他选项) ...
    esac
done
