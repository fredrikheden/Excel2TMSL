# Created by Fredrik Hedenström 2018-05-30
# Modules used: ImportExcel, SqlServer

cls

. "$PSScriptRoot\Excel2TMSL.Functions.include.ps1"
. "$PSScriptRoot\Excel2TMSL.DAXTemplates.include.ps1"

$ASSERVERINSTANCE = "."
$ASDATABASE = "FHDW"
$UseCommaInsteadOfSemicolonInDax = $true


$tables = GetDataFromExcelDocuments -path:$PSScriptRoot
$tmsl = CreateTmslFromTable -tables:$tables
CreateMeasuresInCube -tmsl:$tmsl
