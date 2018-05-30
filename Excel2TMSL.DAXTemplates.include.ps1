# Created by Fredrik Hedenström 2018-05-30

function TimeRange($daxFormula) {
    $template = @"
var val_default = #MEASURE#
var val_ytd = calculate(#MEASURE#; DATESYTD(Calendar[Date]))
var val_lastmonth = calculate(#MEASURE#; PARALLELPERIOD(Calendar[Date]; -1;MONTH))
return
if( HASONEFILTER(TimeRange[Choice]);
    switch(
        Max(TimeRange[Choice]);
        "YTD"; val_ytd;
        "Last Month"; val_lastmonth;
        val_default
    );
    val_default )
"@

    $retValue = $template.Replace("#MEASURE#", $daxFormula)
    if ( $UseCommaInsteadOfSemicolonInDax ) {
        $retValue = $retValue.Replace(";", ",")
    }
    $retValue = $retValue.Replace("""", "\""")
    return $retValue
}

