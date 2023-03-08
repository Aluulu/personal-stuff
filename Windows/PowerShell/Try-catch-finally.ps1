Try { # The try function will try to run the following code, and then catch any errors. 
    # Replace me with the code you want to run. The Try script will attempt to catch any errors when executing this command.
} Catch [error.type.goes.here] {
	# This catch block will allow code to be ran if it matches the above error type.
} Catch { 
	# This empty catch block goes last. Since it is empty, it will catch all error codes not specified above.
} finally {
	# This will run the following code even if an error is caught.
}







# Name: Try, Catch, and Finally
# Module: Microsoft.PowerShell.Core
# Syntax: Try {} Catch {} Finally {}
# Microsoft Docs page: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally


# To add a error specific catch, add the [error.type] into square brackets like the example below
# ===============================================================================================
#	try {
#   	1/0
#		Write-Host "This is executed after the error"
#	} catch [System.DivideByZeroException] {
#   	Write-Host "Divide by zero error occurred.`n$_"
#	} catch {
#    	Catch all errors
#    	Write-Host "Oh oh! Another error occurred.`n$_"
#}
#
# This should result in the output of:
# 	Divide by zero error occurred.
# 	Attempted to divide by zero.
#
# Example taken from https://powershellbyexample.dev/post/error-handling/
# ===============================================================================================


# To read out an error message, you can use the command $_ as it will print out the error message in plain text
# For example if you were to use a string that didn't exist, it would normally print out the plain text, the line and character the error occurred at, and the error category.
# Using $_ will just print out the plain text. So going back to the example above, trying to use a string that didn't exist would just print out:
# "The term 'ThissStringDoesntExist' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again."
# Other formats can be used in addition to the plain text. For example, if you want just the line and character location, you can use $_.StringStackTrace.
# An example of this is: 
# ===========================================================
#	try { NonsenseString }
#	catch {
#  		Write-Host "An error occurred:"
#  		Write-Host $error[0].ScriptStackTrace
#	}
#
#
# Which will result in:
# 	An Error occurred:
# 	at <ScriptBlock>, <No file>: line 2
# Example taken from https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally
# ===========================================================


# The properties you can use are listed as follows: (https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.errorrecord?view=powershellsdk-7.0.0)
#	$error.CategoryInfo				- This gets the CategoryInfo information from the full error message, and prints it in a readable format.
#	$error.ErrorDetails				- This prints additional information about the error
#	$error.Exception				- This prints the full easy to read plain text of what the error is and why is occuried.
#	$error.FullyQualifiedErrorId	- This gets the FullyQualifiedErrorId information from the full error message. This can help figure out what the code was trying to do when it ran into the error.
#	$error.InvocationInfo			- This identifies the cmdlet, script, or other command which caused the error and prints it in a readable format.
#	$error.PipelineIterationInfo	- This prints out where the error occuried in the pipeline and what the error code is for that pipeline object. For example "Get-Childitem -path /NoRealDirectory" returns the output 0 and then as Get-Childitem passed with a 0, while -Path returned with a 1 error.
# 	$error.ScriptStackTrace			- This prints the line and character that the error occuried on.
#	$error.TargetObject				- This prints out which object(s) caused the error.

# Do NOT include quatation marks when writing the error to host. Otherwise you won't get the error message you expected


# To change which error message you with to display, use a number inside square brackets.
# For the most recent, use $error[0]
# For the second most recent, use $error[1]
# For the third most recent, use $error[2]...........


# If you are running this script in a shell to test, you may want to add $error.Clear() at the start of your code to clear the error array.
# Otherwise you'll have problems with error codes appearing when they shouldn't.


# If you'd like to make an error terminating, so that the Catch part of the script takes action, you can add the variable "-ErrorAction Stop" to the end of the command
# So for example, this will look like this:
# Rename-Item -Path "C:\tmp\ThisFolderDoesntExist\test.txt" -NewName "new test.txt" -ErrorAction Stop


# To get the full error type for a specific error, you can use the following command. Then it can be put into your Catch[] parameter:
# $Error[0].Exception.GetType().FullName


# A good idea may be to create a function in your PowerShell profile that you can call upon that will automatically paste in the line above. For example, this script
# allows you to call upon the function "ErrorDetails" with a parameter that allows you to define where in the array you wish to search in.
# ===============================================================================================
# function ErrorDetails {
    # param(
        # [Parameter(Mandatory = $false)]
        # [String]$Array
    # )
    # if ($Array -eq "") {
        # $Array = 0
    # }
    # Write-Host $Error[$Array].Exception.GetType().FullName
	# $Error[$Array].Exception
# }
# ===============================================================================================