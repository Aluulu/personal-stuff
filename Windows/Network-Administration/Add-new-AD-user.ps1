function enterUserDetails {
    Write-Host "Please enter the first name of the new user"
    $newUserFirstName = read-host 'Enter first name'

    Write-Host "Please enter the last name of the new user"
    $newUserLastName = read-host 'Enter last name'

    # This is used in the Active Directory Department field. This is important as it shows up in certain places such as selecting a user in Outlook
    Write-Host "Please enter the department of the user (Management/IT/Finance/Factory/Customer Service)"
    $newUserDepartment = read-host 'Enter department'

    # This is used in the Active Directory Department field. This is important as it shows up in certain places such as selecting a user in Outlook
    Write-Host "Please enter a job role for the user (Kitchen Design Surveyor/Customer Service Executive/Accounts Payable)"
    $newUserJobRole = read-host 'Enter a job role'

    # This is used to populate the manager's field in Active Directory. This is important as an email will be sent to this user informing them of the accounts creation.
    Write-Host "Please enter the name of their manager"
    $newUserManager = read-host 'Enter the name of the manager'
    $Manager_obj = Get-ADUser $newUserManager -properties *

    $newUserFirstName_LowerCase = $newUserFirstName.ToLower() # Converts the user's first and last name to lowercase and stores it as a variable
    $newUserLastName_LowerCase = $newUserLastName.ToLower()

    $newUserFirstName_UpperCase = $newUserFirstName.substring(0, 1).toupper() + $newUserFirstName.substring(1).tolower() # Converts the user's first letter of their name to Uppercase and stores it as a variable
    $newUserLastName_UpperCase = $newUserLastName.substring(0, 1).toupper() + $newUserLastName.substring(1).tolower()

    switchCompany # Go to choosing what company the user will be apart of.

} # End of function enterUserDetails


