Import CDUI.Demo.Utils.CommonUtil

Class CDUI.Utils.TestCommonUtil Extends %UnitTest.TestCase
{

Method TestEncodeXMLEscapedChar()
{
    set input = "abc&"
    set tExpected = "abc&amp;"
    set tResults = ##class(CDUI.Demo.Utils.CommonUtil).encodeXMLEscapedChar(input)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

Method TestDecodeXMLEscapedChar()
{
    set input = "abc&amp;" 
    set tExpected = "abc&"
    set tResults = ##class(CDUI.Demo.Utils.CommonUtil).decodeXMLEscapedChar(input)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

}
