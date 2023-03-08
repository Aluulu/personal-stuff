<#
.SYNOPSIS
  This script allows you to search Active Directory for users and then mark them as unlocked.
.DESCRIPTION
  Grabs an Active Directory account, displays their details, and allows the user to mark them as unlocked.
.PARAMETER <User>
  $User is the variable that stores the user that the script will affect. It needs to be formatted as "firstname.lastname"
.INPUTS
  The user you wish to unlock = $User
.NOTES
  Version:        1.0.0
  Author:         <Callum Wellard>
  Creation Date:  <16/05/2022>
.EXAMPLE
  .\Unlock-AD-Account.ps1 -User john.smith
#>

param(
    [Parameter()]
    [String]$User
)

function parameters {

	if ($User) { # If $User has no value, then it will skip this section. If $User does have a value, it will skip asking what the user's name is and go straight to confirming if it is the correct user
		$ADUserName = $User
		DisplayUser
	}

	EnterUserName
}


function StartofScript {
  $SearchForLockedAccounts = Search-ADAccount -LockedOut | Format-Table Name, ObjectClass -A
  if ($null -eq $SearchForLockedAccounts) {
    Write-Host "There are no locked out accounts, are you sure someone is locked out?" -ForegroundColor Red
    Write-Host "Do you want to continue anyway?"
    $NoLockedOutUsersContinueAnyway = Read-Host "Y/N?"
    switch ($NoLockedOutUsersContinueAnyway) {
      'Y' {
        parameters
      }
      'N' {
        Exit 0
      }
    }
  }
  Else {
    Write-host "The full list of locked out users are:"
    Search-ADAccount -LockedOut | Format-Table Name, LockedOut, SamAccountName -A
    parameters
  }
}

function EnterUserName {
    Write-Host "Please enter the current accounts username used to login so that it matches the SamAccountName" -ForegroundColor Green
    Write-Host "An example: To get John Smith's account, type john.smith" -ForegroundColor Green
    $ADUserName = read-host 'Enter username'
    DisplayUser
} # End of function EnterUserName


function DisplayUser {

    Try { # The try function will try to run the following code, and then catch any errors. 
        $ADUser = get-aduser $ADUserName -Properties * -ErrorAction Stop # Gets the user profile and stores it as $ADUser
        $ExchangeUser = Get-EXOMailbox -Identity $ADUserName -ErrorAction Stop # Gets the user's email address from the user's name and stores it as $ExchangeUser
    } Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] { # Catches if the user you inputted doesn't exist
        Write-Host "This user doesn't exist, are you sure you entered their name in correctly?" -ForegroundColor Red
        Write-Host "Make sure to write their name exactly as it appears as their login name." -ForegroundColor Yellow
        Write-Host "Also be sure to note if their name is a shorthand, for example 'Michael' instead of 'Mike'" -ForegroundColor Yellow
        "`n"
        EnterUserName
    } Catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] { # If the user's mailbox doesn't exist, then catch the error and execute the code below
        $ADUserDoesntHaveExchangeMailbox = $true
        Write-Host "Unable to get the user's mailbox from Exchange, the user may not have a mailbox on Exchange" -ForegroundColor Yellow
    } Catch { # If an error that's not getting the user's mailbox, then the script will exit.
        Write-Host "An unknown error has occuried regarding getting the user's exchange Mailbox. Because of this, the script is exiting." -ForegroundColor Red
        "`n"
        Write-Host $error.FullyQualifiedErrorId # Writes out the error message for easier troubleshooting
        Pause
        Exit-PSHostProcess
    } finally {
        # This will run the following code even if an error is caught.
    }


    $ADUserName_FullName = $ADUser.name # Sets _FullName as a variable of the actual full name of the leaver
    $ADUserName_Title = $ADUser.title # Sets _Title as a variable of the title of the leaver
    $ADUserName_Department = $ADUser.department # Sets _Department as a variable of the department of the leaver
    $ADUserName_EmailAddress = $ExchangeUser.UserPrincipalName #Sets _EmailAddress as a variable of the leaver's email address
    $ADUserName_LockedOut = $AdUser.LockedOut # Sets _LockedOut as a true/false variable. If true, the user is locked out. If false, the user is not locked out.

    try {
      $ADUserName_Manager = $ADUser.manager # This grabs the manager parameter from the Active Directory leaver
      $ADUserName_Manager_obj = get-aduser $ADUserName_Manager -Properties * # This stores the properties of the manager
      $ADUserName_Manager_name = $ADUserName_Manager_obj.name # This grabs the full display name from the properties we stored above
      $ADUserName_ManagerEmail = $ADUserName_Manager_obj.mail # This grabs the manager's email address from the properties we stored above
    } catch { # If the code is unable to get the user's name or email address, then it will skip displaying the managers name and email address.
      Write-Host "Unable to grab user's manager infomation. Does this user have an assigned manager?" -ForegroundColor Yellow
      $ADUserDoesntHaveManager = $True
    } finally {
        # This will run the following code even if an error is caught.
    }

    "`n"
    "`n"
    Write-Host "The User's name is $ADUserName_FullName" # Writes out the fullname of the leaver
    Write-Host "The User's title is $ADUserName_Title" # Writes out the job title of the leaver
    Write-Host "The User's department is $ADUserName_Department" # Writes out the department the leaver was in

    if ( $ADUserName_EmailAddress ) { # If the variables has content then execute the following code
        Write-Host "The email address is $ADUserName_EmailAddress" # Writes out the email address of the leaver
    }
    else {
        Write-Host "User may not have Exchange Mailbox" -ForegroundColor Red
    }

    if ( $ADUserDoesntHaveManager -eq $False ) { # If the variable doesn't have content then execute the following code. This happens if the try, catch, finally code catches an error with getting manager information
      Write-Host "The manager's name is $ADUserName_Manager_name" # Writes the leaver's manager name
      Write-Host "The manager's email address is $ADUserName_ManagerEmail" # Writes out the manager's email address
    }
    "`n"

    if ( $ADUserName_LockedOut ) {
        Write-Host "$ADUserName_FullName is currently locked out" -ForegroundColor Green
    }
    else {
        Write-Host "$ADUserName_FullName is currently NOT locked out" -ForegroundColor Red
        Write-Host "Are you sure this is the correct user?"
    }

    $AccountLockoutTime = Get-ADUser -identity $ADUser -Properties lockoutTime | Select-Object -ExpandProperty lockoutTime
    $AccountLockoutTime_Readable = w32tm.exe /ntte $AccountLockoutTime
    Write-Host "The account was locked at this time: "$AccountLockoutTime_Readable.SubString(26)

    "`n"
    CorrectUser

} # End of function DisplayUser

