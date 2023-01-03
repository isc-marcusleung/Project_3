Class CDUI.Demo.Utils.CommonUtil
{

ClassMethod encodeXMLEscapedChar(input As %String) As %String
{
    return $ZCONVERT(input, "O", "XML")
}

ClassMethod decodeXMLEscapedChar(input As %String) As %String
{
    return $ZCONVERT(input, "I", "XML")
}

}
