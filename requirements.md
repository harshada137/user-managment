# 📋 Project Requirements

Complete list of requirements for the Linux User Management & Backup Automation Script.

---

## 🖥️ System Requirements

### Operating System
- **Supported OS:**
  - Ubuntu 20.04 LTS or higher
  - Debian 10 or higher
  - CentOS 7 or higher
  - RHEL 7 or higher
  - Amazon Linux 2

- **Architecture:** 
  - x86_64 (64-bit)
  - ARM64 (for AWS Graviton instances)

### Hardware Requirements

#### Minimum Requirements
- **CPU:** 1 vCPU / 1 Core
- **RAM:** 1 GB
- **Storage:** 8 GB
- **Free Disk Space:** 1 GB (for backups)

#### Recommended Requirements
- **CPU:** 2 vCPU / 2 Cores
- **RAM:** 2 GB
- **Storage:** 20 GB
- **Free Disk Space:** 5 GB (for multiple backups)

---

## ☁️ AWS EC2 Requirements

### EC2 Instance Configuration

#### Instance Type Options
| Instance Type | vCPU | RAM | Storage | Cost/Hour (approx) | Recommended For |
|---------------|------|-----|---------|-------------------|-----------------|
| **t2.micro** | 1 | 1 GB | 8 GB | $0.0116 | Testing, Learning |
| **t2.small** | 1 | 2 GB | 20 GB | $0.023 | Light Production |
| **t3.micro** | 2 | 1 GB | 8 GB | $0.0104 | Free Tier Eligible |
| **t3.small** | 2 | 2 GB | 20 GB | $0.0208 | Production Use |

**Recommended:** `t2.micro` (sufficient for this project)

### AMI (Amazon Machine Image)
- **Recommended AMI:** Ubuntu Server 22.04 LTS
- **AMI ID Format:** ami-xxxxxxxxxxxxxxxxx
- **Region:** Choose nearest region (e.g., us-east-1, ap-south-1)

### Storage Configuration
- **Root Volume Type:** gp3 (General Purpose SSD)
- **Root Volume Size:** 8-20 GB
- **IOPS:** 3000 (default for gp3)
- **Throughput:** 125 MB/s (default)

### Network Configuration

#### VPC Settings
- Use default VPC (or custom VPC)
- Public subnet with internet gateway
- Auto-assign public IPv4 address: **Enabled**

#### Security Group Rules
| Type | Protocol | Port Range | Source | Description |
|------|----------|------------|--------|-------------|
| SSH | TCP | 22 | Your IP/0.0.0.0/0 | Allow SSH access |

**⚠️ Security Best Practice:** Restrict SSH to your IP only (not 0.0.0.0/0)

### Key Pair
- **Required:** Yes
- **Format:** .pem file (for Linux/Mac) or .ppk (for Windows/PuTTY)
- **Storage:** Keep in secure location with permissions 400

```bash
# Set correct permissions
chmod 400 your-key.pem
```

### IAM Role (Optional)
- **Purpose:** If accessing other AWS services
- **Policies:** AmazonS3ReadOnlyAccess (if backing up to S3)

---

## 💻 Software Requirements

### Required Software

#### 1. Bash Shell
- **Version:** 4.0 or higher
- **Check Version:**
```bash
bash --version
```

#### 2. Core Utilities (Pre-installed on most Linux)
- `tar` - Archive utility
- `gzip` - Compression utility
- `cron` - Task scheduler
- `useradd` - User creation
- `usermod` - User modification
- `userdel` - User deletion
- `groupadd` - Group creation
- `groupdel` - Group deletion
- `passwd` - Password management
- `id` - Display user identity
- `getent` - Get entries from databases

### Optional Software

#### 1. Git (for cloning repository)
```bash
# Install on Ubuntu/Debian
sudo apt install git -y

# Install on CentOS/RHEL
sudo yum install git -y
```

#### 2. Text Editors
- **Vim** (recommended)
```bash
sudo apt install vim -y
```
- **Nano** (beginner-friendly)
```bash
sudo apt install nano -y
```
- **VS Code** (local development)

#### 3. Monitoring Tools (Optional)
- `htop` - Process viewer
- `ncdu` - Disk usage analyzer
```bash
sudo apt install htop ncdu -y
```

---

## 👤 User Requirements

### Privileges
- **Required:** Root or sudo access
- **Reason:** User/group management requires elevated privileges

### Testing
```bash
# Verify sudo access
sudo whoami
# Output should be: root
```

### User Knowledge Requirements
- Basic Linux command line skills
- Understanding of user/group concepts
- SSH connection knowledge
- Basic file system navigation

---

## 🔒 Security Requirements

### File Permissions

#### Script Permissions
```bash
# Script should be executable by owner
chmod 700 user_manager.sh
# or
chmod +x user_manager.sh
```

#### Directory Permissions
```bash
# Backup directory
sudo mkdir -p /opt/backups
sudo chmod 755 /opt/backups

# Log directory
sudo chmod 755 /var/log
```