function CorrectUser {
    $confirmationCorrectUser = Read-Host "Is this the correct user? (y/n)" 	# This brings up a display allowing the user to ensure they are picking the correct user by displaying the 
    if ($confirmationCorrectUser -eq 'y') { # varirables from the Write-Host above. This makes sure no-one is changed accidently if they share the same name
        UnlockTheAccount
    }
    else {EnterUserName}
} # End of function CorrectUser


function UnlockTheAccount {
  try {
    Unlock-ADAccount -Identity $ADUserName
    Write-Host "Unlocking the account $ADUserName_FullName" -ForegroundColor Green
  } catch {
    Write-Host "An error has occuried, so the script is exiting. Please see the error message below for details" -ForegroundColor Red
    Write-Host $error.FullyQualifiedErrorId
  } finally {
    Write-Host "Checking to see if the script has successfully completed its operation"
    CheckForUsers
  }
}

function CheckForUsers {
  $SearchForLockedAccounts = Search-ADAccount -LockedOut | Format-Table Name, ObjectClass -A
  if ($null -eq $SearchForLockedAccounts) {
  Write-Host "There are no more accounts locked out, the script has successfully unlocked their account" -ForegroundColor Green
  } Else {
    $SearchForLockedAccounts = Search-ADAccount -LockedOut | Select-Object -ExpandProperty Name
    $HasUserBeenUnlocked = $SearchForLockedAccounts.Contains($ADUserName)
    if ($HasUserBeenUnlocked -eq $false) {
      Write-Host "The user has been unlocked successfully!" -ForegroundColor Green
      Write-Host "However, there are other accounts to be unlocked. Would you like to unlock them?"
      $OtherUsersAreLockedOutContinueToUnlock = Read-Host "Y/N?"
      switch ($OtherUsersAreLockedOutContinueToUnlock) {
        'Y' {
          "`n"
          parameters
        }
        'N' {
          Exit 0
        } # N Switch
      } #Switch
    } # Check if the user has been unlocked If Statement
  } # Else Statement 
} # End of function CheckForUsers

StartofScript