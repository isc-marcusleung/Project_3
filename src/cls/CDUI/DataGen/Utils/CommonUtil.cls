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

}
