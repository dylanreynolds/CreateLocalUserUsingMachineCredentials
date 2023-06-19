

<# 
.SYNOPSIS 
Pulls in the password as a SecureString.

.DESCRIPTION 
Pulls the encrypted password utilizing the key file provided to output a SecureString.

THIS CODE IS PROVIDED "AS IS", WITH NO WARRANTIES.

.PARAMETER PwdFile
Full path to file that the "passowrd" is saved.

.PARAMETER KeyFile
Full path to file that the "key" is saved.

.NOTES 
Author: Shawn Melton (@wsmelton), http://blog.wsmelton.com

.EXAMPLE   
Get-SecurePassword -PwdFile C:\MyPassword.txt -KeyFile C:\MyKey.key

Description
Retrieves the password found in C:\MyPassword.txt and decrypts it using the key found in C:\MyKey.key. 
Outputs the SecureString object to be used in a PSCredential object.
#>

function Get-SecurePassword {

    [cmdletbinding()]
    param(
        [string]$PwdFile,
        [string]$KeyFile
    )

    if ( !(Test-Path $PwdFile) ) {
        throw "Password File provided does not exist."
    }
    if ( !(Test-Path $KeyFile) ) {
        throw "KeyFile was not found."
    }

    $keyValue = Get-Content $KeyFile
    Get-Content $PwdFile | ConvertTo-SecureString -Key $keyValue
}

# Date and Logging
$Date = Get-Date
$DateStr = $Date.ToString("yyyy-MM-dd-hh-mm")
$folder = "C:\ProgramData\ALU"
$LogFileName = "ALU-"+ $DateStr
$LogFile = "$folder"+"\"+"$LogFileName.Log"

# Create the new local user account
$adminUsername = "admin"
$adminFullName = "Local Admin"
$adminDescription = "Last Updated "+$DateStr

Start-Transcript $LogFile -Force

Write-Output "Checking for User installation..."

If (Get-LocalUser -Name $adminUsername -ErrorAction SilentlyContinue) { 
    Write-Output "User account with that name already exists, updating password..." 
    Try {
        If(!(test-path -PathType container $folder)) {
            New-Item -ItemType Directory -Path $folder
        }
    } Catch{
        Write-Output "Directory already exists..."
        Continue
    } 

    Try {
        Write-Output "Downloading lastest securepassword..."
        Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/CreateLocalUserUsingMachineCredentials/main/MyPwd.txt" -outfile $folder"\MyPwd.txt"
        Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/CreateLocalUserUsingMachineCredentials/main/KeyFile.key" -outfile $folder"\KeyFile.txt"

        # Read the encrypted password from file
        $encryptedPassword = Get-SecurePassword -PwdFile .\MyPwd.txt -KeyFile .\KeyFile.key
        Remove-Item -Path $folder"\Password.txt" -Force
        Remove-Item -Path $folder"\KeyFile.key" -Force

        $adminAccountParams = @{
            Name = $adminUsername
            Password = $encryptedPassword
            Description = $adminDescription
        }
        Set-LocalUser @adminAccountParams

        # Add the new local user account to the Administrators group
        # Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
    } Catch{ 
        $ErrorMessage = $_.Exception.Message 
        Write-Output $ErrorMessage 
    } Finally{ 
        If ($ErrorMessage) { 
            Write-Output "Something went wrong" 
            Try {
                Stop-Transcript
            } Catch {
                Write-Output "Error stopping transcript: $_"
            }
            throw $ErrorMessage 
        } Else { 
            Write-Output "User account '$adminUsername' updated successfully."
            Try {
                Stop-Transcript
            } Catch {
                Write-Output "Error stopping transcript: $_"
            }
        } 
    }
} Else{ 
    Try {
    Write-Output "User account with that name does not exists, creating user account..." 
    Write-Output "Downloading securepassword..."
    Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/CreateLocalUserUsingMachineCredentials/main/MyPwd.txt" -outfile $folder"\MyPwd.txt"
    Invoke-WebRequest -v "https://raw.githubusercontent.com/dylanreynolds/CreateLocalUserUsingMachineCredentials/main/KeyFile.key" -outfile $folder"\KeyFile.txt"

    # Read the encrypted password from file
    $encryptedPassword = Get-SecurePassword -PwdFile .\MyPwd.txt -KeyFile .\KeyFile.key
    Remove-Item -Path $folder"\MyPwd.txt" -Force
    Remove-Item -Path $folder"\KeyFile.key" -Force

    $adminAccountParams = @{
        Name = $adminUsername
        FullName = $adminFullName
        Description = $adminDescription
        Password = $encryptedPassword
        PasswordNeverExpires = $true
        AccountNeverExpires = $true
    }
    New-LocalUser @adminAccountParams

    # Add the new local user account to the Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
    
    Write-Output "User account '$adminUsername' has been created successfully." 
    
    } Catch{
        Write-Output "Error stopping transcript: $_"
        Stop-Transcript
    }
}