### SSH Key Permissions
```bash
# Private key must be readable only by owner
chmod 400 your-key.pem
```

### Firewall Rules
```bash
# Check firewall status (Ubuntu)
sudo ufw status

# Allow SSH if needed
sudo ufw allow 22/tcp
```

---

## 📦 Disk Space Requirements

### Space Allocation

#### System Directories
| Directory | Purpose | Minimum Size | Recommended Size |
|-----------|---------|--------------|------------------|
| `/opt/backups` | Backup storage | 500 MB | 5 GB |
| `/var/log` | Log files | 100 MB | 500 MB |
| `/home` | User home directories | 500 MB | 2 GB |
| `/` (root) | System files | 5 GB | 10 GB |

### Backup Size Estimation
```bash
# Check directory size before backup
du -sh /path/to/directory

# Check available space
df -h /opt/backups
```

### Disk Space Management
```bash
# Monitor disk usage
df -h

# Clean old backups
find /opt/backups -name "*.tar.gz" -mtime +30 -delete
```

---

## 🌐 Network Requirements

### Internet Connectivity
- **Required:** Yes (for package updates and Git clone)
- **Bandwidth:** Minimum 1 Mbps
- **Latency:** <100ms to AWS region

### Ports Required
| Port | Protocol | Purpose |
|------|----------|---------|
| 22 | TCP | SSH access |

### DNS Resolution
```bash
# Test DNS
ping google.com -c 3
nslookup google.com
```

---

## 📊 Performance Requirements

### CPU Usage
- **Script Execution:** <5% CPU
- **Backup Operations:** 10-30% CPU (depending on size)

### Memory Usage
- **Script Runtime:** <50 MB RAM
- **Backup Operations:** <100 MB RAM

### Backup Performance
| Directory Size | Compression Time | Backup Size Reduction |
|----------------|------------------|----------------------|
| 100 MB | ~5 seconds | ~30-50% |
| 1 GB | ~30 seconds | ~40-60% |
| 10 GB | ~5 minutes | ~50-70% |

---

## 🔧 Pre-Installation Checklist

### Before Starting

- [ ] AWS account created
- [ ] EC2 instance launched (t2.micro or higher)
- [ ] SSH key pair downloaded
- [ ] Security group configured (SSH access)
- [ ] Connected to instance via SSH
- [ ] System updated (`sudo apt update && sudo apt upgrade`)
- [ ] Git installed
- [ ] Text editor installed (vim/nano)
- [ ] Root/sudo access verified
- [ ] Minimum 1 GB free disk space available

### AWS Specific Checklist

- [ ] Region selected
- [ ] Ubuntu 22.04 LTS AMI selected
- [ ] Instance type chosen (t2.micro)
- [ ] 8-20 GB storage allocated
- [ ] Public IP assigned
- [ ] Security group allows SSH from your IP
- [ ] Key pair created and downloaded
- [ ] Instance in "running" state

---

## 🚨 Important Notes

### ⚠️ Production Deployment

If deploying in production:
1. **Backup existing data** before running script
2. **Test in staging environment** first
3. **Review security groups** carefully
4. **Use IAM roles** instead of access keys
5. **Enable CloudWatch** for monitoring
6. **Set up automated backups** of critical data
7. **Configure log rotation** to prevent disk fill
8. **Document all changes** made by script

### 💡 Cost Considerations

**AWS Free Tier Eligible:**
- t2.micro: 750 hours/month free for 12 months
- 30 GB EBS storage free
- Data transfer: 15 GB/month outbound

**Estimated Monthly Cost (After Free Tier):**
- t2.micro instance: ~$8.50/month
- 20 GB EBS storage: ~$2.00/month
- **Total:** ~$10.50/month

### 🔐 Security Best Practices

1. **Never share your private key**
2. **Restrict SSH access** to your IP only
3. **Use strong passwords** for user accounts
4. **Regularly update** system packages
5. **Enable MFA** on AWS account
6. **Monitor logs** regularly
7. **Backup encryption keys** securely
8. **Rotate credentials** periodically

---

## 📞 Support & Resources

### Useful Commands

```bash
# Check system info
uname -a
lsb_release -a

# Check disk space
df -h

# Check memory
free -h

# Check CPU
lscpu

# Check running processes
top
htop

# Check network
ip addr
netstat -tulpn
```

### Documentation Links

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Ubuntu Documentation](https://help.ubuntu.com/)
- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Linux User Management](https://www.linux.org/docs/)

---

## ✅ Verification

After setup, verify all requirements:

```bash
# 1. Check OS version
cat /etc/os-release

# 2. Check bash version
bash --version

# 3. Check disk space
df -h

# 4. Check required commands
which tar gzip useradd usermod userdel groupadd passwd cron

# 5. Check sudo access
sudo whoami

# 6. Check network
ping -c 3 google.com

# 7. Check Git (if installed)
git --version
```

All commands should execute successfully! ✅

---

**Last Updated:** December 17, 2025