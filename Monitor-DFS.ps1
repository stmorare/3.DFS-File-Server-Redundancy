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