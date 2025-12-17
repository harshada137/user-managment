# 🧪 Quick Test Checklist

Simple testing guide for User Management & Backup Script.

---

## 📋 Pre-Test Setup

```bash
cd ~/projects/linux-user-management-backup
df -h  # Check disk space
sudo ./user_manager.sh  # Start script
```

---

## ✅ Test Cases

### 1. User Management (5 tests)

#### Test 1: Create User
```
Menu: 1
Username: testuser1
Full name: Test User
Shell: [Enter]
Add to group: n
Sudo: y
Password: test123
```
**Verify:** `id testuser1` → Should show user with sudo group  
**Status:** [PASS]   
**Screenshot:** `01-user-creation.png`

---

#### Test 2: Create User Without Sudo
```
Menu: 1
Username: testuser2
Full name: Test Two
Shell: sh
Add to group: n
Sudo: n
Password: test456
```
**Verify:** `groups testuser2` → Should NOT have sudo  
**Status:** [PASS]

---

#### Test 3: List Users
```
Menu: 4
```
**Verify:** Should show ubuntu, testuser1, testuser2  
**Status:** [PASS]  
**Screenshot:** `02-list-users.png`

---

#### Test 4: Modify User (Change Password)
```
Menu: 3
Username: testuser1
Choice: 1
New password: newpass123
```
**Verify:** `su - testuser1` with new password  
**Status:** [PASS] 

---

#### Test 5: Delete User
```
Menu: 2
Username: testuser2
Confirm: yes
Remove home: y
```
**Verify:** `id testuser2` → Should fail (user not found)  
**Status:** [PASS]  
**Screenshot:** `03-user-deletion.png`

---

### 2. Group Management (3 tests)

#### Test 6: Create Group
```
Menu: 5
Group name: developers
```
**Verify:** `getent group developers`  
**Status:** [PASS]  
**Screenshot:** `04-group-creation.png`

---

#### Test 7: Add User to Group
```
Menu: 7
Group: developers
Choice: 1
Username: testuser1
```
**Verify:** `groups testuser1` → Should include developers  
**Status:** [PASS]

---

#### Test 8: List Groups
```
Menu: 8
```
**Verify:** Should show developers group  
**Status:** [PASS]  
**Screenshot:** `05-list-groups.png`

---

### 3. Backup Operations (3 tests)

#### Test 9: Create Test Data
```bash
mkdir ~/test-backup
echo "test file" > ~/test-backup/file.txt
```
**Status:** [PASS]

---

#### Test 10: Backup Directory
```
Menu: 9
Directory: /home/ubuntu/test-backup
```
**Verify:** `ls -lh /opt/backups/`  
**Status:** [PASS]  
**Screenshot:** `06-backup-creation.png`

---

#### Test 11: Schedule Backup
```
Menu: 10
Directory: /home/ubuntu/test-backup
Hour: 2
```
**Verify:** `sudo crontab -l`  
**Status:** [PASS]  
**Screenshot:** `07-cron-schedule.png`

---

### 4. Logging & Security (2 tests)

#### Test 12: View Logs
```
Menu: 12
```
**Verify:** Should show recent operations  
**Status:** [PASS]  
**Screenshot:** `08-logs.png`

---

#### Test 13: Root Check
```bash
./user_manager.sh  # WITHOUT sudo
```
**Verify:** Should show error "Run as root"  
**Status:** [PASS]

---

## 📊 Summary

**Total Tests:** 13  
**Passed:** 13  
**Failed:** 0   
**Success Rate:** 100 %

---

## 🧹 Cleanup

```bash
# Remove test data
sudo userdel -r testuser1
sudo userdel -r testuser2
sudo groupdel developers
rm -rf ~/test-backup
```

---

## 📸 Required Screenshots (8 total)

1. ✅ User creation
2. ✅ List users
3. ✅ User deletion
4. ✅ Group creation
5. ✅ List groups
6. ✅ Backup creation
7. ✅ Cron schedule
8. ✅ View logs

---

**Test Date:** 17-12-2025 
**Tester:** Harshada Sharad Patil 
**Status:** ✅ Complete