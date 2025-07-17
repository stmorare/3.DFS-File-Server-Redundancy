Absolutely! Here is a **clear, actionable step-by-step guide** for the DFS File Server Redundancy Project on Windows Server 2025, mirroring the direct instructional style of your previous project guides.

# Step-by-Step Guide: DFS File Server Redundancy Project (Windows Server 2025)

## 1. Prepare Your Lab Environment

### 1.1. Set Up Hardware (VMs)
- **VMs Needed:**
  - **DC-00**: Primary Domain Controller (192.168.10.116)
  - **DC-01**: Secondary Domain Controller (192.168.10.119)
  - **FS-01**: File Server (192.168.10.117)
  - **Client**: Windows 11 workstation (192.168.10.118)
- Assign static IP addresses. Set DNS on all servers/clients to point to DC-00 and DC-01.

### 1.2. Join Machines to the Domain
- On FS-01, DC-01, and client:
  - Open **System Properties** (`sysdm.cpl`), join to `mydomain.local`.
  - Reboot if prompted.

## 2. Promote DC-01 to Domain Controller

1. On **DC-01**:
    - Open **Server Manager > Add Roles and Features**.
    - Select **Active Directory Domain Services** (AD DS).
    - Complete the wizard; then select **Promote this server to a domain controller**.
    - Choose **Add a domain controller to an existing domain**.
    - Provide credentials, choose DNS Server if prompted.
    - Set Directory Services Restore Mode (DSRM) password.
    - Complete the wizard and reboot.

## 3. Install DFS Roles

1. On **DC-00** and **FS-01**:
    - Open **Server Manager > Add Roles and Features**.
    - Select **File and Storage Services > File and iSCSI Services**.
    - Check **DFS Namespaces** and **DFS Replication**.
    - Click **Next** and **Install**.
    - Repeat for FS-01.

*OR* via PowerShell (run as Administrator):
```powershell
Install-WindowsFeature -Name FS-DFS-Namespace, FS-DFS-Replication -IncludeManagementTools
```

## 4. Prepare Shared Folders

1. On **DC-00**:
    - Create folder: `C:\SalesFolder`
    - Right-click > **Properties > Sharing > Advanced Sharing**
    - Share as `SalesFolder`
2. On **FS-01**:
    - Create `C:\SalesFolder`
    - Repeat sharing steps above.

**Set NTFS and Share permissions** so relevant AD groups (e.g., `SG_Sales_Staff`, `SG_Sales_Manager`) have access.

## 5. Create a Domain-based DFS Namespace

1. On **DC-00**:
    - Open **DFS Management** (`dfsmgmt.msc`).
    - Right-click **Namespaces > New Namespace**.
    - **Server**: DC-00
    - **Namespace name:** `SalesData`
    - **Namespace type:** **Domain-based** (`\\mydomain.local\SalesData`)
    - Finish wizard.

2. Add folder target:
    - Right-click new namespace > **New Folder**
    - Folder name: `SalesFolder`
    - **Add targets:**  
        - `\\DC-00\SalesFolder`
        - `\\FS-01\SalesFolder`

## 6. Set Up DFS Replication

1. In **DFS Management**:
    - Right-click **Replication > New Replication Group**.
    - Choose **Multipurpose replication group** > Next
    - **Name:** SalesReplication
    - **Add members:** DC-00, FS-01
    - **Replicated folder:** `C:\SalesFolder` on both servers.
    - **Topology:** Full Mesh recommended for two servers.
    - **Primary member:** DC-00 (sets initial data).
    - **Bandwidth**: Leave default for lab.
    - Finish wizard; initial replication will begin.

## 7. Verify DFS Namespace and Replication

1. **Check Replication Status:**
    - In DFS Management > Replication > SalesReplication, check Replicated Folders.
    - Make a test file on DC-00 in `C:\SalesFolder`; within a few minutes, it should appear on FS-01 (and vice versa).

2. **Validate Namespace Access:**
    - On the **Windows 11 client**, map network drive:
        ```cmd
        net use Z: \\mydomain.local\SalesData\SalesFolder /persistent:yes
        ```
    - Access Z: drive, create/read/delete files to confirm functionality.

## 8. Automated Health Monitoring (PowerShell)

1. Create script, e.g. `C:\Scripts\Monitor-DFS.ps1`:
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
2. Schedule via **Task Scheduler** for regular checks.

3. See **DFS Management > Replication** for backlog/errors.

## 9. Perform Failover Testing

1. On client, map drive as above.
2. **Shut down DC-00**.
3. Access Z: drive again—should redirect transparently to FS-01.
4. Test read/write operations.
5. **Restart DC-00**, ensure DFS synchronizes missed changes.

## 10. Troubleshooting Tips

| Symptom                  | Check/Solution                                              |
|--------------------------|------------------------------------------------------------|
| DFS Namespace inaccessible   | Ping all servers; verify AD, DNS, and network connectivity.    |
| Replication delays           | See Event Viewer logs on both servers (DFSR).                |
| Access denied                | Permissions: Check both NTFS and share permissions.          |
| Data out-of-sync             | Force sync: `dfsrdiag syncnow /partner:FS-01 /RGName:SalesReplication /RFName:SalesFolder` |

# Summary

By following this guide, you will:
- **Deploy a redundant file service** with seamless failover via DFS Namespace and Replication.
- **Automatically synchronize files** between two servers, protecting against downtime.
- Enhance your **Active Directory** and **PowerShell automation** portfolio with real-world, enterprise-grade solutions.
