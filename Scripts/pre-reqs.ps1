
# Install the Az module for the current user. 
# The -Force parameter is used to suppress the confirmation prompt.
Install-Module -Name Az -Scope CurrentUser -Force

# Update the Az module to the latest version. 
# The -Force parameter is used to suppress the confirmation prompt.
Update-Module -Name Az -Force



# Connect to Azure
Connect-AzAccount