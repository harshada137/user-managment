#!/bin/bash

################################################################################
# Script Name: user_manager.sh
# Description: Comprehensive User Management and Backup Script for Linux
# Version: 2.0 (Optimized)
# Usage: sudo ./user_manager.sh
################################################################################

set -euo pipefail

################################################################################
# CONFIGURATION
################################################################################

LOG_FILE="/var/log/user_management.log"
BACKUP_DIR="/opt/backups"
BACKUP_LOG="/var/log/backup.log"
DATE=$(date +%Y%m%d_%H%M%S)

# Detect sudo group (Debian vs RHEL)
SUDO_GROUP=$(getent group sudo >/dev/null && echo sudo || echo wheel)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

################################################################################
# BASIC FUNCTIONS
################################################################################

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

pause() {
    echo ""
    read -p "Press Enter to continue..."
}

check_root() {
    [[ $EUID -eq 0 ]] || { echo -e "${RED}Run as root${NC}"; exit 1; }
}

init_dirs() {
    mkdir -p "$BACKUP_DIR"
    touch "$LOG_FILE" "$BACKUP_LOG"
    chmod 755 "$BACKUP_DIR"
    chmod 644 "$LOG_FILE" "$BACKUP_LOG"
}

user_exists() { id "$1" &>/dev/null; }
group_exists() { getent group "$1" &>/dev/null; }

################################################################################
# USER MANAGEMENT
################################################################################

add_user() {
    echo -e "\n${BLUE}━━━ ADD NEW USER ━━━${NC}"
    read -p "Username: " username
    [[ "$username" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || { echo -e "${RED}Invalid username${NC}"; pause; return; }
    user_exists "$username" && { echo -e "${RED}User already exists${NC}"; pause; return; }

    read -p "Full name (optional): " fullname
    read -p "Shell (bash/sh/zsh) [bash]: " shell
    shell=${shell:-bash}

    cmd=(useradd -m -s "/bin/$shell")
    [[ -n "${fullname:-}" ]] && cmd+=(-c "$fullname")

    # Ask whether to add to group
    read -p "Add user to any group? (y/n): " add_grp
    if [[ "$add_grp" =~ ^[Yy]$ ]]; then
        read -p "Enter group name(s) (comma-separated): " groups
        if [[ -n "$groups" ]]; then
            cmd+=(-G "$groups")
        fi
    fi

    cmd+=("$username")

    if "${cmd[@]}"; then
        echo -e "${GREEN}✓ User created${NC}"
    else
        echo -e "${RED}✗ User creation failed${NC}"
        pause
        return
    fi

    # Set password
    echo -e "\n${CYAN}Set password for $username:${NC}"
    if passwd "$username"; then
        echo -e "${GREEN}✓ Password set${NC}"
    else
        echo -e "${RED}✗ Password setting failed${NC}"
    fi

    # Grant sudo access
    read -p "Grant sudo access? (y/n): " sudo_ans
    if [[ "$sudo_ans" =~ ^[Yy]$ ]]; then
        usermod -aG "$SUDO_GROUP" "$username"
        echo -e "${GREEN}✓ Sudo access granted${NC}"
    fi

    # Display user info
    echo -e "\n${GREEN}User Information:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    id "$username"
    echo "Home: $(eval echo ~$username)"
    echo "Shell: /bin/$shell"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    log_action "USER_ADD: Created user '$username' with shell /bin/$shell"
    pause
}

delete_user() {
    echo -e "\n${BLUE}━━━ DELETE USER ━━━${NC}"
    read -p "Username to delete: " username
    
    # Validation checks
    user_exists "$username" || { echo -e "${RED}User not found${NC}"; pause; return; }
    [[ "$username" == "root" ]] && { echo -e "${RED}Cannot delete root${NC}"; pause; return; }
    
    # Check for system user (UID < 1000)
    uid=$(id -u "$username")
    [[ $uid -lt 1000 ]] && { echo -e "${RED}Cannot delete system user${NC}"; pause; return; }
    
    # Display user info before deletion
    echo -e "\n${YELLOW}User to be deleted:${NC}"
    id "$username"
    
    # Confirmation
    echo -e "\n${YELLOW}⚠ This action cannot be undone!${NC}"
    read -p "Are you sure you want to delete '$username'? (yes/no): " confirm
    [[ "$confirm" != "yes" ]] && { echo -e "${CYAN}Cancelled${NC}"; pause; return; }
    
    # Delete user
    read -p "Remove home directory? (y/n): " rmhome
    if [[ "$rmhome" =~ ^[Yy]$ ]]; then
        if userdel -r "$username" 2>/dev/null; then
            echo -e "${GREEN}✓ User and home directory deleted${NC}"
            log_action "USER_DELETE: Deleted user '$username' with home directory"
        else
            echo -e "${RED}✗ Deletion failed${NC}"
        fi
    else
        if userdel "$username" 2>/dev/null; then
            echo -e "${GREEN}✓ User deleted (home directory preserved)${NC}"
            log_action "USER_DELETE: Deleted user '$username' (home preserved)"
        else
            echo -e "${RED}✗ Deletion failed${NC}"
        fi
    fi
    
    pause
}

list_users() {
    echo -e "\n${BLUE}━━━ USER LIST ━━━${NC}"
    echo ""
    printf "${CYAN}%-20s %-6s %-30s %-15s${NC}\n" USER UID HOME SHELL
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    awk -F: '$3>=1000 && $3!=65534 {printf "%-20s %-6s %-30s %-15s\n",$1,$3,$6,$7}' /etc/passwd
    echo ""
    pause
}

modify_user() {
    echo -e "\n${BLUE}━━━ MODIFY USER ━━━${NC}"
    read -p "Username to modify: " username
    
    user_exists "$username" || { echo -e "${RED}User not found${NC}"; pause; return; }
    
    echo -e "\n${CYAN}Current Info:${NC}"
    id "$username"
    
    echo -e "\n${CYAN}Modifications:${NC}"
    echo "1) Change password"
    echo "2) Grant sudo access"
    echo "3) Revoke sudo access"
    echo "4) Lock account"
    echo "5) Unlock account"
    echo "0) Back"
    
    read -p "Choice: " mod_choice
    
    case $mod_choice in
        1)
            passwd "$username" && echo -e "${GREEN}✓ Password changed${NC}"
            log_action "USER_MODIFY: Changed password for '$username'"
            ;;
        2)
            usermod -aG "$SUDO_GROUP" "$username" && echo -e "${GREEN}✓ Sudo granted${NC}"
            log_action "USER_MODIFY: Granted sudo to '$username'"
            ;;
        3)
            gpasswd -d "$username" "$SUDO_GROUP" && echo -e "${GREEN}✓ Sudo revoked${NC}"
            log_action "USER_MODIFY: Revoked sudo from '$username'"
            ;;
        4)
            usermod -L "$username" && echo -e "${GREEN}✓ Account locked${NC}"
            log_action "USER_MODIFY: Locked account '$username'"
            ;;
        5)
            usermod -U "$username" && echo -e "${GREEN}✓ Account unlocked${NC}"
            log_action "USER_MODIFY: Unlocked account '$username'"
            ;;
        0) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    pause
}

