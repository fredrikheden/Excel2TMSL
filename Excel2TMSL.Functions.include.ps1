
# Created by Fredrik Hedenström 2018-05-30

function InvokeASCmd($query, $ignoreError) {
    if ( $ignoreError ) {
        $result = Invoke-ASCmd -Server $ASSERVERINSTANCE -Query:$query -ErrorAction SilentlyContinue -ErrorVariable e
    } else {
        $result = Invoke-ASCmd -Server $ASSERVERINSTANCE -Query:$query
        if ( $result.Contains("<Error") ) {
            write-host "Error occurred!" -ForegroundColor Red
            write-host $result -ForegroundColor Red
        } elseif ( $result.Contains("<Warning") ) {
            write-host "Warning!" -ForegroundColor Yellow
            write-host $result -ForegroundColor Yellow
        }
    }
}

function GetDataFromExcelDocuments($path) {
    $list = @()
    foreach( $f in (Get-ChildItem -Path $path -Filter "*.xlsx") ) {
        $xls1 = Import-Excel -Path $f.FullName -WorksheetName "Calculations"
        foreach( $r in $xls1 ) {
            $rn = @{DAXFormula=$r.DAXFormula; DAXTemplate=$r.DAXTemplate; Description=$r.Description; Folder=$r.Folder; Format=$r.Format; Hidden=$r.Hidden; MeasureName=$r.MeasureName; VirtualTable=$r.VirtualTable}
            $list += $rn
        }
    }
    $tables = $list | Group-Object -Property {$_.VirtualTable}
    return $tables
}

function CreateTmslFromTable($tables) {
    $arrTmslCreate = @()
    $arrTmslDelete = @()
    foreach( $row in $tables ) {
        $tableName = $row.Name
        $tmslCreateTable = @"
{
    "create": {
    "parentObject": {
	    "database": "$ASDATABASE"
    },
    "table": {
	    "name": "$tableName",
	    "columns": [
	    {
		    "type": "calculatedTableColumn",
		    "name": "Hide me",
		    "dataType": "string",
		    "isNameInferred": true,
		    "isDataTypeInferred": true,
		    "isHidden": true,
		    "sourceColumn": "[Hide me]"
	    }
	    ],
	    "partitions": [
	    {
		    "name": "$tableName",
		    "source": {
		    "type": "calculated",
		    "expression": "DATATABLE(\"Hide me\",string,{{\"\"}})"
		    }
	    }
	    ],
	    "measures": [#MEASUREEXPRESSION#]
        }
    }
}
"@ 
        $arrMeasures = @()
        foreach( $rm in $row.Group ) {
            $DAXExpression = $rm.DAXFormula
            $HiddenFlag = $rm.Hidden.ToString().ToLower()
            $MeaureName = $rm.MeasureName
            $Description = $rm.Description
            $DisplayFolder = $rm.Folder
            $FormatString = $rm.Format
            $DAXMethod = $rm.DAXTemplate
            if ( $rm.DAXTemplate.Length -gt 0 ) {
                $DAXExpression = &"$DAXMethod" $DAXExpression
            }
            $tm = @"
{
    "name": "$MeaureName",
    "expression": "$DAXExpression",
    "description": "$Description",
    "displayFolder": "$DisplayFolder",
    "formatString": "$FormatString",
    "isHidden": $HiddenFlag
}
"@
        $arrMeasures += $tm
    }
    $tmslCreateTable = $tmslCreateTable.Replace( "#MEASUREEXPRESSION#", ( $arrMeasures -join ",") )
    $tmslDeleteTable = @"
			{
			  "delete": {
				"object": {
				  "database": "$ASDATABASE",
				  "table": "$tableName"
				}
			  }
			}
"@
    
        $arrTmslCreate += $tmslCreateTable
        $arrTmslDelete += $tmslDeleteTable
    }
    return @{TmslCreate=$arrTmslCreate; TmslDelete=$arrTmslDelete }
}

function CreateMeasuresInCube($tmsl) {

    for ($i=0; $i -lt $tmsl.TmslCreate.Length; $i++) {
        $crt = $tmsl.TmslCreate[$i]
        $del = $tmsl.TmslDelete[$i]
        InvokeASCmd -query:$del -ignoreError:$true
        InvokeASCmd -query:$crt -ignoreError:$false
    }
}