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

}
