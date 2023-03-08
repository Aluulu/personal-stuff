#Requires -Modules ActiveDirectory
Search-ADAccount –AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | Select -Property Name, LastLogonDate, UserPrincipalName, LockedOut, AccountExpirationDate | Out-GridView







# Name: Display Active Directory users that have not logged in within a certain time period
# Module: ActiveDirectory
# Microsoft Docs page: https://docs.microsoft.com/en-us/powershell/module/activedirectory/search-adaccount
# Syntax: Search-ADAccount [-AccountDisabled] [-AccountExpired] [-AuthType <ADAuthType>] [-ComputersOnly] [-Credential <PSCredential>] [-ResultPageSize <Int32>] [-ResultSetSize <Int32>] [-SearchBase <String>] [-SearchScope <ADSearchScope>] [-Server <String>] [-UsersOnly] [<CommonParameters>]
#       -AccountDisabled            Searches for accounts that have been marked as disabled.     
#       -AccountExpired             Searches for accounts that have been marked as expired
#       -AccountInactive            Searches for accounts that have not logged in within a time period. Must be used in conjunction with TimeSpan.
#       -AuthType                   Specifies the authentication to use. Negotiate or 0. Basic or 1.
#       -ComputersOnly              Searches only for objects marked as computers.
#       -Credential                 Specifies the credentials used to perform Search-ADAccount. If blank or not included, it uses the account currently signed into PowerShell.
#       -DateTime                   Specifies a time value for Search-ADAccounts parameters.
#       -LockedOut                  Searches for accounts that have been marked as locked out due to incorrect passwords.
#       -PasswordExpired            Searches for accounts that have an expired password.
#       -PasswordNeverExpires       Searches for accounts that have passwords that don't expire.
#       -ResultPageSize             Specifies how many objects are included in a single query. Default is 256.
#       -ResultSetSize              Specifies how many objects should be returned/displayed in a single query. The default is all objects in a search. 
#       -SearchBase                 Specifies an Active Directory path to search.
#       -SearchScope                Specifies the scope of an Active Directory search.
#       -Server                     Specifies the server that the search will apply to.
#       -TimeSpan                   Specifies the time interval that is used for certain parameters. The format for this command is [D.H.M.S.F].
#       -UsersOnly                  Searches only for objects that have been mared as users.


#Property (https://docs.microsoft.com/en-us/dotnet/api/microsoft.activedirectory.management.adaccount#properties)
#       AccountExpirationDate       Displays the expiration date for the displayed accounts.
#       DistinguishedName           Displays the Canonical Name and Organisational Unit for the displayed accounts.
#       Enabled                     Shows whenever an account is currently disabled or not. True means the account is active, and False means the account is disabled.
#       LastLogonDate               Displays the last logon date for the account. The account must have made a connection to the server for the date to update.
#       LockedOut                   Displays whenever the account is currently locked out due to incorrect passwords.
#       Name                        Shows the DisplayName of the user. This is a lot readable and makes it easier to identify a user.
#       ObjectClass                 Displays the class of the object. Whenever the object is a usre, computer, contact, group, etc. Using the parameter -UsersOnly displays only users from this list.
#       ObjectGUID                  Displays the object's unique identifier. Typically unreadable unless it is really required.
#       PasswordExpired             Displays whenever a user's password has reached its expiration date. This does not display when that date is or how long it has been expired.
#       PasswordNeverExpires        Shows if a user's password has an expiration date or not. This does not display the date if a user does have an expiration date set against their account.
#       SamAccountName              Displays the user's SamAccountName. This is only useful for pre-Windows 2000 machines but can be used as a visual identifier.
#       SID                         Displays the user's Security ID. Since the ID contains the domain's ID as well, it can be useful for identifying a domain and more.
#       UserPrincipalName           Displays the full UserPrincipalName of a user. This contains the first name, last name, and the domain name. Example: john.smith@microsoft.co.uk
#       PropertyNames               
#       AddedProperties             
#       RemovedProperties           
#       ModifiedProperties          
#       PropertyCount               Counts the number of properties applied against an account.


# Using the information above, we can create a useful and easy to understand table of users that haven't logged on within a certain time period.
# Without specifying some properties, the default output is a lot of useless information that doesn't help with readability. This can be condensed with properties with the following syntax:
#       Search-ADAccount -AccountInactive -TimeSpan [D.H:M:S] -UsersOnly | Select -Property [Insert, Properties, Here, Seperated, By, Commas] | Out-GridView
# Recommendations include using Name, LastLogonDate, UserPrincipalName, LockedOut, AccountExpirationDate. This is a much more readable with some relevant information.
# The syntax for this example would look like this:
#       Search-ADAccount –AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | Select -Property Name, LastLogonDate, UserPrincipalName, LockedOut, AccountExpirationDate | Out-GridView


# I have deliberately used the command Out-GridView in all of my examples as it is a really useful command that displays the output in a interactable and filterable table.
# In order to add or remove this functionality, simple add or remove the Pipe and the command. Below are two examples, the first without the command, and the second with the command.
#       Search-ADAccount –AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | Select -Property Name, LastLogonDate, UserPrincipalName, LockedOut, AccountExpirationDate
#       Search-ADAccount –AccountInactive -TimeSpan 90.00:00:00 -UsersOnly | Select -Property Name, LastLogonDate, UserPrincipalName, LockedOut, AccountExpirationDate | Out-GridView