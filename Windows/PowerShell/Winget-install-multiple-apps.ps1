Write-Output "Installing Apps using WinGet"
$AppsToInstall = @(
    @{name = "7zip.7zip" },
    @{name = "Adobe.Acrobat.Reader.64-bit" }, 
    @{name = "Foxit.FoxitReader" }, 
    @{name = "Ubuntu"; source = "msstore" }, 
    @{name = "Docker.DockerDesktop"; version = "4.9.0"}, 
    @{name = "Microsoft Terminal"; source = "msstore"; version = "1.13.11432.0" }, 
    @{name = "TeamViewer.TeamViewer.Host" }, 
    @{name = "Microsoft.Teams" }, 
    @{name = "PDFsam.PDFsam" }
);
Foreach ($App in $AppsToInstall) {
    $ListApp = WinGet list $App.name # List the applications currently installed and save them in $ListApp
    if (![String]::Join("", $ListApp).Contains($App.name)) { # If "WinGet List" does NOT contain the app ID in its string then it will install the app
        Write-host "Installing:" $App.name

        If ($null -ne $App.version -and $App.source) { # If your $App has a verison and a source, it will use this to install the application using the specificed version and source
            WinGet install --exact --silent $App.name --source $App.source --version $App.version
            "`n" # Makes space for each install, otherwise there isn't that default spacing between each install
        }

        If ($null -ne $App.version) { # If your $App has a version specificed, it will use this to install the app using the version specified
            WinGet install --exact --silent $App.name --version $App.version
            "`n" # Makes space for each install, otherwise there isn't that default spacing between each install
        }

        If ($null -ne $App.source) { # If your $App has a source, it will use this to install using that source. This is useful for installing a named app from a specific source (etc: msstore)
            WinGet install --exact --silent $App.name --source $App.source
            "`n" # Makes space for each install, otherwise there isn't that default spacing between each install
        }
        
        Else { # Install from here if there isn't a source or version specificed
            WinGet install --exact --silent $App.name
            "`n" # Makes space for each install, otherwise there isn't that default spacing between each install
        }

    } else { # If "WinGet List" has the app name somewhere in its output, then it will skip the installation of that app. This is because the app must be installed if it is being listed with "WinGet List"
        Write-host "Skipping Install of " $App.name -ForegroundColor Green
    }
}







# This script takes your specified applications and saves them as an object named $AppsToInstall
# Then it will pass it through a Foreach loop that will check if the app is already installed, and if not then it will figure out how to install it based on parameters specified.
# This limits down the script so that it is easier to see what apps are being installed and makes it easier to maintain a list of applications.


# If you wish to make the script shorter you can remove the other parameters to only include what you want. So if you only want WinGet installs without source and version parameters, you can make it look like this:
# =====================================================================================================================================================================================================================================
#        Foreach ($App in $AppsToInstall) {
#           $ListApp = WinGet list $App.name # List the applications currently installed and save them in $ListApp
#             if (![String]::Join("", $ListApp).Contains($App.name)) { # If "WinGet List" does NOT contain the app ID in its string then it will install the app
#                 Write-host "Installing:" $App.name
#                 WinGet install --exact --silent $App.name
#                "`n" # Makes space for each install, otherwise there isn't that default spacing between each install
#             } else { # If "WinGet List" has the app name somewhere in its output, then it will skip the installation of that app. This is because the app must be installed if it is being listed with "WinGet List"
#               Write-host "Skipping Install of " $App.name -ForegroundColor Green
#             }
#       }
# =====================================================================================================================================================================================================================================


# Notice how the last app in the install list doesn't have a comma on the end of it, as the comma indicates that another application exists in this object when it shouldn't