################################################################################
# GROUP MANAGEMENT
################################################################################

create_group() {
    echo -e "\n${BLUE}━━━ CREATE GROUP ━━━${NC}"
    read -p "Group name: " group
    
    group_exists "$group" && { echo -e "${RED}Group already exists${NC}"; pause; return; }
    
    if groupadd "$group"; then
        echo -e "${GREEN}✓ Group '$group' created${NC}"
        log_action "GROUP_CREATE: Created group '$group'"
    else
        echo -e "${RED}✗ Group creation failed${NC}"
    fi
    
    pause
}

delete_group() {
    echo -e "\n${BLUE}━━━ DELETE GROUP ━━━${NC}"
    read -p "Group name: " group
    
    group_exists "$group" || { echo -e "${RED}Group not found${NC}"; pause; return; }
    
    # Check for members
    members=$(getent group "$group" | cut -d: -f4)
    [[ -n "$members" ]] && echo -e "${YELLOW}⚠ Group has members: $members${NC}"
    
    read -p "Delete group '$group'? (yes/no): " confirm
    [[ "$confirm" != "yes" ]] && { echo -e "${CYAN}Cancelled${NC}"; pause; return; }
    
    if groupdel "$group"; then
        echo -e "${GREEN}✓ Group deleted${NC}"
        log_action "GROUP_DELETE: Deleted group '$group'"
    else
        echo -e "${RED}✗ Deletion failed${NC}"
    fi
    
    pause
}

list_groups() {
    echo -e "\n${BLUE}━━━ GROUP LIST ━━━${NC}"
    echo ""
    printf "${CYAN}%-30s %-6s %-40s${NC}\n" GROUP GID MEMBERS
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    awk -F: '$3>=1000 && $3!=65534 {printf "%-30s %-6s %-40s\n",$1,$3,$4}' /etc/group
    echo ""
    pause
}

manage_group_members() {
    echo -e "\n${BLUE}━━━ MANAGE GROUP MEMBERS ━━━${NC}"
    read -p "Group name: " group
    
    group_exists "$group" || { echo -e "${RED}Group not found${NC}"; pause; return; }
    
    members=$(getent group "$group" | cut -d: -f4)
    echo -e "\n${CYAN}Current members:${NC} ${members:-<none>}"
    
    echo -e "\n1) Add user"
    echo "2) Remove user"
    echo "0) Back"
    
    read -p "Choice: " choice
    
    case $choice in
        1)
            read -p "Username to add: " username
            user_exists "$username" || { echo -e "${RED}User not found${NC}"; pause; return; }
            usermod -aG "$group" "$username" && echo -e "${GREEN}✓ User added to group${NC}"
            log_action "GROUP_MEMBER: Added '$username' to '$group'"
            ;;
        2)
            read -p "Username to remove: " username
            gpasswd -d "$username" "$group" && echo -e "${GREEN}✓ User removed from group${NC}"
            log_action "GROUP_MEMBER: Removed '$username' from '$group'"
            ;;
        0) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    pause
}

