# Backup and Recovery with Windows Server Backup Project

## Objectives
- Configured backup for `C:\SalesFolder` on DC-00.
- Simulated data loss by renaming to `SalesFolder_Old` on FS-01.
- Restored to DC-00, then manually copied to FS-01.
- Automated monitoring with PowerShell.
- Verified on the Windows 11 client.

## Steps
- Set up `SalesFolder` and `BackupShare` on FS-01.
- Backed up `C:\SalesFolder` on DC-00 to `\\FS-01\BackupShare`.
- Renamed `SalesFolder` to `SalesFolder_Old` on FS-01.
- Restored to `C:\SalesFolder` on DC-00, then copied to `SalesFolder_Old` on FS-01.
- Mapped `Z:` and verified.

## Screenshots
- [Backup Console](screenshots/backup-console.png)
- [Restored Folder](screenshots/restored-folder.png)
- [Mapped Drive](screenshots/mapped-drive.png)
- [PowerShell Output](screenshots/monitor-backup-output.png)

## Tools
- Windows Server 2025, Windows 11, PowerShell, Git Bash.

## Acknowledgments
Special thanks to Grok 3, built by xAI, for providing expert guidance and assistance in completing this project.