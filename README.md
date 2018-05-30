# Excel2TMSL
Using Excel &amp; PowerShell to organize and deploy DAX measures

Change the following attributes before running on your machine.
$ASSERVERINSTANCE = "." # You AS Server instance (or Azure Instance)
$ASDATABASE = "FHDW" # Name of your AS database
$UseCommaInsteadOfSemicolonInDax = $true # Set to $true is , should be used instead of ; in DAX expressions.