################################################################################
# BACKUP FUNCTIONS
################################################################################

backup_directory() {
    echo -e "\n${BLUE}━━━ BACKUP DIRECTORY ━━━${NC}"
    read -p "Directory to backup: " src
    
    [[ -d "$src" ]] || { echo -e "${RED}Invalid directory${NC}"; pause; return; }

    name=$(basename "$src")
    dest="$BACKUP_DIR/${name}_$DATE.tar.gz"

    echo -e "\n${CYAN}Creating backup...${NC}"
    if tar -czf "$dest" -C "$(dirname "$src")" "$(basename "$src")" 2>>"$BACKUP_LOG"; then
        size=$(du -h "$dest" | cut -f1)
        echo -e "${GREEN}✓ Backup successful${NC}"
        echo "Location: $dest"
        echo "Size: $size"
        log_action "BACKUP: Created backup '$dest' (Size: $size)"
    else
        echo -e "${RED}✗ Backup failed${NC}"
        log_action "BACKUP: FAILED to backup '$src'"
    fi
    
    pause
}

schedule_backup() {
    echo -e "\n${BLUE}━━━ SCHEDULE BACKUP ━━━${NC}"
    read -p "Directory to backup: " src
    
    [[ -d "$src" ]] || { echo -e "${RED}Invalid directory${NC}"; pause; return; }

    read -p "Hour (0-23): " hour
    [[ "$hour" =~ ^([0-9]|1[0-9]|2[0-3])$ ]] || { echo -e "${RED}Invalid hour${NC}"; pause; return; }

    script="$BACKUP_DIR/backup_$(date +%s).sh"

    cat > "$script" <<EOF
#!/bin/bash
tar -czf "$BACKUP_DIR/$(basename "$src")_\$(date +%Y%m%d_%H%M%S).tar.gz" -C "$(dirname "$src")" "$(basename "$src")"
echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Scheduled backup completed" >> "$BACKUP_LOG"
EOF

    chmod +x "$script"
    (crontab -l 2>/dev/null; echo "0 $hour * * * $script") | crontab -

    echo -e "${GREEN}✓ Backup scheduled${NC}"
    echo "Schedule: Daily at ${hour}:00"
    echo "Script: $script"
    
    log_action "SCHEDULE: Backup scheduled for '$src' at hour $hour"
    pause
}

list_backups() {
    echo -e "\n${BLUE}━━━ BACKUP LIST ━━━${NC}"
    echo ""
    
    if [[ $(ls -A "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l) -eq 0 ]]; then
        echo "No backups found"
    else
        printf "${CYAN}%-50s %-10s %-20s${NC}\n" "BACKUP FILE" "SIZE" "DATE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{printf "%-50s %-10s %-20s\n", $9, $5, $6" "$7" "$8}'
    fi
    
    echo ""
    pause
}

view_logs() {
    echo -e "\n${BLUE}━━━ RECENT LOGS ━━━${NC}"
    echo ""
    
    if [[ -f "$LOG_FILE" ]]; then
        echo -e "${CYAN}User Management Log (Last 20 entries):${NC}"
        tail -20 "$LOG_FILE"
    else
        echo "No logs found"
    fi
    
    echo ""
    pause
}

################################################################################
# MAIN MENU
################################################################################

main_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}     USER MANAGEMENT & BACKUP SYSTEM${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}User Management:${NC}"
    echo "  1) Add User"
    echo "  2) Delete User"
    echo "  3) Modify User"
    echo "  4) List Users"
    echo ""
    echo -e "${CYAN}Group Management:${NC}"
    echo "  5) Create Group"
    echo "  6) Delete Group"
    echo "  7) Manage Group Members"
    echo "  8) List Groups"
    echo ""
    echo -e "${CYAN}Backup Operations:${NC}"
    echo "  9) Backup Directory"
    echo " 10) Schedule Backup"
    echo " 11) List Backups"
    echo ""
    echo -e "${CYAN}System:${NC}"
    echo " 12) View Logs"
    echo "  0) Exit"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

################################################################################
# ENTRY POINT
################################################################################

check_root
init_dirs

while true; do
    main_menu
    read -p "Enter choice: " choice
    case $choice in
        1) add_user ;;
        2) delete_user ;;
        3) modify_user ;;
        4) list_users ;;
        5) create_group ;;
        6) delete_group ;;
        7) manage_group_members ;;
        8) list_groups ;;
        9) backup_directory ;;
        10) schedule_backup ;;
        11) list_backups ;;
        12) view_logs ;;
        0) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}"; pause ;;
    esac
done