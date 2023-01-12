Import CDUI.DataGen.Utils.CommonUtil

Class CDUI.DataGen.Utils.TestCommonUtil Extends %UnitTest.TestCase
{

Method TestEncodeXMLEscapedChar()
{
    set input = "abc&"
    set tExpected = "abc&amp;"
    set tResults = ##class(CDUI.DataGen.Utils.CommonUtil).encodeXMLEscapedChar(input)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

Method TestDecodeXMLEscapedChar()
{
    set input = "abc&amp;" 
    set tExpected = "abc&"
    set tResults = ##class(CDUI.DataGen.Utils.CommonUtil).decodeXMLEscapedChar(input)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

}
