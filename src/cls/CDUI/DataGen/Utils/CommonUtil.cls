Class CDUI.DataGen.Utils.CommonUtil
{

ClassMethod encodeXMLEscapedChar(input As %String) As %String
{
    return $ZCONVERT(input, "O", "XML")
}

ClassMethod decodeXMLEscapedChar(input As %String) As %String
{
    return $ZCONVERT(input, "I", "XML")
}

ClassMethod convertListOfDataTypeToString(sourceList As %ListOfDataTypes, delimiter As %String = ",") As %String
{
    set result = ""
    for i=1:1:sourceList.Count(){
        if (result = "")
        {
            set result = sourceList.GetAt(i)
        } else {
             set result = result_delimiter_sourceList.GetAt(i)
        }

    }
    return result
}

// "17/02/2023","05:58"

ClassMethod GetCurrentDT(Output dateD, Output timeD)
{
    SET dateH=$PIECE($HOROLOG,",",1)
    SET timeH=$PIECE($HOROLOG,",",2)
    set dateD = $zdate(dateH,4)
    set timeD = $ztime(timeH,2)
}

ClassMethod GetTimeDiff(datetime1 As %String, datetime2 As %String, Output secDiff, Output minDiff, Output hrDiff, Output dayDiff)
{
    set result = $system.SQL.DATEDIFF("s",datetime1,datetime2)
    set secDiff = result # 60
    set minDiff = $system.SQL.FLOOR((result / 60 # 60))
    set hrDiff = $system.SQL.FLOOR((result / 60 / 60 # 24))
    set dayDiff = $system.SQL.FLOOR((result / 60 / 60 / 24))
}

}
