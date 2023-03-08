<#
.SYNOPSIS
  This script will allow the Script User to make choices regarding how to mark a user as a leaver using the Actice Directory and ExchangeOnlineManagement modules.
  First the script will prompt for a name. After a user is inputted, it will grab their information using the two modules and display it, letting the Script user decide if this is the correct user.
  Once a user has been selected, it will then prompt you with multiple choices regarding how you want to mark the chosen user as a leaver.
  With all the information set in variables, it will let the Script user decide if they want to continue by requiring them to type "WITH GREAT POWER".
  If accepted, the script will now connect to ActiveDirectory and ExchangeOnline to perform the choices the user has chosen.
.DESCRIPTION
  Adds a user into a shared mailbox using the module ExchangeOnlineManagement and ActiveDirectory
.PARAMETER <User>
  $User is the variable that stores the user that the script will affect. It needs to be formatted as "firstname.lastname"
.INPUTS
  The user you wish to mark as a leaver = $ADUserName
.OUTPUTS
  If chosen, it will send an email to the leaver's manager informing them that they've been added to the shared mailbox.
.NOTES
  Version:        1.0
  Author:         <Callum Wellard>
  Creation Date:  <28/04/2022>
.EXAMPLE
  .\Leavers-in-ActiveDirectory-&-Exchange.ps1 -User john.smith
#>

param(
    [Parameter()]
    [String]$User
)

function parameters {

	$CurrentTime = $(get-date -f dd-MM-yyyy-HHmm)

	Start-Transcript -Path "\\mg-fileserver1\markey sys\APPLIC\INFORMATION TECHNOLOGY\Active Directory leavers log\$CurrentTime.log"
	$error.Clear() # Clears the current error cache so that it starts the script with an empty array.

	if ($User) { # If $User has no value, then it will skip this section. If $User does have a value, it will skip confirmation and go straight to confirming what to do
		$ADUserName = $User
		GetUserFromAD
	}

	EnterUserName
}





function EnterUserName {
Write-Host "Please enter the current accounts username used to login (PLEASE USE LOWERCASE)" -ForegroundColor Green
Write-Host "An example: To get John Smith's account, type john.smith" -ForegroundColor Green
$ADUserName = read-host 'Enter username'
GetUserFromAD
} # End of function EnterUserName

Function GetUserFromAD {

Try {
	$ADUser = get-aduser $ADUserName -Properties * -ErrorAction Stop # Gets the user profile and stores it as $ADUser
} Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
	Write-Host "This user doesn't exist, please search for another user" -ForegroundColor Red
	EnterUserName
} Catch {

}

Try {
$ExchangeUser = Get-EXOMailbox -Identity $ADUserName -properties DisplayName -ErrorAction Stop # Gets the user's email address from the user's name and stores it as $ExchangeUser
} Catch [Microsoft.Exchange.Management.RestApiClient.RestClientException] {
	Write-Host "This user doesn't have a Exchange Online mailbox"
} Catch {

}

$ADUserName_FullName = $ADUser.name # Sets _FullName as a variable of the actual full name of the leaver
$ADUserName_Title = $ADUser.title # Sets _Title as a variable of the title of the leaver
$ADUserName_Department = $ADUser.department # Sets _Department as a variable of the department of the leaver
$ADUserName_EmailAddress = $ExchangeUser.UserPrincipalName #Sets _EmailAddress as a variable of the leaver's email address

$ADUserName_Manager = $ADUser.manager # This grabs the manager parameter from the Active Directory leaver
Try {
	$ADUserName_Manager_obj = get-aduser $ADUserName_Manager -Properties * -ErrorAction Stop # This stores the properties of the manager
} Catch [System.Management.Automation.ParameterBindingException] { # System.Management.Automation.ParameterBindingValidationException doesn't work
	$UserDoesntHaveManager = $true
	Write-Host "User doesn't have an assigned manager, please assign one when you can"
} Catch {

}

