# CreateLocalUserUsingMachineCredentials
To get around key file and non-keyfile passwords

# .SYNOPSIS 
Creates OR Updates Local Administrator account using MDM scripts in Intune.

# .DESCRIPTION 
Creates a local admin using credentials key and secure key password txt file. (no stored text)
Get-SecurePassword - credit to Author: Shawn Melton (@wsmelton), http://blog.wsmelton.com

# .PARAMETER PwdFile
Full path to file that the "password" is saved.

# .PARAMETER KeyFile
Full path to file that the "key" is saved.

# .NOTES 
Requires a MyPwd.txt generated using https://github.com/dylanreynolds/GenerateSecureStringWithKey

# .EXAMPLE   
Gets run from intune - not intented to be run locally.


# .PROBLEMS  
Security concerns yet to be addressed including both the path to the pwd file and key file.
Perhaps they are moved to an internal server for referencing only.
