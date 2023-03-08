#requires -RunAsAdministrator







# Name: Require elevated permissions
# Module: Microsoft.PowerShell.Core
# Syntax: #requires -RunAsAdministrator
# Microsoft Docs page: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires


# Put the code above at the top of your script to require the script to run as an administrator.
# This looks like:

########################################################### - top of script
#			#requires -RunAsAdministrator
#
#			Rest of your script goes here
#			Any code here won't matter because
#			it will need to be elevated first.
#			Good for scripts that need elevation.
########################################################### - bottom of script


# This can be ideal when you have a script that must be ran elevated, but often forget to do so.
# This will prevent you from accidently having the script be half-ran before requiring the elevated permissions.

# Keep in mind that on non-Windows operating systems (powershell for Linux and Mac), this command DOES NOT WORK.

# While this command can be put anywhere in your scripts, it may be best practise to leave it at the top since it doesn't operate unless the parameter is met.
# This helps when you need to make changes to your code, and you don't have to go searching for a line of code that essentially runs at the very start of your program.
# This applies to all "#requires" statements but specifically so for -RunAsAdministrator.

# The official Microsoft Docs page for this command is here:
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_requires?view=powershell-7.2#-runasadministrator