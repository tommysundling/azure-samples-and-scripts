# Login to the 10 demo subscriptions in "Contoso"
Connect-AzAccount -Tenant "ebc1ce4a-bb8c-4db4-b38b-f14f900a45ff" -Subscription "b2e3574b-9fc4-4047-b92e-c4b21f01dc88" # Azure Internal Subscription




# UNTESTED (from lab script)
# Function to generate a secure random password (12 characters, no spaces)
function Get-SecurePassword {
    $lowercase = Get-Random -InputObject "abcdefghijklmnopqrstuvwxyz".ToCharArray()
    $uppercase = Get-Random -InputObject "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
    $numbers = Get-Random -InputObject "0123456789".ToCharArray()
    $specialChars = Get-Random -InputObject "$!@#%^&*".ToCharArray()
    $randomChars = Get-Random -InputObject "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789$!@#%^&*()-_=+{}[];:,.<>?".ToCharArray() -Count 8

    # Initialize an empty string
    $secureSuffix = ""

    # Loop through each selection and append only character position [0]
    foreach ($char in ($lowercase, $uppercase, $numbers,  $specialChars) + $randomChars) {
        if ($char -ne " ") {
            $secureSuffix += $char
        }
    }

    # Shuffle the characters to remove any patterns
    $secureSuffix = -join ($secureSuffix.ToCharArray() | Sort-Object {Get-Random})

    return $secureSuffix

}