function switchCompany {
    Write-Host "1: Press '1' for Markey Construction."
    Write-Host "2: Press '2' for Markey Building Services."
    Write-Host "3: Press '3' for NutritionX."
    Write-Host "4: Press '4' for Premiere Kitchens."
    Write-Host "5: Press '5' for TPT Holdings"
    $selection = Read-Host "Which company does this user belong to?"
    switch ($selection) {
        '1' {
            "You have chosen Markey Construction"
            $newUserPath = "OU=Users,OU=Markey Builders,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@markeyconstruction.co.uk" # This stores the user's email in the email section of AD 
            $newUserWebpage = "www.markeyconstruction.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886155" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "MCL" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/Markey Builders/Users (Markey Construction)" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "MB_Network-logon.bat" # Sets the logon script as the appropriate companies's logon script

            if ($newUserJobRole -like 'Site Manager') {
                $newUserDepartment = "Site"
            }

        }
        '2' {
            "You have chosen Markey Building Services"
            $newUserPath = "OU=Users,OU=Markey Building Services,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@markeybuildingservices.co.uk" # This stores the user's email in the email section of AD
            $newUserWebpage = "www.markeybuildingservices.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886145" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "MBS" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/Markey Building Services/Users" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "MB_Network-logon.bat" # Sets the logon script as the appropriate companies's logon script

            if ($newUserJobRole -like 'Site Manager') {
                $newUserDepartment = "Site"
            }

        }
        '3' {
            "You have chosen NutritionX"
            $newUserPath = "OU=Users,OU=Nutrition X,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@nutritionx.co.uk" # This stores the user's email in the email section of AD
            $newUserWebpage = "www.nutritionx.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886198" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "Nutrition X" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/Nutrition X/Users" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "PK_Network-logon.bat" # Sets the logon script as the appropriate companies's logon script

        }
        '4' {
            "You have chosen Premiere Kitchens"
            $newUserPath = "OU=Team Delivery,OU=Users,OU=Premiere Kitchens,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@premierefurniture.co.uk" # This stores the user's email in the email section of AD
            $newUserWebpage = "www.premierekitchens.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886100" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "Premiere Kitchens" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/Premiere Kitchens/Users/Team Delivery" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "PK_Network-logon.bat" # Sets the logon script as the appropriate companies's logon script

            if ($newUserJobRole -like 'Survey') {
                # If the user's job title has survey in their job title, their job role and department will be updated to properly match their title.
                $newUserJobRole = "Kitchen Design Surveyor"
                $newUserDepartment = "Surveying"
            }
            if ($newUserJobRole -like 'Customer') {
                # If the user's job title has Customer in their job title, their job role and department will be updated to properly match their title.
                $newUserJobRole = "Customer Service"
                $newUserDepartment = "Customer Service"
            }
            if ($newUserJobRole -like 'Engineer') {
                # If the user's job title has Engineer in their job title, their job role and department will be updated to properly match their title.
                $newUserDepartment = "Engineering"
            }

        }
        '5' {
            "You have chosen TPT Holdings"
            $newUserPath = "OU=Users,OU=TPT Holdings,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@markeygroup.co.uk" # This stores the user's email in the email section of AD
            $newUserWebpage = "www.markeygroup.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886146" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "Test Company" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/TPT Holdings/Users" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "login.vbs" # Sets the logon script as the appropriate companies's logon script

            if ($newUserJobRole -like 'People') {
                $newUserDepartment = "People Services"
            }

            if ($newUserJobRole -like 'Account') {
                $newUserDepartment = "Accounts Payable"
            }

            if ($newUserJobRole -like 'Finance') {
                $newUserDepartment = "Finance"
            }

        }
        'T' {
            "You have chosen Test User"
            $newUserPath = "OU=Users,OU=Test Office365 Accounts,OU=Gloucester,DC=tptholdings,DC=co,DC=UK" # This is the location of the user.
            $newUserEmailAddress = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@testemail.co.uk" # This stores the user's email in the email section of AD
            $newUserWebpage = "www.testwebsite.co.uk" # Sets the user's Web page as the companies website
            $newUserTelephoneNumber = "01452 886146" # Sets the user's telephone number as the companies phone number. This should be changed afterwards if the user has a work phone num
            $newUserCompany = "Test Company" # Sets the Organisation company as the user's company name
            $newUserPath_readableText = "Gloucester/Test Office365 Accounts/Users" # This is used to display where the user will be stored. This is only for the Script User, it won't be used at all in the execution
            $newUserLogonScript = "Test-Script.bat" # Sets the logon script as the appropriate companies's logon script

        }

    }
    applyGroupToUser
} # End of function switchCompany

