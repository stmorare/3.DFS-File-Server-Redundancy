### DFS File Server Redundancy Project

This document provides a comprehensive guide to the **DFS File Server Redundancy Project**, detailing the setup, configuration, testing, 
and troubleshooting of a Distributed File System (DFS) environment using Windows Server 2025. 
The project aims to create a redundant file server setup with a Domain Controller (DC), a secondary file server (FS-01), and a client, 
ensuring high availability of the `SalesFolder` via DFS Namespace and Replication. The documentation is intended for upload to a new GitHub repository 
as a separate project in your system administration portfolio.

---

#### Project Overview
The DFS File Server Redundancy Project builds on your Active Directory (AD) skills to implement a fault-tolerant file-sharing solution. 
Using two Windows Server 2025 VMs (DC-00 and DC-01 as Domain Controllers) and a file server (FS-01), along with a Windows 11 client, 
the project configures a DFS Namespace (`SalesData`) and Replication to synchronize the `SalesFolder` across servers, allowing access even if one server fails. 
Automation and failover testing are included to demonstrate enterprise-level administration capabilities.

#### Objectives
- Set up a second Windows Server 2025 VM (FS-01) as a file server and join it to the `mydomain.local` domain.
- Configure a DFS Namespace for centralized file access.
- Implement DFS Replication to synchronize the `SalesFolder` between servers.
- Add a second Domain Controller (DC-01) for AD and DNS redundancy.
- Test failover and redundancy with the new DC setup.
- Automate DFS health checks with a PowerShell script.
- Document the setup for portfolio purposes.

#### Tools Used
- **Windows Server 2025**: DC-00, DC-01, and FS-01.
- **Windows 11**: Client VM for testing.
- **PowerShell**: For automation and monitoring.
- **VMware Workstation Player**: For virtual lab setup.
- **Git Bash**: For uploading to GitHub.

---

### Step-by-Step Guide

#### Step 1: Prepare the Environment
1. **Verify Existing Setup**:
   - Ensure DC-00 (e.g., IP 192.168.10.116) is running with domain `mydomain.local`, DHCP, and DNS configured.
   - Confirm the `Sales` OU, `SG_Sales_Staff`, and `SG_Sales_Manager` groups exist.
2. **Add FS-01 VM**:
   - Create a new Windows Server 2025 VM with 2 GB RAM and 60 GB disk space.
   - Install with **Standard (Desktop Experience)** option.
   - Join to `mydomain.local`:
     - **System Properties > Change > Domain** > Enter `mydomain.local` > Use domain admin credentials (e.g., `mydomain\administrator`).
   - Name it `FS-01` and assign a static IP (e.g., 192.168.10.117).
3. **Add DC-01 VM**:
   - Create a new Windows Server 2025 VM with 2 GB RAM and 60 GB disk space.
   - Install and join to `mydomain.local`.
   - Promote to DC:
     - **Server Manager > Add roles and features** > Install **Active Directory Domain Services**.
     - Post-installation, **Promote this server to a domain controller** > **Add a new domain controller to an existing domain** > Use `mydomain\administrator` credentials.
     - Set static IP (e.g., 192.168.10.119) and complete the wizard.
   - Restart and verify in **Active Directory Users and Computers**.

#### Step 2: Install DFS Roles
1. **On DC-00 and FS-01**:
   - **Server Manager > Add roles and features** > Select **File and Storage Services** > Install **DFS Namespaces** and **DFS Replication**.
   - Restart if prompted.
2. **Create Shared Folder**:
   - On DC-00, create `C:\SalesFolder` and share it:
     - **Properties > Sharing > Share** > Add `SG_Sales_Staff` (Read/Write), `SG_Sales_Manager` (Read/Write).
     - **Security** tab: `SG_Sales_Staff` (Read & Execute), `SG_Sales_Manager` (Modify).
   - Repeat on FS-01 for `C:\SalesFolder`.

#### Step 3: Configure DFS Namespace
1. **On DC-00**:
   - Open **DFS Management** > Right-click **Namespaces** > **New Namespace**.
   - Select DC-00, name the namespace `SalesData`, choose **Domain-based namespace**.
   - Add folder `SalesFolder` with targets:
     - `\\DC-00\SalesFolder`.
     - `\\FS-01\SalesFolder` (after sharing on FS-01).
   - Set referral ordering to **Lowest cost**.
