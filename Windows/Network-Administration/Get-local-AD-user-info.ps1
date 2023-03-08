function EnterUserName {
    # Clear-Variable AdUsername
    Write-Host "Please enter the current accounts username used to login to Windows (SamAccountName)" -ForegroundColor Green
    Write-Host "An example: If John Smith uses 'john.smith' to log into Windows then type 'john.smith'" -ForegroundColor Green
    $ADUserName = read-host 'Enter username'
    FindUser
    } # End of function EnterUserName

Function FindUser {

    $ADUser_Search = Get-AdUser -Filter "SamAccountName -like '*$ADUserName*'" -Properties * -ErrorAction Stop
    
    if ($ADUser_Search -is [array]) { # Checks to see if $ADUser_Search is an array, and if it is then the search result has found multiple profiles with the name that the user specified
        if ($ADUser_Search[0].SamAccountName -eq $AdUserName) {
            Write-Host "A user exists with that log-in name, although you may have been searching for users with the same name" -ForegroundColor Yellow
            $ADUser_Search[0] | Select-Object SamAccountName, Name, Title | Format-Table -Wrap
            "`n"
            $ADUser_Search | Select-Object SamAccountName, Name, Title | Format-Table -Wrap
            "`n"
            $selection = Read-Host "Would you like to select this user? [Y/N]"
            switch ($selection) {
            'Y'
            {
                FilterUsers
            }
            'N'
            {
                EnterUserName
            }
            }
        }
        Write-host "There are multiple user's with that name, please refine your search" -ForegroundColor Yellow
        Write-Host "Use the SamAccountName to specify your chosen user" -ForegroundColor Yellow
        $ADUser_Search | Select-Object SamAccountName, Name, Title | Format-Table -Wrap # Displays all the search results so that the script user can input in the correct name of the user they are searching for
        "`n"
        EnterUserName
    }
    FilterUsers
} # End of function FindUser

Function FilterUsers {
    <#
        This will run if the search result doesn't have multiple results.
        Since each SamAccountName is unique,if the search returns only one result then it must have been the user that the script was searching for

        It will:
        Search for the exact SamAccountName you provide first.
        If it catches an error, it will search for the user using their SamAccountName.
        Then if that doesn't return a result, say as a result of their being nothing that fits the SamAccountName, then it will
        search using names rather than the SAM.
        If both the SamAccountName and the Name results turn up empty, then it will return an error informing that no-one could be found
    #>

    Try {
    $ADUser = Get-AdUser -Identity $ADUserName -Properties * # Gets the user profile and stores it as $ADUser
    } Catch {

        $ADUser = Get-AdUser -Filter "SamAccountName -like '*$ADUserName*'" -Properties * # Gets the user profile and stores it as $ADUser
        if ($null -eq $AdUser) { # This should only catch an error if the search result returns no results
                Write-Host "No user matches your SamAccountName search. Searching using Display Name" -ForegroundColor Yellow
                $ADUser = Get-AdUser -Filter "name -like '*$ADUserName*'" -Properties * # Gets the user profile and stores it as $ADUser
                    if ($null -eq $AdUser) { # This should only catch an error if the search result returns no results
                        Write-Host "No user matches your searches. Please make sure you're typing in the name of the person correctly." -ForegroundColor Red
                        "`n"
                        EnterUserName
                    }
        }

    }

    if (!$null -eq $ADUser.mail) {
        Try {
        $ExchangeUser = Get-EXOMailbox -Identity $ADUser.mail -properties DisplayName -ErrorAction Stop # Gets the user's email address from the user's name and stores it as $ExchangeUser
        } Catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] {
            Write-Host "This user doesn't have a Exchange Online mailbox" -ForegroundColor Red
        } Catch {
        
        }
    }
    
    Try {
        $ADUserName_Manager_obj = get-aduser $ADUser.manager -Properties * -ErrorAction Stop # This stores the properties of the manager
        $ADUserName_Manager_name = $ADUserName_Manager_obj.name # This grabs the full display name from the properties we stored above
        $ADUserName_ManagerEmail = $ADUserName_Manager_obj.mail # This grabs the manager's email address from the properties we stored above
    } Catch [System.Management.Automation.ParameterBindingException] { # System.Management.Automation.ParameterBindingValidationException doesn't work
        
    } Catch {
    
    }

