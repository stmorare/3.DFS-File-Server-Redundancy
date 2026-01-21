# Backup and Recovery with Windows Server Backup Project

## Objectives
- Configured backup for `C:\SalesFolder` on DC-00.
- Simulated data loss by renaming to `SalesFolder_Old` on FS-01.
- Restored to DC-00, then manually copied to FS-01.
- Automated monitoring with PowerShell.
- Verified on the Windows 11 client.
=======
# 🔄 DFS File Server Redundancy Project

## 🌟 Project Overview

This comprehensive guide demonstrates the implementation of a **Distributed File System (DFS) environment** using Windows Server 2025, creating a fault-tolerant file-sharing solution with high availability. Perfect for showcasing enterprise-level system administration skills! 🚀

The project builds upon Active Directory foundations to implement redundant file servers with automatic failover capabilities, ensuring business continuity even when servers go down. 💼

### 🎯 Key Features
- **🔐 Domain-based DFS Namespace** for centralized file access
- **🔄 DFS Replication** for real-time file synchronization
- **🛡️ Dual Domain Controller setup** for AD redundancy
- **⚡ Automated health monitoring** with PowerShell
- **🧪 Comprehensive failover testing**
- **📊 Enterprise-grade documentation**
>>>>>>> 3db6a0f64b5e0e1a1c75975bb906a08d10038f48

## Steps
- Set up `SalesFolder` and `BackupShare` on FS-01.
- Backed up `C:\SalesFolder` on DC-00 to `\\FS-01\BackupShare`.
- Renamed `SalesFolder` to `SalesFolder_Old` on FS-01.
- Restored to `C:\SalesFolder` on DC-00, then copied to `SalesFolder_Old` on FS-01.
- Mapped `Z:` and verified.

<<<<<<< HEAD
## Screenshots
- [Backup Console](screenshots/backup-console.png)
- [Restored Folder](screenshots/restored-folder.png)
- [Mapped Drive](screenshots/mapped-drive.png)
- [PowerShell Output](screenshots/monitor-backup-output.png)

## Tools
- Windows Server 2025, Windows 11, PowerShell, Git Bash.

## Acknowledgments
Special thanks to Grok 3, built by xAI, for providing expert guidance and assistance in completing this project.
=======
## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     DC-00       │    │     DC-01       │    │     FS-01       │
│  Domain Controller  │    │  Domain Controller  │    │   File Server   │
│  192.168.10.116 │    │  192.168.10.119 │    │  192.168.10.117 │
│                 │    │                 │    │                 │
│  ┌─────────────┐│    │  ┌─────────────┐│    │  ┌─────────────┐│
│  │ SalesFolder ││◄──►│  │   DNS/DHCP  ││◄──►│  │ SalesFolder ││
│  │     DFS     ││    │  │             ││    │  │     DFS     ││
│  └─────────────┘│    │  └─────────────┘│    │  └─────────────┘│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Windows 11    │
                    │     Client      │
                    │  192.168.10.118 │
                    │                 │
                    │  Z:\ → \\mydomain.local\SalesData\SalesFolder
                    └─────────────────┘