function applyGroupToUser {
    if ($hasUserBeenCreated) {
        # If User has been created, run this part of the script

        $createdADUser = get-aduser -Identity "$newUserFirstName_UpperCase.$newUserLastName_UpperCase" # Grabs the Active Directory user and stores it in a variable for easy adding to groups

        # All users will be in these groups
        Write-Host "Applying groups to $newUserFirstName_UpperCase"
        Start-Sleep -Seconds 3

        Add-ADGroupMember -Identity "All Employees" -Members "$createdADUser"
        Add-ADGroupMember -Identity "All Employees - Q1" -Members "$createdADUser"
        Add-ADGroupMember -Identity "IKEv2" -Members "$createdADUser"
        Add-ADGroupMember -Identity "IKEv2-Users" -Members "$createdADUser"
        Add-ADGroupMember -Identity "L2TP-Users" -Members "$createdADUser"
        Add-ADGroupMember -Identity "IT Tips" -Members "$createdADUser"
        Add-ADGroupMember -Identity "MarkeyGroup" -Members "$createdADUser"
        Add-ADGroupMember -Identity "MarkeyGroup2" -Members "$createdADUser"
        Add-ADGroupMember -Identity "PaperCut" -Members "$createdADUser"
        Add-ADGroupMember -Identity "Users" -Members "$createdADUser"

        switch ($selection) {
            '1' {
                # Markey Construction

                Add-ADGroupMember -Identity "All Employees - MCL & MBS" -Members "$createdADUser"
                Add-ADGroupMember -Identity "All Employees - MBS" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Markey Builders" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Remote Apps - MCL" -Members "$createdADUser"
            }
            '2' {
                # Markey Building Services'
                Add-ADGroupMember -Identity "All Employees - MCL" -Members "$createdADUser"
                Add-ADGroupMember -Identity "All Employees - MCL & MBS" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Markey Building Services" -Members "$createdADUser"
            }
            '3' {
                # Nutrition X'
                Add-ADGroupMember -Identity "All Employees - Nutrition X" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Remote Apps - NutritionX" -Members "$createdADUser"
            }
            '4' {
                # Premiere Kitchens
                Add-ADGroupMember -Identity "All Employees - Premiere" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Premiere - All Staff" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Premiere Kitchens" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Team Delivery Wallpaper" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Remote Apps - PK" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Remote Apps - PK ArtiCAD" -Members "$createdADUser"
                Add-ADGroupMember -Identity "Remote Apps - PK BDM" -Members "$createdADUser"

                if ($newUserDepartment -eq "Surveying") {
                    Add-ADGroupMember -Identity "Premiere - Remote Surveying" -Members "$createdADUser"
                    Add-ADGroupMember -Identity "Premiere - Surveyor Files" -Members "$createdADUser"
                    Add-ADGroupMember -Identity "Premiere - Surveyor Pictures" -Members "$createdADUser"
                }
            }
            '5' {
                # TPT Holdings
                Add-ADGroupMember -Identity "All Employees - Group Services" -Members "$createdADUser"

                if ($newUserDepartment -eq "People Services") {
                    Add-ADGroupMember -Identity "Group - HR" -Members "$createdADUser"
                    Add-ADGroupMember -Identity "HR - Factory" -Members "$createdADUser"
                    Add-ADGroupMember -Identity "HR_Department" -Members "$createdADUser"
                }

                if ($newUserDepartment -eq "Finance") {
                    Add-ADGroupMember -Identity "Finance" -Members "$createdADUser"
                }
            }
            'T' {
                # Test Account
                Add-ADGroupMember -Identity "All Employees - MCL" -Members "$createdADUser"
                Add-ADGroupMember -Identity "All Employees - MCL & MBS" -Members "$createdADUser"
            }
        }
        Write-Host "Successfully added groups to the user" -ForegroundColor Green
        "`n"
        Admin365Settings
        # Write-Host "Script has finished" -ForegroundColor Green
        # Write-Host "Make sure to change the user's domain name on Microsoft 365 and then apply them a license" -ForegroundColor Green
        PAUSE
    }
    else {
        # If the script hasn't been to the createUser function then it will run this, which will write out what the user will be added to
        $userGroups_AllReadable = "
        All Employees - All
        ALL Employees - Q1 Based
        Ikev2
        IKEv2-Users
        L2TP-Users
        IT Tips
        MarkeyGroup
        MarkeyGroup2
        PaperCut
        Users"

        switch ($selection) {
            '1' {
                # Markey Construction
                $userGroups_SpecificReadable = "
                All Employees - MCL
                All Employees - MCL & MBS
                All Employees - MBS
                Markey Builders
                Markey Building Services
                Remote Apps - MCL"
            }
            '2' {
                # Markey Building Services
                $userGroups_SpecificReadable = "
                All Employees - MCL
                All Employees - MCL & MBS
                Markey Building Services"
            }
            '3' {
                # Nutrition X'
                $userGroups_SpecificReadable = "
                All Employees - Nutrition X
                Remote Apps - Nutrition X"
            }
            '4' {
                # Premiere Kitchens
                $userGroups_SpecificReadable = "
                All Employees - PK
                Premiere - All Staff
                Premiere Kitchens
                Team Delivery Wallpaper
                Remote Apps - PK
                Remote Apps - PK ArtiCAD
                Remote Apps - PK BDM"

                if ($newUserDepartment -eq "Surveying") {
                    Write-Host "Premiere - Remote Surveying"
                    Write-Host "Premiere - Surveyor Files"
                    Write-Host "Premiere - Surveyor Pictures"
                }
            }
            '5' {
                # TPT Holdings
                $userGroups_SpecificReadable = "
                All Employees - Group Services"

                if ($newUserDepartment -eq "People Services") {
                    Write-Host "Group - HR"
                    Write-Host "HR - Factory"
                    Write-Host "HR_Department"
                }

                if ($newUserDepartment -eq "Finance") {
                    Write-Host "Finance"
                }
            }
            'T' {
                # Test Account
                $userGroups_SpecificReadable = "
                All Employees - MCL
                All Employees - MCL & MBS"
            }
        }

        createUser_confirmation
    }
} # End of function applyGroupToUser




