Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{Multiselect = $false}
    $OpenFileDialog.Title = "Please Select the Install.wim file for repair."
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "WIM (*.wim)| *.wim"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filenames
}

cls

Write-Host "Select from the following choices:"
Write-Host -fore yellow "1: Scan Health: To check an image for corruption"
Write-host -fore yellow "2: Check Health: To see if image corruption has been detected"
Write-Host -fore yellow "3: Restore Health from local source and Windows Update"
Write-Host -fore red "4: Restore Health from external source (Requires installation media or ISO)"
write-host ""
Write-Host -fore green "Enter your selection below:"
$scan = Read-Host

if($scan -eq "1"){
    $scan = Repair-WindowsImage -Online -ScanHealth
    }
if($scan -eq "2"){
    $scan = Repair-WindowsImage -Online -CheckHealth
    }
if($scan -eq "3"){
    $scan = Repair-WindowsImage -Online -RestoreHealth
    }
if($scan -eq "4"){
    RepSource
}
if(!$scan){EndScript}
else{
$scan
}

Function RepSource{
# Obtain source for image repair attempt
write-host -fore yellow "Insert DVD or mount ISO to retrive WIM file for health restore"
write-host -fore yellow "Browse to install.wim file from your installation source"
write-host ""
$src = Get-FileName("C")
if (!$src){EndScript}
Else{
$src
}


# Obtain index of image for repair attempt
Write-Host -fore Yellow "Identify the installation index for the version of Windows currently installed"
write-host ""
Get-WindowsImage -ImagePath $src
write-host ""
Write-Host -fore Green "Type the index number and select enter:"
$idx = Read-Host
if (!$idx){EndScript}
Else{
$idx
}

# Obtain mount directory for image
Write-Host -fore Green "Select the location for mounting the repair image from the browse window"
$mntdir = New-Object System.Windows.Forms.FolderBrowserDialog
    if($mntdir.ShowDialog() -eq 'OK'){
    $mntdir = $mntdir.SelectedPath
    }
if (!$mntdir){EndScript}
Else{
$mntdir
}

# Mount the image
Write-Host -red "This process will mount $src to $mntdir as a repair source"
Mount-WindowsImage -Imagepath $src -index:$idx -path $mntdir


# Attempt DISM restore health


Write-Host "Repair-WindowsImage -Online $scan -Source $src -LimitAccess"

# Dismount the repair image
Dismount-WindowsImage -path $mntdir
}
