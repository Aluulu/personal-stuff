Start-Transcript -Path "C:\Path\To\File\logfile.log"

# Write the code you wish to be logged here

Stop-Transcript







# Name: Start-Transcript
# Module: Microsoft.PowerShell.Host
# Microsoft Docs page: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires
# Syntax: Start-Transcript [[-Path] <String>] [-Append] [-Force] [-NoClobber] [-IncludeInvocationHeader] [-UseMinimalHeader] [-WhatIf] [-Confirm] [<CommonParameters>]
#    -Path                          - Specifies the file path in which the log will be stored in. If specified but blank, or not used, it will default to $Home\Documents\PowerShell_transcript.<time-stamp>.txt
#    -Append                        - Specifies that this new log should be added to a existing file. The Path parameter must be used if Append is specified.
#    -Force                         - Forces an append to a pre-existing read-only file. Cannot be used if the user doesn't have permissions to change the file permissions.
#    -NoClobber                     - Specifies that the script should not attempt to save to the specified location if a file already exists in that location.
#    -IncludeInvocationHeader       - Indicates that commands have their time stamps when they are ran.
#    -UseMinimalHeader              - Prepend a short header to the transcript, instead of the detailed header included by default.
#    -WhatIf                        - Shows what would happen if the cmdlet runs. The cmdlet is not run.
#    -Confirm                       - Prompts you for confirmation before running the cmdlet.


# It will be a good idea to have this command near the top of your scripts so that as much information is saved as possible.
# This will make going back over files to find issues a lot easier.


# Keep in mind that some commands are not written to the log file. Cmdlets like Read-Host for example do not store the user's input.
# Instead, you should confirm their input through a variable and write it back to the host so that it is written and saved.
# For example:
#       $Username = read-host 'Enter username'
#       Write-Host "You have chosen $Username"


# It is imperative that you end your scripts with Stop-Transcript otherwise the cmdlet will continue storing information after it is no longer needed.
# Some issues it can cause are:
#       - Preventing editing/moving of the log file as it is currently in use/open.
#       - Storing additional non-important information.
#       - The file size being larger than expected.