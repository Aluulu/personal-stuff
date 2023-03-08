<#
.SYNOPSIS
  This script will add a user into a shared mailbox using the ExchangeOnlineManagement module.
  First the script will prompt for a name. After a user is inputted, it will grab their information using the ActiveDirectory module and display it, letting the Script user decide if this is the correct user.
  Once a user has been selected, it will then ask for input asking for a email address that the user will be added into.
  After that email address has been inputted, it will display relevant information to let the Script user decided if that is the correct.
  With all the information, it will let the Script user decide if they want to continue by requiring them to type "WITH GREAT POWER".
  If accepted, the script will now connect to ExchangeOnline and add the user into the shared mailbox, giving them member status and allowing them to send as that email address.
.DESCRIPTION
  Adds a user into a shared mailbox using the module ExchangeOnlineManagement and ActiveDirectory
.PARAMETER <User>
  $User is the variable that stores the user that will be added into the shared mailbox. It needs to be formatted as "firstname.lastname"
.PARAMETER <EmailAddress>
  #$EmailAddress is the variable that stores the shared email address that the user will be added into. It should be the full address format "email@domain.co.uk"
.INPUTS
  The user you wish to add into the mailbox = $ADUserName
  The shared mailbox you wish to get the user into = $SharedEmailAddress
.OUTPUTS
  Sends an email to both the user and their manager informing them that they've been added to the shared mailbox
.NOTES
  Version:        1.0
  Author:         <Callum Wellard>
  Creation Date:  <28/04/2022>
  Purpose/Change: Initial script development
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

param(
    [Parameter()]
    [String]$User,
    [String]$EmailAddress
)

function parameters {

	if ($User) { # If $User has no value, then it will skip this section. If $User does have a value, it will confirm this is the correct user. If $User doesn't have a value, it will continue the script like normal.
		$ADUserName = $User
		
		CorrectUser
	}

	EnterUserName
}


function EnterUserName {

Write-Host "Please enter the current accounts username used to login" -ForegroundColor Green
Write-Host "An example: To get John Smith's account, if they use type 'john.smith' to login to Windows, use that" -ForegroundColor Green
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
  CorrectUser
}

  Function CorrectUser{

  Try {
    $ExchangeUser = Get-EXOMailbox -Identity $ADUser.mail -properties DisplayName -ErrorAction Stop # Gets the user's email address from the user's name and stores it as $ExchangeUser
    } Catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] {
      Write-Host "WARNING: This user doesn't have a Exchange Online mailbox" -ForegroundColor Red
      Write-Host "This script won't work unless the Exchange module can find the user's mailbox" -ForegroundColor Red
      if ($ADUser.mail -eq "") {
        Write-Host "The user's Active Directory email field is empty. Please input in the user's correct address before running this script again" -ForegroundColor Red
        Exit
      }
    } Catch {
    
    }


$ADUserName_Manager = $ADUser.manager # This grabs the manager parameter from the Active Directory user
$ADUserName_Manager_obj = get-aduser $ADUserName_Manager -Properties * # This stores the properties of the manager
$ADUserName_Manager_name = $ADUserName_Manager_obj.name # This grabs the full display name from the properties we stored above
$ADUserName_ManagerEmail = $ADUserName_Manager_obj.mail # This grabs the manager's email address from the properties we stored above
$ADUserName_FullName = $ADUser.Name
$ADUserName_EmailAddress = $ADUser.Mail

"`n"
"`n"
Write-Host "The user's name is: " $ADUser.name # Writes out the fullname of the user
Write-Host "The user's login is: " $ADUser.SamAccountName # Writes out the login used to sign into the user
Write-Host "The user's title is: " $ADUser.title # Writes out the job title of the user
Write-Host "The user's department is: " $ADUser.Department # Writes out the department the user was in
Write-Host "The email address of the user is" $ADUser.mail # Writes out the email address of the user
Write-Host "The user manager's name is $ADUserName_Manager_name" # Writes the user's manager name
Write-Host "The manager's email address is $ADUserName_ManagerEmail" # Writes out the manager's email address
"`n"

$confirmationCorrectUser = Read-Host "Is this the correct user? (y/n)" 	# This brings up a display allowing the user to ensure they are picking the correct user by displaying the 
if ($confirmationCorrectUser -eq 'y') {									# varirables from the Write-Host above. This makes sure no-one is changed accidently if they share the same name
	EnterSharedEmailAddress
}
else {EnterUserName}


} # End of function CorrectUser

