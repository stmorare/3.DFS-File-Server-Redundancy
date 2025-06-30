# DFS File Server Redundancy

## Overview
This project implements a redundant file server setup using Distributed File System (DFS) on Windows Server 2025, 
ensuring high availability of the `SalesFolder` via a Namespace (`SalesData`) and Replication. 
A second Domain Controller (DC-01) was added for AD and DNS redundancy.

## Objectives
- Configured FS-01 as a file server and joined it to `mydomain.local`.
- Set up DFS Namespace and Replication for `SalesFolder`.
- Added DC-01 for domain redundancy.
- Tested failover with DC-00 down.
- Automated health checks with PowerShell.

## Steps
- **Environment Setup**: Created FS-01 and DC-01 VMs, joined to `mydomain.local`.
- **DFS Configuration**: Installed roles, created `SalesFolder`, configured Namespace and Replication.
- **Automation**: Developed `Monitor-DFS.ps1` for health monitoring.
- **Failover Test**: Mapped drive, simulated DC-00 failure, verified access via FS-01 and DC-01.
- **Troubleshooting**: Resolved network and domain issues with static IPs and secondary namespace server.

## Screenshots
- [DFS Namespace Configuration](screenshots/dfs-namespace.png)
- [Failover Test](screenshots/failover-test.png)
- [PowerShell Output](screenshots/monitor-dfs-output.png)

## Tools
- Windows Server 2025, Windows 11, PowerShell, VMware Workstation Player, Git Bash.

## Challenges
- Initial reliance on DC-00 due to DNS and namespace issues, resolved with DC-01 and FS-01 as namespace server.
