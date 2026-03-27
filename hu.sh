#!/bin/bash
# ==================================================
# MacBook 稳定工具箱（终极版）
# 特点：稳定 / 可恢复 /   小胡同学
# ==================================================

# 颜色
RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'; CYAN='\033[1;36m'; NC='\033[0m'

# 自动识别系统盘
SYS_PATH=$(df / | tail -1 | awk '{print $6}')
DATA_PATH=""

for d in /Volumes/*; do
  if [[ "$d" == "Data" ]]; then
    DATA_PATH="$d"
    break
  fi
done

if [[ -z "$DATA_PATH" ]]; then
  echo -e "${RED}❌ 未找到 Data 磁盘，请检查${NC}"
  exit 1
fi

# hosts 文件路径
HOSTS_FILE="$SYS_PATH/etc/hosts"
BACKUP_HOSTS="$SYS_PATH/etc/hosts.bak"

# MDM域名（安全版）
MDM_DOMAINS=(
"deviceenrollment.apple.com"
"mdmenrollment.apple.com"
"iprofiles.apple.com"
)

# ===== 功能函数 =====

create_admin() {
  echo -e "${YEL}创建管理员中...${NC}"

  NEXT_UID=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1)
  NEXT_UID=$((NEXT_UID + 1))

  USERNAME="MacBook"

  dscl . -create /Users/$USERNAME
  dscl . -create /Users/$USERNAME UserShell /bin/zsh
  dscl . -create /Users/$USERNAME RealName "MacBook"
  dscl . -create /Users/$USERNAME UniqueID $NEXT_UID
  dscl . -create /Users/$USERNAME PrimaryGroupID 20
  dscl . -create /Users/$USERNAME NFSHomeDirectory /Users/$USERNAME
  dscl . -passwd /Users/$USERNAME 1234
  dscl . -append /Groups/admin GroupMembership $USERNAME

  echo -e "${GRN}✅ 管理员创建完成：$USERNAME / 1234${NC}"
}

block_mdm() {
  echo -e "${YEL}屏蔽 MDM 域名中...${NC}"

  # 备份 hosts
  cp "$HOSTS_FILE" "$BACKUP_HOSTS"

  for d in "${MDM_DOMAINS[@]}"; do
    grep -q "$d" "$HOSTS_FILE" || echo "0.0.0.0 $d" >> "$HOSTS_FILE"
  done

  echo -e "${GRN}✅ MDM 屏蔽完成${NC}"
}

restore_hosts() {
  if [[ -f "$BACKUP_HOSTS" ]]; then
    cp "$BACKUP_HOSTS" "$HOSTS_FILE"
    echo -e "${GRN}✅ hosts 已恢复${NC}"
  else
    echo -e "${RED}❌ 没有备份文件${NC}"
  fi
}

bypass() {
  echo -e "${YEL}开始稳定绕过...${NC}"

  create_admin

  # 标记跳过设置
  touch "$DATA_PATH/private/var/db/.AppleSetupDone"

  # 删除远程管理记录
  rm -rf "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigHasActivationRecord"
  touch "$SYS_PATH/var/db/ConfigurationProfiles/Settings/.cloudConfigProfileInstalled"

  block_mdm

  echo -e "${GRN}🎉 绕过完成！请重启${NC}"
}

check_status() {
  echo -e "${CYAN}当前设备状态：${NC}"
  profiles show -type enrollment
  read -p "回车返回..."
}

# ===== 主菜单 =====
while true; do
  clear
  echo -e "${CYAN}=========================================${NC}"
  echo -e "${YEL}      MacBook 终极版。                     ${NC}"
  echo -e "${CYAN}=========================================${NC}"
  echo -e " 1. 一键自动绕过MDM"
  echo -e " 2. 创建管理员"
  echo -e " 3. 屏蔽 MDM（临时）"
  echo -e " 4. 恢复 hosts（推荐更新前执行）"
  echo -e " 5. 查看监管状态"
  echo -e " 6. 重启电脑"
  echo -e " 0. 退出"
  echo -e "${CYAN}=========================================${NC}"

  read -p "请选择: " opt

  case $opt in
    1) bypass; sleep 2 ;;
    2) create_admin; sleep 2 ;;
    3) block_mdm; sleep 2 ;;
    4) restore_hosts; sleep 2 ;;
    5) check_status ;;
    6) reboot ;;
    0) exit 0 ;;
    *) echo "无效输入"; sleep 1 ;;
  esac
done