2. **Add FS-01 as Namespace Server**:
   - Right-click `SalesData` > **Add Namespace Server** > Select FS-01 > **Next** > **Create**.

#### Step 4: Configure DFS Replication
1. **On DC-00**:
   - Open **DFS Management** > Right-click **Replication** > **New Replication Group**.
   - Choose **Multipurpose Replication Group** > **Next**.
   - Name it `SalesReplication` > **Next**.
   - Add DC-00 and FS-01 as members > **Next**.
   - Select **Full Mesh** topology > **Next**.
   - Set **Replicate continuously using the specified bandwidth** (Full) > **Next**.
   - Choose DC-00 as primary member > **Next**.
   - Add `SalesFolder` as the replicated folder (paths `C:\SalesFolder` on both) > **Next**.
   - Review and **Create** > **Close**.
2. **Verify Replication**:
   - Add `test.txt` to `C:\SalesFolder` on DC-00 and check FS-01 after a few minutes.

#### Step 5: Automate DFS Health Checks
1. **Create PowerShell Script**:
   - Save as `C:\Scripts\Monitor-DFS.ps1` on DC-00:

     ```powershell
     # Load the DFSR module
     Import-Module DFSR

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
         $replicationGroups = Get-DfsrReplicationGroup
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
             $targets = Get-DfsnFolderTarget -Path $namespace.Path
             Write-Log "Namespace: $($namespace.Path), Targets: $($targets.TargetPath)"
             Write-Host "Namespace: $($namespace.Path), Targets: $($targets.TargetPath)"
             if ($targets.State -ne "Online") {
                 Write-Log "Warning: Namespace target $($targets.TargetPath) is not Online!"
                 Write-Host "Warning: Namespace target $($targets.TargetPath) is not Online!"
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

2. **Run the Script**:
   - **PowerShell (as admin)**:
     ```powershell
     cd C:\Scripts
     .\Monitor-DFS.ps1
     ```
   - Check `C:\Scripts\DFS_Log.txt` for results.

#### Step 6: Test Failover and Redundancy
1. **Map the Drive**:
   - On the Windows 11 client, map `Z:` to `\\mydomain.local\SalesData\SalesFolder` with a domain user (e.g., `mydomain\janesmith`) and **Remember my credentials**.
2. **Simulate Failure**:
   - Shut down DC-00.
   - Verify client and FS-01 retain "mydomain.local" labeling (via DC-01).
   - Access `Z:\` and read/write `failover-test.txt`.
3. **Restore and Verify**:
   - Restart DC-00 and check replication on DC-01 via **DFS Management**.

#### Step 7: Configure Network Independence
- **Static IPs**:
  - Client: 192.168.10.118, DNS 192.168.10.116, 192.168.10.119.
  - FS-01: 192.168.10.117, DNS 192.168.10.116, 192.168.10.119.
  - Run `ipconfig /flushdns` and `ipconfig /registerdns` on both.
- **Optional DHCP on DC-01**:
  - Install DHCP role, create scope (192.168.10.100-200), and authorize.

#### Step 8: Troubleshoot Issues
- **Network Loss**: Resolved with static IPs.
- **Domain Visibility**: Ensured by DC-01.
- **DFS Dependency**: Eliminated by adding FS-01 as namespace server.

---

### GitHub Upload
1. **Create New Repository**:
   - On GitHub, create a repository named `DFS-File-Server-Redundancy-Project`.
2. **Set Up Local Folder**:
   - Create `C:\SystemAdminProjects\DFS-File-Server-Redundancy-Project`.
   - Copy `Monitor-DFS.ps1`, screenshots, and this `README.md` to the folder.
3. **Initialize and Push**:
   - **Git Bash**:
     ```bash
     cd /c/SystemAdminProjects/DFS-File-Server-Redundancy-Project
     git init
     git add .
     git commit -m "Initial commit: Added DFS File Server Redundancy Project documentation"
     git remote add origin https://github.com/your-username/DFS-File-Server-Redundancy-Project.git
     git push -u origin main
     ```
---

### Acknowledgements
- Collaborated with Grok 3, built by xAI, for expert guidance and assistance in completing this project.
- Collaborated with Grok 3, built by xAI, for expert guidance and assistance in completing this project.