$ADUserName_Manager_name = $ADUserName_Manager_obj.name # This grabs the full display name from the properties we stored above
$ADUserName_ManagerEmail = $ADUserName_Manager_obj.mail # This grabs the manager's email address from the properties we stored above


"`n"
"`n"
Write-Host "The leaver's name is $ADUserName_FullName" # Writes out the fullname of the leaver
if ($ADUserName_Title -eq "") {
	Write-Host "The user doesn't have a title" -ForegroundColor Yellow
} Else {
	Write-Host "The leaver's title was $ADUserName_Title" # Writes out the job title of the leaver
}
Write-Host "The leaver's department was $ADUserName_Department" # Writes out the department the leaver was in
Write-Host "The email address of the leaver is $ADUserName_EmailAddress" # Writes out the email address of the leaver

if ($UserDoesntHaveManager -eq $true) {
	Write-Host "This user does not have a manager assigned" -ForegroundColor Red
} Else {
	Write-Host "The leavers manager's name is $ADUserName_Manager_name" # Writes the leaver's manager name
	Write-Host "The manager's email address is $ADUserName_ManagerEmail" # Writes out the manager's email address
}
"`n"

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
	"`n"

CorrectUser
} # End of function GetUserFromAD




function CorrectUser {
$confirmationCorrectUser = Read-Host "Is this the correct user? (y/n)" 	# This brings up a display allowing the user to ensure they are picking the correct user by displaying the 
if ($confirmationCorrectUser -eq 'y') {									# varirables from the Write-Host above. This makes sure no-one is changed accidently if they share the same name
	variables
}
else {EnterUserName}


} # End of function CorrectUser


function Variables{
"`n"
"`n"

$Choice_RenameToLeaver = 0						# Declares the varirables used in option-selecting what will happen to the leaver's account.
$Choice_ConvertToShared = 0						# They are declared so that they are not null, and they are set to not be active by default
$Choice_GiveManagerSendOnBehalfPerms = 0
$Choice_HideAddressFromGAL = 0
$Choice_DisableOnActiveDirectory = 0


Write-Host "==========================================================================="
$confirmationRename = Read-Host "Would you like to rename '$ADUserName' to 'Leaver - $ADUserName'? (y/n)"
if ($confirmationRename -eq 'y') {
	$Choice_RenameToLeaver = 1
}

$confirmationConvertToShared = Read-Host "Would you like to convert the mailbox '$ADUserName_EmailAddress' to a shared mailbox? (y/n)"
if ($confirmationConvertToShared -eq 'y') {
	$Choice_ConvertToShared = 1

	$confirmationSendOnBehalfPerm = Read-Host "Would you like to give the manager SendOnBehalf permissions (y/n)"
	if ($confirmationSendOnBehalfPerm -eq 'y') {
		$Choice_GiveManagerSendOnBehalfPerms = 1
	}
}

$confirmationHideFromGAL = Read-Host "Would you like to hide the address from the Global Address list (y/n)"
if ($confirmationHideFromGAL -eq 'y') {
	$Choice_HideAddressFromGAL = 1
}

$confirmationDisableFromAD = Read-Host "Would you like to disable the account on Active Directory? (y/n)"
if ($confirmationDisableFromAD -eq 'y') {
	$Choice_DisableOnActiveDirectory = 1
}

$confirmationRemoveLicense = Read-Host "Would you like to remove their Microsoft 365 licenses? (y/n)"
if ($confirmationRemoveLicense -eq 'y') {
	$Choice_RemoveLicense = 1
}

VariableConfirmation

} # End of function Variables 