function EnterSharedEmailAddress {
Write-Host "Please enter the shared inbox you would like to add a user into" -ForegroundColor Green
$SharedEmailAddress = read-host 'Enter the general name of the shared inbox'



Try {
$SharedEmailAddress_Obj = Get-EXOMailbox -Anr $SharedEmailAddress -ErrorAction Stop
} Catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] {
  Write-Host "Nothing is matching your search criteia, please try again and refine your search" -ForegroundColor Red
  EnterSharedEmailAddress
} Catch {
  Write-Host "An error has occurried, the error message is as follows:"
  $Error[0].Exception
  $Error[0].Exception.GetType().FullName
}
$SharedEmailAddress_FullAddress = $SharedEmailAddress_Obj | Select-Object -ExpandProperty PrimarySmtpAddress
$SharedEmailAddress_Name = $SharedEmailAddress_Obj | Select-Object -ExpandProperty DisplayName

if ($SharedEmailAddress_Obj -is [array]) { # If the second object in the array isn't clear then it means multiple email addresses were found
  "`n"
  Write-Host "There are multiple addresses that fit your search criteria, please type out the one you wish to select"
  $SharedEmailAddress_FullAddress
  "`n"
  EnterSharedEmailAddress
}


"`n"
if ($null -eq $SharedEmailAddress_Obj) {
  Write-Host "There are no mailboxes that match your search critera, please refine your search" -ForegroundColor Red
  EnterSharedEmailAddress
}
Write-Host "The Shared mailbox's name is $SharedEmailAddress_Name" # Writes out the fullname of the shared mailbox
Write-Host "The Shared mailbox's full email address is $SharedEmailAddress_FullAddress" # Writes out the primary email address of the shared mailbox
"`n"
CorrectSharedEmailAddress
}

function CorrectSharedEmailAddress {
$confirmationCorrectSharedEmailAddress = Read-Host "Is this the correct shared inbox? (y/n)" 	# This brings up a display allowing the user to ensure they are picking the correct user by displaying the 
if ($confirmationCorrectSharedEmailAddress -eq 'y') {											# varirables from the Write-Host above. This makes sure no-one is changed accidently if they share the same name
	VariableConfirmation
}
else {EnterSharedEmailAddress}
}


# =====================================================================================================================================================
function VariableConfirmation {
"`n"

Write-Host "The user" $ADUser.Name "will have access to the shared mailbox $SharedEmailAddress_FullAddress" -ForegroundColor Green

	
$confirmation = Read-Host "Please confirm you would like the above to happen. Please type in all caps 'WITH GREAT POWER'"
if ($confirmation -ceq 'WITH GREAT POWER') {
	execute # This will run the script to execute the changes against Exchange
}
Else {Write-Host "Exiting without making changes."
PAUSE
Exit
}

} # End of function VariableConfirmation
# =====================================================================================================================================================
function Execute{
"`n"
"`n"

Add-MailboxPermission -Identity $SharedEmailAddress_FullAddress -User $ADUserName_EmailAddress -AccessRights FullAccess -InheritanceType All -Confirm:$false
Add-RecipientPermission $SharedEmailAddress_FullAddress -AccessRights SendAs -Trustee $ADUserName_EmailAddress -Confirm:$false
Write-Host "Granting permissions to" $ADUser.Name "to access the email address $SharedEmailAddress_FullAddress"


"`n"
"`n"

# This sends an email to the manager of the leaver informing them that they have been granted access to the leaver's mailbox. This saves any busy work and automates the process for security and logging.
Write-Host "Sending an email to" $ADUser.Name "and $ADUserName_Manager_name informing them that $ADUserName_FullName has been granted access to the shared mailbox."
Send-MailMessage -From helpdesk@markeygroup.co.uk -To $ADUser.Mail -Cc $ADUserName_ManagerEmail -Smtpserver markeygroup-co-uk.mail.protection.outlook.com -Subject "You have been granted access to $SharedEmailAddress_FullAddress" -body "Hello $ADUserName_FullName, `n `nYou have been granted access to the shared mailbox $SharedEmailAddress_FullAddress. `nPlease note that this can take up to 60 minutes to take effect and show up automatically in your Outlook. `nIf you think this is a mistake, please contact the helpdesk at helpdesk@markeygroup.co.uk `n `nA copy of this email has been sent to your manager ($ADUserName_Manager_name). `n `nPlease note that although this is an automatic email, you can respond to this message if you notice anything is incorrect or this action wasn't supposed to happen."


Exit
} #End of function Execute

# =====================================================================================================================================================


# Start the program
parameters # Goes back to parameters to begin the script as the variables needed to be declared first