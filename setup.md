# 🚀 Complete Setup Guide

Step-by-step guide to set up and run the Linux User Management & Backup Automation Script on AWS EC2.

---

## 📑 Table of Contents

1. [AWS Account Setup](#1-aws-account-setup)
2. [Launch EC2 Instance](#2-launch-ec2-instance)
3. [Connect to EC2 Instance](#3-connect-to-ec2-instance)
4. [System Configuration](#4-system-configuration)
5. [Install Dependencies](#5-install-dependencies)
6. [Clone Repository](#6-clone-repository)
7. [Script Setup](#7-script-setup)
8. [Run and Test](#8-run-and-test)
9. [Verify Installation](#9-verify-installation)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. AWS Account Setup

### 1.1 Create AWS Account (if you don't have one)

1. Go to [AWS Console](https://aws.amazon.com/)
2. Click **"Create an AWS Account"**
3. Fill in required details:
   - Email address
   - Password
   - AWS account name
4. Choose **Personal** account type
5. Enter payment information (required for verification)
6. Verify phone number
7. Select **Basic Support (Free)** plan
8. Wait for account activation email

### 1.2 Sign in to AWS Console

1. Go to [AWS Console](https://console.aws.amazon.com/)
2. Enter your email and password
3. Complete MFA if enabled

---

## 2. Launch EC2 Instance

### 2.1 Navigate to EC2 Dashboard

```
AWS Console → Search "EC2" → Click "EC2"
```

### 2.2 Launch Instance

**Step-by-Step:**

1. Click **"Launch Instance"** button (orange button)

2. **Name and Tags**
   ```
   Name: linux-user-management-server
   ```

3. **Application and OS Images (AMI)**
   - Click **"Ubuntu"**
   - Select **"Ubuntu Server 22.04 LTS"**
   - Architecture: **64-bit (x86)**
   - ✅ Verify "Free tier eligible" label

4. **Instance Type**
   - Select: **t2.micro**
   - vCPU: 1
   - Memory: 1 GiB
   - ✅ Free tier eligible

5. **Key Pair (login)**
   
   **If you have a key pair:**
   - Select existing key pair from dropdown
   
   **If you need to create new key pair:**
   - Click **"Create new key pair"**
   - Key pair name: `my-ec2-key`
   - Key pair type: **RSA**
   - Private key file format: 
     - **Mac/Linux:** `.pem`
     - **Windows:** `.pem` (use with Git Bash) or `.ppk` (use with PuTTY)
   - Click **"Create key pair"**
   - **File downloads automatically** - Save it securely!

6. **Network Settings**
   - Click **"Edit"** button
   
   **VPC:** Use default VPC (or select your VPC)
   
   **Subnet:** No preference (or select specific subnet)
   
   **Auto-assign public IP:** **Enable**
   
   **Firewall (Security Groups):**
   - Select **"Create security group"**
   - Security group name: `linux-management-sg`
   - Description: `Allow SSH access`
   
   **Inbound Security Group Rules:**
   - Type: **SSH**
   - Protocol: **TCP**
   - Port range: **22**
   - Source type: **My IP** (recommended) or **Anywhere** (0.0.0.0/0)
   - ⚠️ Using "My IP" is more secure!

7. **Configure Storage**
   - Root volume:
     - Size: **8 GB** (minimum) or **20 GB** (recommended)
     - Volume type: **gp3**
     - Delete on termination: ✅ (checked)

8. **Advanced Details** (Optional - you can skip this)
   - Leave default settings

9. **Summary**
   - Review all settings
   - Number of instances: **1**

10. **Launch**
    - Click **"Launch instance"**
    - Wait for success message
    - Click **"View all instances"**

### 2.3 Wait for Instance to Start

```
Instance State should be: "running" (green)
Status Check: "2/2 checks passed"
```

⏱️ This takes 1-2 minutes

### 2.4 Note Down Important Information

From EC2 Instances page, note:
- ✅ **Instance ID:** i-0123456789abcdef0
- ✅ **Public IPv4 address:** 3.25.123.456
- ✅ **Public IPv4 DNS:** ec2-3-25-123-456.compute.amazonaws.com
- ✅ **Availability Zone:** us-east-1a

---

## 3. Connect to EC2 Instance

### 3.1 Set Key Permissions (Mac/Linux)

```bash
# Navigate to directory where your key is saved
cd ~/Downloads

# Set correct permissions (IMPORTANT!)
chmod 400 my-ec2-key.pem

# Verify permissions
ls -la my-ec2-key.pem
# Output should show: -r--------
```

### 3.2 Connect via SSH

#### Option A: Using Terminal (Mac/Linux)

```bash
# SSH command format:
ssh -i /path/to/your-key.pem ubuntu@YOUR_PUBLIC_IP

# Example:
ssh -i ~/Downloads/my-ec2-key.pem ubuntu@3.25.123.456
```

**First time connection:**
```
The authenticity of host '3.25.123.456' can't be established.
ECDSA key fingerprint is SHA256:xxxxxxxxxxxxx.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
Type: `yes` and press Enter

**Successful connection shows:**
```
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-1045-aws x86_64)

ubuntu@ip-172-31-1-72:~$
```

#### Option B: Using Git Bash (Windows)

1. Download and install [Git for Windows](https://git-scm.com/download/win)
2. Open **Git Bash**
3. Follow same SSH command as Mac/Linux:

```bash
ssh -i /c/Users/YourName/Downloads/my-ec2-key.pem ubuntu@3.25.123.456
```

#### Option C: Using PuTTY (Windows)

1. Download [PuTTY](https://www.putty.org/)
2. Convert .pem to .ppk using PuTTYgen
3. Open PuTTY
4. Enter IP address in "Host Name"
5. Go to Connection → SSH → Auth → Credentials
6. Browse and select your .ppk file
7. Click "Open"

### 3.3 Verify Connection

Once connected, verify you're on the EC2 instance:

```bash
# Check hostname
hostname
# Output: ip-172-31-x-x

# Check OS
cat /etc/os-release
# Output should show: Ubuntu 22.04

# Check you're ubuntu user
whoami
# Output: ubuntu

# Check sudo access
sudo whoami
# Output: root
```

✅ If all commands work, you're successfully connected!

---

## 4. System Configuration

### 4.1 Update System Packages

```bash
# Update package list
sudo apt update

# Upgrade installed packages
sudo apt upgrade -y
```

⏱️ This takes 2-5 minutes depending on updates

**Expected output:**
```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following packages will be upgraded:
  ...
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

### 4.2 Check System Information

```bash
# Check disk space
df -h
# Should show at least 1GB free on /

# Check memory
free -h
# Should show available memory

# Check CPU
lscpu | grep "Model name"

# Check kernel version
uname -r
```

---

## 5. Install Dependencies

### 5.1 Install Git

```bash
# Install Git
sudo apt install git -y

# Verify installation
git --version
```

**Expected output:**
```
git version 2.34.1
```

### 5.2 Install Vim (Text Editor)

```bash
# Install Vim
sudo apt install vim -y

# Verify installation
vim --version | head -1
```

**Expected output:**
```
VIM - Vi IMproved 8.2
```

**Alternative:** Install Nano (easier for beginners)
```bash
sudo apt install nano -y
```

### 5.3 Verify Required Commands

```bash
# Check if all required commands exist
which tar && echo "✓ tar found"
which gzip && echo "✓ gzip found"
which useradd && echo "✓ useradd found"
which usermod && echo "✓ usermod found"
which cron && echo "✓ cron found"
```

All should output "✓ [command] found"

---

## 6. Clone Repository

### 6.1 Create Project Directory

```bash
# Create and navigate to project directory
mkdir -p ~/projects
cd ~/projects
```

### 6.2 Clone the Repository

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/linux-user-management-backup.git

# Navigate into project directory
cd linux-user-management-backup

# List files
ls -la
```

**Expected output:**
```
-rwxr-xr-x 1 ubuntu ubuntu  12345 Dec 17 10:30 user_manager.sh
-rw-r--r-- 1 ubuntu ubuntu   5678 Dec 17 10:30 README.md
-rw-r--r-- 1 ubuntu ubuntu   1234 Dec 17 10:30 REQUIREMENTS.md
```

### 6.3 Verify Script Content

```bash
# View first 20 lines of script
head -20 user_manager.sh

# Check script size
wc -l user_manager.sh
```

---

## 7. Script Setup

### 7.1 Make Script Executable

```bash
# Make script executable
chmod +x user_manager.sh

# Verify permissions
ls -l user_manager.sh
```

**Expected output:**
```
-rwxr-xr-x 1 ubuntu ubuntu 12345 Dec 17 10:30 user_manager.sh
```

### 7.2 Create Required Directories

```bash
# Create backup directory
sudo mkdir -p /opt/backups

# Create log files
sudo touch /var/log/user_management.log
sudo touch /var/log/backup.log

# Set permissions
sudo chmod 755 /opt/backups
sudo chmod 644 /var/log/user_management.log
sudo chmod 644 /var/log/backup.log

# Verify directories
ls -ld /opt/backups
ls -l /var/log/user_management.log
ls -l /var/log/backup.log
```

### 7.3 Verify Setup

```bash
# Check if script can be executed
bash -n user_manager.sh
# No output means no syntax errors ✅

# Check script location
pwd
# Should show: /home/ubuntu/projects/linux-user-management-backup
```

---

## 8. Run and Test

### 8.1 First Run

```bash
# Run the script with sudo
sudo ./user_manager.sh
```

**Expected output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     USER MANAGEMENT & BACKUP SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Main Menu:
1) User Management
2) Group Management
3) Backup Operations
4) View Logs
5) Exit

Enter choice:
```

✅ **Success!** The script is running correctly.

### 8.2 Test User Creation

**Follow these steps:**

1. Type `1` (User Management) and press Enter
2. Type `1` (Add User) and press Enter
3. Enter details:
   ```
   Enter username: testuser1
   Enter full name (optional): Test User One
   Select shell [1]: [press Enter for default]
   Additional groups: [press Enter to skip]
   ```
4. Set password when prompted:
   ```
   Enter new UNIX password: testpass123
   Retype new UNIX password: testpass123
   ```
5. Grant sudo: `y`

**Expected output:**
```
✓ User 'testuser1' created successfully
✓ Password set successfully
✓ Sudo privileges granted

User Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
uid=1001(testuser1) gid=1001(testuser1) groups=1001(testuser1),27(sudo)
Home Directory: /home/testuser1
Shell: /bin/bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 8.3 Test Backup Creation

1. Create test directory:
```bash
# Exit script first (type 5 → 0)
mkdir -p ~/test-backup
echo "Test file" > ~/test-backup/file.txt
```

2. Run script again:
```bash
sudo ./user_manager.sh
```

3. Perform backup:
   ```
   Type: 3 (Backup Operations)
   Type: 1 (Backup Directory)
   Enter directory path: /home/ubuntu/test-backup
   Enter backup name: [press Enter]
   Exclude patterns: [press Enter]
   Proceed? y
   ```

**Expected output:**
```
Creating backup...
✓ Backup completed successfully
Backup size: 1.2K
```

### 8.4 Verify Backup

```bash
# Exit script
# List backups
ls -lh /opt/backups/

# Check backup contents
tar -tzf /opt/backups/test-backup_backup_*.tar.gz
```

---

## 9. Verify Installation

### 9.1 Check Created User

```bash
# Verify user exists
id testuser1

# Check home directory
ls -la /home/testuser1

# Check groups
groups testuser1

# Check sudo access
sudo -l -U testuser1
```

### 9.2 Check Logs

```bash
# View user management log
sudo cat /var/log/user_management.log

# View backup log
sudo cat /var/log/backup.log

# Monitor logs in real-time (open another terminal)
sudo tail -f /var/log/user_management.log
```

### 9.3 Test User Login

```bash
# Switch to created user
su - testuser1
# Enter password: testpass123

# Test sudo access
sudo whoami
# Enter password again
# Should output: root

# Exit back to ubuntu user
exit
```

### 9.4 Run Complete Verification Script

```bash
#!/bin/bash
echo "=== System Verification ==="

echo -n "1. Checking script... "
[[ -x user_manager.sh ]] && echo "✓" || echo "✗"

echo -n "2. Checking backup directory... "
[[ -d /opt/backups ]] && echo "✓" || echo "✗"

echo -n "3. Checking log files... "
[[ -f /var/log/user_management.log ]] && echo "✓" || echo "✗"

echo -n "4. Checking test user... "
id testuser1 &>/dev/null && echo "✓" || echo "✗"

echo -n "5. Checking backups... "
[[ $(ls /opt/backups/*.tar.gz 2>/dev/null | wc -l) -gt 0 ]] && echo "✓" || echo "✗"

echo "=== Verification Complete ==="
```

Save this as `verify.sh` and run:
```bash
chmod +x verify.sh
./verify.sh
```

---

## 10. Troubleshooting

### Issue 1: Permission Denied

**Error:**
```
-bash: ./user_manager.sh: Permission denied
```

**Solution:**
```bash
chmod +x user_manager.sh
sudo ./user_manager.sh
```

### Issue 2: Script Must Be Run as Root

**Error:**
```
ERROR: This script must be run as root or with sudo
```

**Solution:**
```bash
# Always use sudo
sudo ./user_manager.sh
```

### Issue 3: Can't Connect to EC2

**Error:**
```
Connection timed out
```

**Solution:**
```bash
# 1. Check security group allows SSH from your IP
# 2. Check instance is running
# 3. Verify you're using correct IP address
# 4. Check key permissions: chmod 400 key.pem
```

### Issue 4: User Already Exists

**Error:**
```
✗ User 'testuser1' already exists
```

**Solution:**
```bash
# Delete existing user first
sudo userdel -r testuser1

# Or use different username
```

### Issue 5: No Space Left on Device

**Error:**
```
tar: Cannot write: No space left on device
```

**Solution:**
```bash
# Check disk space
df -h

# Clean old backups
sudo rm /opt/backups/old_*.tar.gz

# Or increase EBS volume size in AWS Console
```

### Issue 6: Cron Job Not Running

**Problem:** Scheduled backups not working

**Solution:**
```bash
# Check cron service
sudo systemctl status cron

# Start cron if not running
sudo systemctl start cron

# Enable cron to start on boot
sudo systemctl enable cron

# Check cron jobs
sudo crontab -l
```

### Issue 7: Git Clone Fails

**Error:**
```
fatal: could not read Username
```

**Solution:**
```bash
# Make sure repository is public
# Or use HTTPS URL
git clone https://github.com/username/repo.git
```

---

## 📸 Screenshot Guide

### When to Take Screenshots

1. **After launching EC2** - Show instance in "running" state
2. **After SSH connection** - Show terminal with ubuntu prompt
3. **Main menu** - First screen of script
4. **User creation** - Success message
5. **User verification** - Output of `id username`
6. **Backup creation** - Backup success message
7. **Backup verification** - `ls /opt/backups`
8. **Cron job** - Output of `sudo crontab -l`
9. **Logs** - Sample log entries

### How to Take Screenshots

**Mac:**
- Entire screen: `Cmd + Shift + 3`
- Selected area: `Cmd + Shift + 4`

**Windows:**
- Snipping Tool or `Windows + Shift + S`

**Linux:**
- `gnome-screenshot` or `Alt + Print Screen`

---

## 🎉 Success Checklist

After completing this guide, verify:

- [✅] AWS EC2 instance running
- [✅] Successfully connected via SSH
- [✅] System updated and dependencies installed
- [✅] Repository cloned
- [✅] Script executable and running
- [✅] Test user created successfully
- [✅] Backup completed successfully
- [✅] Logs are being written
- [✅] All screenshots taken
- [✅] Can access user with created credentials

---

## 🔄 Next Steps

1. **Document your work** - Create TESTING_REPORT.md
2. **Take screenshots** - For GitHub repository
3. **Clean up test data** - Remove test users/backups
4. **Push to GitHub** - Update repository
5. **Share your project** - Add link to LinkedIn/resume

---

## 📞 Need Help?

If you encounter issues not covered here:

1. Check [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
2. Review [Ubuntu Documentation](https://help.ubuntu.com/)
3. Open an issue on GitHub
4. Contact via email

---

**Setup Guide Version:** 1.0  
**Last Updated:** December 17, 2024  
**Tested On:** Ubuntu 22.04 LTS, AWS EC2 t2.micro