function createUser_confirmation {
    # This will write out the parameters for the Script User so they know what they are creating
    "`n"
    "`n"
    Write-Host "Creating an account with the following parameters" -ForegroundColor Green
    Write-Host "The user's name is '$newUserFirstName_UpperCase $newUserLastName_UpperCase'"
    "`n"
    Write-Host "They are going to be stored in '$newUserPath_readableText'"
    Write-Host "The email address for this user is '$newUserEmailAddress'"
    Write-Host "The account is going to be enabled"
    "`n"
    Write-Host "The title of the user is '$newUserJobRole'"
    Write-Host "Their department is '$newUserDepartment'"
    Write-Host "Their company is '$newUserCompany'"
    Write-Host "Their manager is: " $Manager_obj.Name
    Write-Host "The user's address is 'Unit Q1, Quadrant Distribution Centre, Quadrant Way, Hardwicke'"
    Write-Host "The city is 'Gloucester'"
    Write-Host "The postal address is 'GL2 2RN'"
    Write-Host "Setting the country as 'United Kingdom'"
    Write-Host "The webpage is '$newUserWebpage'"
    "`n"
    Write-Host "Setting the script path to '$newUserLogonScript'"
    Write-Host "The password will not expire"
    Write-Host "The phone number is '$newUserTelephoneNumber'"
    "`n"
    Write-Host "User will be added to: $userGroups_AllReadable"
    Write-Host "User will also be added to: $userGroups_SpecificReadable"



    "`n"
    "`n"
    # Prompts a confirmation request to confirm that everything so far will be executed
    $confirmation = Read-Host "Please confirm you would like the above to happen. Please type in all caps 'WITH GREAT POWER'" # Requires that the Script User type the following command to execute the script
    if ($confirmation -ceq 'WITH GREAT POWER') {
        createUser
    }
    Else {
        Write-Host "Exiting without making changes."
        PAUSE
        Exit
    }
} # End of function createUser_confirmation