# =====================================================================================================================================================
function VariableConfirmation {
"`n"

	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#GGGGGB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGPG#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#GGGGGGGGGGPB@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@BPGGGGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGGGGGGPG#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#GPGGGGGGGGGGGGGGGGGB@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@BGGGGGGGGGG5PGGGGGGGGPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&BPGGGGGGGGG? ~PGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGG!   :YGGGGGGGGGG#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#GGGGGGGGGGP^     .?GGGGGGGGGPB@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@BPGGGGGGGGGY:        !GGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGG?           ^5GGGGGGGGPG#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGG!   ~J5P5Y?^  .YGGGGGGGGGPB@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#GGGGGGGGGGP^   5@@@@@@@@J   ?GGGGGGGGGPB&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@@@BPGGGGGGGGGY:   .&@@@@@@@@&.   !PGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGGJ.    .#@@@@@@@@#.    :5GGGGGGGGGG#@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@@#GPGGGGGGGGG7       G@@@@@@@@B      .JGGGGGGGGGPB@@@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@@@BGGGGGGGGGGP~        5@@@@@@@@G        7GGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@@&BPGGGGGGGGGY:         J@@@@@@@@5         ~PGGGGGGGGPG#@@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@@&GPGGGGGGGGGJ.          7@@@@@@@@J          :YGGGGGGGGGPB@@@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@@#GGGGGGGGGGG7            ~@@@@@@@@?           .?GGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@@@BPGGGGGGGGGP~             :@@@@@@@@!             !PGGGGGGGGPG&@@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@@&GPGGGGGGGGG5:              .#@@@@@@@^              ^5GGGGGGGGGG#@@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@@&GPGGGGGGGGGJ.                B@@@@@@&:               .YGGGGGGGGGPB@@@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@@#GGGGGGGGGGG7                  5@@@@@@#.                 ?GGGGGGGGGPG&@@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@@@BPGGGGGGGGGP~                   ~@@@@@@Y                   ~PGGGGGGGGGG#@@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@@&GPGGGGGGGGG5:                     ^5BGP7                     :5GGGGGGGGGPB@@@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@@#GPGGGGGGGGGJ.                                                  .JGGGGGGGGGPG&@@@@@@@@@@@"
	Write-Host "@@@@@@@@@@#GGGGGGGGGGG7                        !YGGG5!                       7GGGGGGGGGPG#@@@@@@@@@@"
	Write-Host "@@@@@@@@@BPGGGGGGGGGP~                       .G@@@@@@@P.                      ~PGGGGGGGGGG#@@@@@@@@@"
	Write-Host "@@@@@@@&GPGGGGGGGGG5:                        !@@@@@@@@@~                       :YGGGGGGGGGPB&@@@@@@@"
	Write-Host "@@@@@@#GGGGGGGGGGGJ.                          J&@@@@@@Y                         .?GGGGGGGGGPG&@@@@@@"
	Write-Host "@@@@@BPGGGGGGGGGG7                             :7JYJ7:                            !PGGGGGGGGGG#@@@@@"
	Write-Host "@@@&BPGGGGGGGGGP~                                                                  ^5GGGGGGGGGPB@@@@"
	Write-Host "@@&GPGGGGGGGGGG5JYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY5555555Y5GGGGGGGGGGPG&@@"
	Write-Host "@#GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPG#@2"
	Write-Host "BPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGB"
	Write-Host "GPGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGPG"
	Write-Host "&BGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGB&"

"`n"

if ($Choice_RenameToLeaver -eq 1) {Write-Host "The name $ADUserName_FullName WILL be changed to 'Leaver - $ADUserName_FullName" -ForegroundColor Green} 
else {Write-Host "The name $ADUserName_FullName will NOT be changed to 'Leaver - $ADUserName_FullName" -ForegroundColor Red} 

if ($Choice_ConvertToShared -eq 1) {Write-Host "The email address will be converted to a shared mailbox" -ForegroundColor Green} 
else {Write-Host "The email address will NOT be converted to a shared mailbox" -ForegroundColor Red}

if ($Choice_GiveManagerSendOnBehalfPerms -eq 1) {Write-Host "The manager will be given SendOnBehalf permissions" -ForegroundColor Green}
else {Write-Host "The manager will NOT be given SendOnBehalf permissions" -ForegroundColor Red}

if ($Choice_HideAddressFromGAL -eq 1) {Write-Host "The emaill address will be hidden from the Global Address List" -ForegroundColor Green} 
else {Write-Host "The emaill address will NOT be hidden from the Global Address List" -ForegroundColor Red} 

if ($Choice_DisableOnActiveDirectory -eq 1) {Write-Host "The account will be disabled on Active Directory" -ForegroundColor Green} 
else {Write-Host "The account will NOT be disabled on Active Directory" -ForegroundColor Red}

if ($Choice_DisableOnActiveDirectory -eq 1) {Write-Host "All Microsoft 365 licenses will be revoked" -ForegroundColor Green} 
else {Write-Host "The account will NOT have its Microsoft 365 licenses revoked" -ForegroundColor Red} 
	
$confirmation = Read-Host "Please confirm you would like the above to happen. Please type in all caps 'WITH GREAT POWER'"
if ($confirmation -ceq 'WITH GREAT POWER') {
	execute # This will run the script to execute the changes against Active Directory
}
Else {Write-Host "Exiting without making changes."
Stop-Transcript
PAUSE
Exit
}

} # End of function VariableConfirmation
# =====================================================================================================================================================
function Execute{
"`n"
Write-Host "The script will attempt to do the following:"
"`n"
if ($Choice_DisableOnActiveDirectory -eq 1) {
	Disable-ADAccount -Identity $ADUser # This goes first because otherwise when the account is renamed, it fails to find it
	Write-Host "Disabling the account on Active Directory" # This will enable the option in Active Directory to lock the account from Sign-ins
}

if ($Choice_RenameToLeaver -eq 1) {
	Get-aduser $ADUserName | Rename-AdObject -NewName "Leaver - $ADUserName_FullName" # This will rename the user in AD to match other Leavers, making them easier to spot
	Write-Host "Changing name from '$ADUserName' to 'Leaver - $ADUserName'"
}


if ($Choice_ConvertToShared -eq 1) {
	Set-Mailbox -Identity $ADUserName_EmailAddress -Type Shared # This sets the option in Exchange Online to turn the mailbox into a shared mailbox. Requires the Online Module to work.
	Write-Host "Converting the mailbox to shared"
	Set-ADUser -Identity $ADUserName -Replace @{DisplayName="Leaver - $ADUserName_FullName"} # Changes the name of the shared mailbox in Exchange. This will match it to a "leaver -" name if the leaver name is changed.
	Set-ADUser -Identity $ADUserName -Replace @{mailNickname="ADUserName_EmailAddress"} # When a mailbox is changed to shared, sometimes the default mail address on Exchange will change. This will keep it what it once was.
	Set-ADUser -Identity $ADUserName -Replace @{proxyAddresses="SMTP:$ADUserName_EmailAddress"} # The Exchange Online will use the primary SMTP as its primary address. This makes sure it's what it is expected as sometimes Exchange changes it.
	Set-msoluserprincipalname -newuserprincipalname $ADUserName_EmailAddress -userprincipalname $ADUserName@tptholdings.co.uk # Microsoft.Online.Administration.Automation.MicrosoftOnlineException
}

if ($Choice_GiveManagerSendOnBehalfPerms -eq 1) {
	Set-Mailbox -Identity $ADUserName_EmailAddress -GrantSendOnBehalfTo $ADUserName_ManagerEmail -Confirm:$false
	Add-RecipientPermission $ADUserName_EmailAddress -AccessRights SendAs -Trustee $ADUserName_ManagerEmail -Confirm:$false
	Set-Mailbox -Identity $ADUserName_EmailAddress -MessageCopyForSendOnBehalfEnabled $true -Confirm:$false
	Set-Mailbox -Identity $ADUserName_EmailAddress -MessageCopyForSentAsEnabled $true -Confirm:$false
	Add-MailboxPermission -Identity $ADUserName_EmailAddress -User $ADUserName_ManagerEmail -AccessRights FullAccess -InheritanceType All -Confirm:$false
	Write-Host "Granting permissions to $ADUserName_Manager_name to use the email address $ADUserName_EmailAddress"
}

if ($Choice_HideAddressFromGAL -eq 1) {
	Set-ADUser -Identity $ADUserName -Replace @{msExchHideFromAddressLists=$true} # This sets the ADSI option of msExchHideFromAddressLists to true
	Write-Host "Hiding the email from the Global Address List"
}

if ($Choice_RemoveLicense -eq 1) {
	$LicenseArray = Get-MsolUser -UserPrincipalName $ADUserName_EmailAddress | Select-Object -ExpandProperty licenses | Select-Object -Property AccountSkuId | Select-Object -ExpandProperty AccountSkuId # Stores the licenses in an array so it can be easily removed
	Set-MsolUserLicense -UserPrincipalName $ADUserName_EmailAddress -RemoveLicenses $LicenseArray # This will remove the Microsoft 365 licenses
	Write-Host "Removing the following licenses:"
	Write-Host $LicenseArray

	Start-Sleep -Seconds 2 # It may be that the removal of licenses takes about a second to apply so this gives leeway to the check
	# Checks to see if the licenses still exist for the user and informs the script user
	$DoesMicrosoft365LicenseExist = Get-MsolUser -UserPrincipalName $ADUserName_EmailAddress | Select-Object -ExpandProperty IsLicensed
	if ($DoesMicrosoft365LicenseExist -eq "False") {
		Write-Host "Successfully removed Microsoft 365 licenses from $ADUserName_FullName"
	} Else {
		$Microsoft365UserObjectId = Get-MsolUser -UserPrincipalName $ADUserName_EmailAddress | Select-Object -ExpandProperty ObjectId
		Write-Host "Unable to remove some/all Microsoft 365 licenses. Please double check the licenses here:"
		Write-Host "https://admin.microsoft.com/Adminportal/Home#/users/:/UserDetails/$Microsoft365UserObjectId" -ForegroundColor Yellow
	}

}


"`n"
"`n"
Write-Host "The Script has attempted to make the changes, please allow one minute for the changes to take effect" -ForegroundColor Green

# This sends an email to the manager of the leaver informing them that they have been granted access to the leaver's mailbox. This saves any busy work and automates the process for security and logging.
if ($Choice_GiveManagerSendOnBehalfPerms -eq 1) {
	Send-MailMessage -From microsoft365admin@markeygroup.co.uk -To $ADUserName_ManagerEmail -Smtpserver markeygroup-co-uk.mail.protection.outlook.com -Subject "You have been granted permissions to $ADUserName_FullName and their shared inbox" -body "Hello $ADUserName_Manager_name, `n `nYou have been granted access to $ADUserName_FullName and their shared inbox $ADUserName_EmailAddress. `nPlease note that this can take up to 60 minutes to take effect and show up automatically in your Outlook. `nIf you think this is a mistake, please contact the helpdesk at helpdesk@markeygroup.co.uk `n `nPlease note this is an automatic email, this mailbox is not monitored. Do not attempt to send an email to this inbox expecting a reply. All questions should be sent to the helpdesk"
	Write-Host "Sending an email to $ADUserName_ManagerEmail informing them they have been granted access to their shared mailbox."
}

Stop-Transcript

# Sends an email to the IT Team with the transcript of this script, this ensures that it is logged and can be viewed at a later date. The log is also stored on the Network Drive under a Domain admin only folder.
Send-MailMessage -from microsoft365admin@markeygroup.co.uk -Attachments "\\mg-fileserver1\markey sys\APPLIC\INFORMATION TECHNOLOGY\Active Directory leavers log\$CurrentTime.log" -Subject "*** Active Directory Script log for $CurrentTime ***" -to callum.wellard@markeygroup.co.uk -smtpserver markeygroup-co-uk.mail.protection.outlook.com



} #End of function Execute

# =====================================================================================================================================================


# Start the program
parameters # Goes back to EnterUserName to begin the script as the variables needed to be declared first