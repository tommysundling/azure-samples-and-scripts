
# TO USE THIS SCRIPT YOU FIRST NEED TO LOGIN AS A USER WITH 'Connect-AzAccount'


function Get-AzureHeaders {
   # Get the access token
   $token = (Get-AzAccessToken).Token

   # Define the headers
   $headers = @{
      'Authorization' = "Bearer $token"
      'Content-Type' = 'application/json'
   }

   # Return the headers
   return $headers
}


