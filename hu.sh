#!/bin/bash

# ============================================
# MacBook MDM 绕过工具 - 专家增强版 (V60)
# 作者: 华强北小胡 (福田吴彦祖)
# 微信: huhu-019
# 适用: Intel (带Touchbar/T2) & M1/M2/M3/M4/M5 全系列
# ============================================

# 颜色定义
RED='\033[1;31m'
GRN='\033[1;32m'
BLU='\033[1;34m'
YEL='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

# 清屏
clear

# 1. 智能获取数据盘路径 (核心：自动识别“Data”或“数据”盘符)
get_data_path() {
    if [ -d "/Volumes/Data" ]; then
        echo "/Volumes/Data"
    elif [ -d "/Volumes/Macintosh HD - Data" ]; then
        echo "/Volumes/Macintosh HD - Data"
    elif [ -d "/Volumes/Macintosh HD - 数据" ]; then
        echo "/Volumes/Macintosh HD - 数据"
    else
        # 寻找包含 Data 或 数据 字样的卷
        local found_path=$(ls -d /Volumes/*Data* 2>/dev/null | head -n 1)
        if [ -z "$found_path" ]; then
            found_path=$(ls -d /Volumes/*数据* 2>/dev/null | head -n 1)
        fi
        echo "$found_path"
    fi
}

# 2. 显示欢迎信息
show_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${YEL}      欢迎使用 MacBook MDM 绕过工具 - 专家版         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}║${GRN}  🔒 华强北小胡 - 国内最早专售MDM配置锁专家        ${CYAN}║${NC}"
    echo -e "${CYAN}║${GRN}  🚀 微信: huhu-19 | 闲鱼: 福田吴彦祖             ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 3. 强制挂载并解锁权限
force_mount_all() {
    echo -e "${YEL}🔄 正在解除磁盘只读限制...${NC}"
    mount -uw /Volumes/Macintosh\ HD 2>/dev/null
    local data_path=$(get_data_path)
    if [ ! -z "$data_path" ]; then
        mount -uw "$data_path" 2>/dev/null
        echo -e "${GRN}✅ 已挂载数据盘: $data_path${NC}"
    fi
}

# 4. 创建管理员用户 (解决 not a known dslocal status)
create_user_smart() {
    local data_path=$(get_data_path)
    if [ -z "$data_path" ]; then
        echo -e "${RED}❌ 错误: 找不到数据盘，请先在磁盘工具中“装载”！${NC}"
        return 1
    fi

    local dscl_path="$data_path/private/var/db/dslocal/nodes/Default"
    
    echo -e "${CYAN}👤 正在创建管理员用户 (Apple/1234)...${NC}"
    
    # 核心创建逻辑
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple" UserShell "/bin/zsh"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple" RealName "Apple"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple" UniqueID "501"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple" PrimaryGroupID "20"
    dscl -f "$dscl_path" localhost -create "/Local/Default/Users/Apple" NFSHomeDirectory "/Users/Apple"
    dscl -f "$dscl_path" localhost -passwd "/Local/Default/Users/Apple" "1234"
    dscl -f "$dscl_path" localhost -append "/Local/Default/Groups/admin" GroupMembership "Apple"
    
    mkdir -p "$data_path/Users/Apple"
    echo -e "${GRN}✅ 用户创建完成${NC}"
}

# 5. 屏蔽域名 (包含Albert等6个域名)
block_hosts_smart() {
    echo -e "${YEL}🛡️  正在配置Hosts屏蔽...${NC}"
    local target="/Volumes/Macintosh HD/etc/hosts"
    
    if [ -f "$target" ]; then
        cat >> "$target" << EOF

# MDM 屏蔽规则 - 华强北小胡配置
0.0.0.0 acmdm.apple.com
0.0.0.0 mdmenrollment.apple.com
0.0.0.0 deviceenrollment.apple.com
0.0.0.0 iprofiles.apple.com
0.0.0.0 albert.apple.com
0.0.0.0 deviceservices-external.apple.com
EOF
        echo -e "${GRN}✅ 域名屏蔽完成 (6个服务器)${NC}"
    else
        echo -e "${RED}❌ 错误: 找不到Hosts文件路径${NC}"
    fi
}

# 6. 一键绕过主逻辑
auto_bypass() {
    force_mount_all
    block_hosts_smart
    
    # 写入激活标记文件
    echo -e "${YEL}📝 正在写入绕过标记...${NC}"
    rm -f /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord 2>/dev/null
    touch /Volumes/Macintosh\ HD/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled
    
    local data_path=$(get_data_path)
    if [ ! -z "$data_path" ]; then
        touch "$data_path/private/var/db/.AppleSetupDone"
    fi
    
    create_user_smart
    
    echo -e "\n${GRN}🎉 华强北小胡提示：MDM绕过全部完成！${NC}"
    echo -e "${YEL}请直接重启电脑，使用 Apple (密码1234) 登录即可。${NC}"
}

# 执行脚本
show_banner
auto_bypass