Try {
    $MsolUser = Get-MsolUser -UserPrincipalName $ADUser.mail -ErrorAction Stop
} Catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
    Write-Host "This user doesn't have an account in Azure Active Directory, this may be because their actual email address is not the same as the email set in local Active Directory" -ForegroundColor Red
    Write-Host "Logs: Username being searched in Azure: " $ADUser.mail
} Catch {

}
    $MsolUser = $MsolUser.strongauthenticationmethods | Where-Object IsDefault -eq $true | Select-Object -ExpandProperty Methodtype

    DisplayUserInformation
} # End of function FilterUsers
Function DisplayUserInformation {

    "`n"
    "`n"
    Write-Host "Their name is: " $ADUser.name # Writes out the fullname of the leaver
    if ($null -eq $ADUser.title) {
        Write-Host "They doesn't have a title" -ForegroundColor Yellow
    } Else {
        Write-Host "Their job title is: "$AdUser.title # Writes out the job title of the leaver
    }

    if ($null -eq $ADUser.Department) {
        Write-Host "This user does NOT have a department set" -ForegroundColor Red
    } Else {
        Write-Host "Their department is: " $ADUser.Department # Writes out the department the leaver was in
    }

    if ($null -eq $ADUser.mail) {
        Write-Host "This user does NOT have a mailbox in Active Directory. Please assign one as soon as possible" -ForegroundColor Red
    } Else {
        Write-Host "Their email address is: " $ADUser.Mail # Writes out the email address of the leaver
    }

    if ($null -eq $ADUser.manager) {
        Write-Host "This user doesn't have an assigned manager, please assign one when you can" -ForegroundColor Red
    } Else {
        Write-Host "Their manager's name is $ADUserName_Manager_name" # Writes the leaver's manager name
        Write-Host "The manager's email address is $ADUserName_ManagerEmail" # Writes out the manager's email address
    }
    "`n"
    
    if (!$null -eq $ADUser.mail) {
        $ADUserName_EmailAddress = $ExchangeUser.UserPrincipalName #Sets _EmailAddress as a variable of the leaver's email address
        Try {
            $UserLicenses = Get-MsolUser -UserPrincipalName $ADUserName_EmailAddress | Select-Object -ExpandProperty licenses | Select-Object -Property AccountSkuId | Select-Object -ExpandProperty AccountSkuId -ErrorAction Stop
        } Catch {
            Write-Host "User doesn't have a Microsoft 365 license" -ForegroundColor Yellow
            $UserHasLicense = $False
        }

        if ($UserHasLicense -ne $False) {
            Write-Host "The user has the following licenses:"
            $UserLicenses
        }
    }


    
        "`n"
        Write-Host "Other important information"
        Write-Host "Their SamAccountName is: " $ADUser.SamAccountName # Sets _FullName as a variable of the actual full name of the leaver
        Write-Host "Their UserPrincipalName is: "$ADUser.UserPrincipalName
        Write-Host "Their login script is :" $ADUser.ScriptPath
        Write-Host "Does their password never expire? " $ADUser.PasswordNeverExpires
        Write-Host "Is their account not disabled?: "$ADUser.Enabled
        Write-Host "Their AD location is: " $ADUser.CanonicalName
        Write-Host "Their AD object ID is: " $ADUser.ObjectGUID
        Write-Host "Their AD description is: "$ADUser.Description
        if (!$MsolUser) {
            Write-host "This user does NOT have MFA turned on" -ForegroundColor Red
        } Else {
            Write-Host "Their MFA status is: " $MsolUser
        }
        "`n"
        Write-Host "Their office is :" $ADUser.Office
        Write-Host "Their job title is :" $ADUser.Title
        Write-Host "Their department is :" $ADUser.Department
        Write-Host "Their company is :" $ADUser.Company
        Write-Host "Their street address is :" $ADUser.StreetAddress
        Write-Host "Their city is :" $ADUser.City
        Write-Host "Their post code is :" $ADUser.PostalCode
        Write-Host "Their telephone number is :" $ADUser.telephoneNumber

        "`n"
        "`n"
        Exit
        # There is a weird bug where the script will run multple times if the script has to search for a Active Directory user. This just closes the script before it can attempt to run mulitple times
}

EnterUserName