function createUser {
# This function actually creates the user and all of their properties in Active Directory
    Try {
    New-ADUser `
        -Name "$newUserFirstName_UpperCase $newUserLastName_UpperCase" `
        -GivenName "$newUserFirstName_UpperCase" `
        -Surname "$newUserLastName_UpperCase" `
        -DisplayName "$newUserFirstName_UpperCase $newUserLastName_UpperCase" `
        -SamAccountName "$newUserFirstName_LowerCase.$newUserLastName_LowerCase" `
        -UserPrincipalName "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@tptholdings.co.uk" `
        -Path "$newUserPath" `
        -Accountpassword (Read-Host -AsSecureString "AccountPassword") `
        -Enabled $true `
        -EmailAddress "$newUserEmailAddress" `
        -Homepage "$newUserWebpage" `
        -Description "$newUserJobRole" `
        -Office "Q1, Hardwicke" `
        -Title "$newUserJobRole" `
        -Department "$newUserDepartment" `
        -Company "$newUserCompany" `
        -Manager "$newUserManager" `
        -StreetAddress "Unit Q1, Quadrant Distribution Centre, Quadrant Way, Hardwicke" `
        -City "Gloucester" `
        -PostalCode "GL2 2RN" `
        -ScriptPath "login.vbs" ` # -ScriptPath "$newUserLogonScript" `
        -PasswordNeverExpires $True `
        -Country "GB" `
        -OtherAttributes @{'telephoneNumber' = $newUserTelephoneNumber }
        -ErrorAction Stop
    } Catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
        Write-Host "This user already exists. Exiting Script to prevent groups from being added"
        Exit-PSHostProcess
    } Catch {

    }

    Write-Host "The account has been created" -ForegroundColor Green
    Start-Sleep -Seconds 1 # Gives time for the account to be created before applying groups. It is inconsistent if it will work or not without this small pause
    $hasUserBeenCreated = $True
    applyGroupToUser

} # End of function createUser