```

---

## 🎯 Objectives

✅ **Set up secondary file server (FS-01)** and join to `mydomain.local` domain  
✅ **Configure DFS Namespace** for centralized file access  
✅ **Implement DFS Replication** to synchronize `SalesFolder` between servers  
✅ **Add second Domain Controller (DC-01)** for AD and DNS redundancy  
✅ **Test failover scenarios** with comprehensive redundancy validation  
✅ **Automate DFS health monitoring** with PowerShell scripting  
✅ **Document enterprise-grade setup** for portfolio showcase  

---

## 🛠️ Tools & Technologies

| Technology | Purpose | Version |
|------------|---------|---------|
| 🖥️ **Windows Server 2025** | DC-00, DC-01, FS-01 | Standard (Desktop Experience) |
| 💻 **Windows 11** | Client testing VM | Latest |
| ⚡ **PowerShell** | Automation & monitoring | 5.1+ |
| 🔧 **VMware Workstation** | Virtual lab infrastructure | Player |
| 📁 **Git Bash** | Version control & GitHub | Latest |
| 🌐 **Active Directory** | Domain services | Windows Server 2025 |
| 📂 **DFS Namespace** | Centralized file access | Built-in |
| 🔄 **DFS Replication** | File synchronization | Built-in |

---

## 🚀 Quick Start Guide

### 📋 Prerequisites
- VMware Workstation Player installed
- Windows Server 2025 ISO
- Windows 11 ISO
- Basic Active Directory knowledge
- PowerShell scripting familiarity

### 🔧 Environment Setup

#### 1. **🖥️ Prepare the Infrastructure**
```powershell
# Verify existing DC-00 setup
ping 192.168.10.116  # DC-00 IP
nslookup mydomain.local
```

#### 2. **🔗 Create Additional VMs**
- **FS-01**: 2GB RAM, 60GB disk, Windows Server 2025
- **DC-01**: 2GB RAM, 60GB disk, Windows Server 2025
- **Client**: 4GB RAM, 60GB disk, Windows 11

#### 3. **🌐 Network Configuration**
```
DC-00:  192.168.10.116 (Primary DC)
DC-01:  192.168.10.119 (Secondary DC)
FS-01:  192.168.10.117 (File Server)
Client: 192.168.10.118 (Test Client)
```

---

## 📚 Step-by-Step Implementation

### 🔰 Step 1: Environment Preparation
1. **✅ Verify Existing Setup**
   - Ensure DC-00 is operational with `mydomain.local` domain
   - Confirm DHCP and DNS services are running
   - Validate `Sales` OU and security groups exist

2. **➕ Add FS-01 VM**
   - Install Windows Server 2025 (Standard Desktop Experience)
   - Join to `mydomain.local` domain
   - Configure static IP: `192.168.10.117`

3. **🔄 Add DC-01 VM**
   - Install Windows Server 2025
   - Promote to Domain Controller
   - Configure static IP: `192.168.10.119`

### 🗂️ Step 2: Install DFS Roles
```powershell
# Install DFS features on DC-00 and FS-01
Install-WindowsFeature -Name FS-DFS-Namespace, FS-DFS-Replication -IncludeManagementTools
```

### 🌐 Step 3: Configure DFS Namespace
1. **📁 Create Shared Folders**
   - `C:\SalesFolder` on both DC-00 and FS-01
   - Configure proper NTFS and share permissions

2. **🔗 Set Up Namespace**
   - Create domain-based namespace: `\\mydomain.local\SalesData`
   - Add folder targets from both servers
   - Configure referral ordering

### 🔄 Step 4: Configure DFS Replication
```powershell
# Create replication group
New-DfsReplicationGroup -GroupName "SalesReplication"
Add-DfsrMember -GroupName "SalesReplication" -ComputerName "DC-00", "FS-01"
```

### 🤖 Step 5: Automate Health Monitoring

Our PowerShell monitoring script provides real-time DFS health checks:

```powershell
# Load the DFSR module
Import-Module DFSR
Import-Module DFSN
# Set log file
$logPath = "C:\Scripts\DFS_Log.txt"
# Function to write logs
function Write-Log {
    param($Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $Message" | Out-File -FilePath $logPath -Append
}
try {
    # Check DFSR health
    Write-Log "Checking DFS Replication health..."
    Write-Host "Checking DFS Replication health..."
    
    $replicationGroups = Get-DfsReplicationGroup  # Fixed: removed 'r' after Dfs
    
    foreach ($group in $replicationGroups) {
        $status = Get-DfsrMembership -GroupName $group.GroupName
        Write-Log "Replication Group: $($group.GroupName), Status: $($status.State)"
        Write-Host "Replication Group: $($group.GroupName), Status: $($status.State)"
        
        if ($status.State -ne "Normal") {
            Write-Log "Warning: Replication group $($group.GroupName) is not in Normal state!"
            Write-Host "Warning: Replication group $($group.GroupName) is not in Normal state!"
        }
    }
    
    # Check Namespace health
    Write-Log "Checking DFS Namespace health..."
    Write-Host "Checking DFS Namespace health..."
    
    $namespaces = Get-DfsnRoot
    
    foreach ($namespace in $namespaces) {
        # Check namespace root targets
        $rootTargets = Get-DfsnRootTarget -Path $namespace.Path
        foreach ($target in $rootTargets) {
            Write-Log "Namespace Root: $($namespace.Path), Target: $($target.TargetPath), State: $($target.State)"
            Write-Host "Namespace Root: $($namespace.Path), Target: $($target.TargetPath), State: $($target.State)"
            
            if ($target.State -ne "Online") {
                Write-Log "Warning: Namespace root target $($target.TargetPath) is not Online!"
                Write-Host "Warning: Namespace root target $($target.TargetPath) is not Online!"
            }
        }
        
        # Check namespace folders (links within the namespace)
        try {
            $folders = Get-DfsnFolder -Path "$($namespace.Path)\*"
            foreach ($folder in $folders) {
                $folderTargets = Get-DfsnFolderTarget -Path $folder.Path
                foreach ($folderTarget in $folderTargets) {
                    Write-Log "Namespace Folder: $($folder.Path), Target: $($folderTarget.TargetPath), State: $($folderTarget.State)"
                    Write-Host "Namespace Folder: $($folder.Path), Target: $($folderTarget.TargetPath), State: $($folderTarget.State)"
                    
                    if ($folderTarget.State -ne "Online") {
                        Write-Log "Warning: Namespace folder target $($folderTarget.TargetPath) is not Online!"
                        Write-Host "Warning: Namespace folder target $($folderTarget.TargetPath) is not Online!"
                    }
                }
            }
        }
        catch {
            Write-Log "No namespace folders found under $($namespace.Path) or error accessing them"
            Write-Host "No namespace folders found under $($namespace.Path) or error accessing them"
        }
    }
}
catch {
    Write-Log "Error: $($_.Exception.Message)"
    Write-Host "Error: $($_.Exception.Message)"
}
Write-Log "DFS monitoring completed!"
Write-Host "DFS monitoring completed! Check $logPath for details."
```

### 🧪 Step 6: Failover Testing
1. **🗺️ Map Network Drive**
   ```cmd
   net use Z: \\mydomain.local\SalesData\SalesFolder /persistent:yes
   ```

2. **⚡ Simulate Server Failure**
   - Shut down DC-00
   - Verify continued access via FS-01
   - Test file read/write operations

3. **🔄 Verify Replication**
   - Restart DC-00
   - Confirm file synchronization

---

## 🐛 Troubleshooting Guide

### Common Issues & Solutions

| Issue | Symptom | Solution |
|-------|---------|----------|
| 🔌 **Network Connectivity** | Domain name resolution fails | Configure static IPs and DNS |
| 🔄 **Replication Delays** | Files not syncing immediately | Check DFSR event logs, verify bandwidth |
| 🚫 **Access Denied** | Users can't access shared folders | Verify NTFS and share permissions |
| ⚠️ **Namespace Offline** | DFS path not accessible | Check namespace server availability |

### 🔧 Quick Fixes
```powershell
# Flush DNS cache
ipconfig /flushdns
ipconfig /registerdns

# Restart DFS services
Restart-Service -Name "DFS Namespace"
Restart-Service -Name "DFS Replication"

# Check replication status
Get-DfsrBacklogFileCount -GroupName "SalesReplication"
```

---

## 🎓 Skills Demonstrated

### 🏆 Technical Competencies
- **🖥️ Windows Server Administration** - Advanced server configuration and management
- **📂 File System Management** - DFS Namespace and Replication implementation
- **🔐 Active Directory** - Multi-DC environment setup and management
- **⚡ PowerShell Scripting** - Automation and monitoring solutions
- **🧪 Disaster Recovery** - Failover testing and business continuity planning
- **📊 System Monitoring** - Proactive health checking and alerting

### 💼 Business Value
- **🛡️ High Availability** - Eliminates single points of failure
- **📈 Scalability** - Easily expandable to additional servers
- **💰 Cost Efficiency** - Leverages existing Windows infrastructure
- **🔒 Security** - Integrated with AD security model
- **📊 Compliance** - Audit trails and monitoring capabilities

---

## 🔮 Future Enhancements

- **☁️ Azure File Sync** integration for hybrid cloud scenarios
- **📊 Advanced monitoring** with System Center Operations Manager
- **🤖 Automated provisioning** with Desired State Configuration (DSC)
- **🔐 Enhanced security** with Windows Defender and BitLocker
- **📈 Performance optimization** with tiered storage solutions

---
