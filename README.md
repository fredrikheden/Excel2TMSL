Deprecated.

# Excel2TMSL
Using Excel &amp; PowerShell to organize and deploy DAX measures
<br><br>

Change the following attributes before running on your machine.
<br>
$ASSERVERINSTANCE = "." # You AS Server instance (or Azure Instance)
<br>
$ASDATABASE = "FHDW" # Name of your AS database
<br>
$UseCommaInsteadOfSemicolonInDax = $true # Set to $true is , should be used instead of ; in DAX expressions.
<br><br>
Don't forget to import the PowerShell module ImportExcel by running the following PowerShell command:
<br>
Install-Module -Name ImportExcel
<br>