Function Admin365Settings {

#Check licenses
$Licenses = Get-MsolAccountSku



#Microsoft 365 Premium licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*SPB*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*SPB*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Premium licenses left" -ForegroundColor Red
    Write-Host "The total number of Premium licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Premium licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total number of Premium licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}
"`n"

# Microsoft 365 Standard licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_PREMIUM*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_PREMIUM*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Standard licenses left" -ForegroundColor Red
    Write-Host "The total number of Standard licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total number of we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Standard licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total Standard licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}
"`n"

# Microsoft 365 Essential licenses
$Licenses_TotalAmount = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS*"} | Select-Object -ExpandProperty ActiveUnits # Total licenses we have available
$Licenses_CurrentlyUsing = $Licenses | Where-Object {$_.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS*"} | Select-Object -ExpandProperty ConsumedUnits # Total licenses we are using

$Licenses_Available = $Licenses_TotalAmount - $Licenses_CurrentlyUsing
If ($Licenses_Available -eq "0") {
    Write-Host "There are no Microsoft 365 Essential licenses left" -ForegroundColor Red
    Write-Host "The total number of Essential licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
} Else {
    Write-Host "There are $Licenses_Available Microsoft 365 Essential licenses available to be assigned" -ForegroundColor Green
    Write-Host "The total number of Essential licenses we have are: " $Licenses_TotalAmount
    Write-Host "The total we are using are: " $Licenses_CurrentlyUsing
}

    $AssignALicense = Read-Host "Would you like to assign the user a license?"
    "`n"
    switch($AssignALicense) {
        'Y' {
            $DoNotAssignALicense = $false

            Write-Host "Please select a license you'd like to apply them with:"
            Write-Host "1) Microsoft 365 Essentials"
            Write-Host "2) Microsoft 365 Standard"
            Write-Host "3) Microsoft 365 Premium"
            $ChooseLicense = Read-Host "What license would you like to apply?"
            switch($ChooseLicense){
                '1' {
                    $LicenseToApply = "markeygroup:O365_BUSINESS_ESSENTIALS" # Essentials
                } '2' {
                    $LicenseToApply = "markeygroup:O365_BUSINESS_PREMIUM" # Standard
                } '3' {
                    $LicenseToApply = "markeygroup:SPB" # Premium
                }
            }
        }
        'N' {
            $DoNotAssignALicense = $true
            Write-Host "Skipping assigning a license"
        }
    }

    if ($DoNotAssignALicense -eq $false) {

    Write-Host "Please wait 35 minutes for the directory to sync with Azure."
    Write-Host "It will be ready at: "
    $CurrentTime = Get-Date
    $CurrentTime.addminutes(35)

    # Wait 35 minutes then do these
    Start-Sleep -Seconds 2100

    $OldEmailDomain = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase@tptholdings.co.uk"
    Write-Host "Setting domain name from $newUserFirstName_LowerCase.$newUserLastName_LowerCase@tptholdings.co.uk to $newUserEmailAddress"
    set-msoluserprincipalname -newuserprincipalname $newUserEmailAddress -userprincipalname $OldEmailDomain
    Write-Host "Waiting 60 seconds to apply the domain name change"
    Start-Sleep -Seconds 60

    Set-MsolUser -UserPrincipalName $newUserEmailAddress -UsageLocation "GB" # This is required as licenses require the UsageLocation to be set. MUST BE AFTER THE DOMAIN NAME CHANGE AS IT NEEDS THE DOMAIN NAME TO BE CORRECT!
    Write-Host "Changing the user's location to United Kingdom so that the licenses can be applied"
    Start-Sleep -Seconds 10 # Gives time for the changes to apply


    if ($DoNotAssignALicense -eq $false) {

        Try {
            Set-MsolUserLicense -UserPrincipalName "$newUserEmailAddress" -AddLicenses $LicenseToApply # Assigns a Business Standard license
            Write-Host "Allowing 5 minutes for the mailbox to be created"
            Start-Sleep -Seconds 300 # Gives the mailbox time to create

            $newUserSAMAccountName = "$newUserFirstName_LowerCase.$newUserLastName_LowerCase"
            $ADUser = get-aduser $newUserSAMAccountName -Properties *
            $ADUserName_Manager = $ADUser.manager
            $ADUserName_Manager_obj = get-aduser $ADUserName_Manager -Properties *
            $ADUserName_ManagerEmail = $ADUserName_Manager_obj.mail # This grabs the manager's email address from the properties we stored above

            # Sends an email to the new person's manager informing them that the mailbox has been set up
            Send-MailMessage -from helpdesk@markeygroup.co.uk -Subject "$newUserFirstName_UpperCase $newUserLastName_UpperCase mailbox" -to $ADUserName_ManagerEmail -Cc $newUserEmailAddress -smtpserver markeygroup-co-uk.mail.protection.outlook.com -body "Hello, `n `nThe mailbox for $newUserFirstName_UpperCase $newUserLastName_UpperCase has been created. Their email address is: $newUserEmailAddress. `n `nTheir email has been CC'ed for convience. `n `nNote: This is an automatic email, however you can respond to this message if you notice anything is incorrect or this action wasn't supposed to happen."

            $HTMLBody =
@"
Hello <br><br>
The link to our Internal Phone List can be found here: <a href=https://markeygroup.sharepoint.com/:x:/r/sites/InformationTechnology/Shared%20Documents/Gereral%20Information/Internal%20Phone%20List.xlsx?d=w89d80485add34c4a8f454bcf52814206&csf=1&web=1&e=UyEEz2>Internal Phone List.xlsm</a> <br><br>
Feel free to bookmark the site for easy access. <br><br>
Note: This is an automatic email, however you can respond to this message if you notice anything is incorrect or this action wasn't supposed to happen."
"@
            # Sends an email to the user's mailbox with the link to the Internal Phone List
            Send-MailMessage -from helpdesk@markeygroup.co.uk -Subject "Internal Phone List" -to $newUserEmailAddress -smtpserver markeygroup-co-uk.mail.protection.outlook.com -BodyAsHTML -body $HTMLBody

            } Catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
                Write-Host "A Microsoft Online error has occurried. The error message is as follows: "
                $Error[0].Exception
                $Error[0].Exception.GetType().FullName
            } Catch {
                Write-Host "An error occurred. The error message is:"
                $Error[0].Exception
                $Error[0].Exception.GetType().FullName
            }
            "`n"
        } Else {
            Write-Host "Skipping assigning license due to user input"
        }
        Write-Host "Script has finished its operation" -ForegroundColor Green
        PAUSE
    }
}# End of Function Admin365Settings

enterUserDetails