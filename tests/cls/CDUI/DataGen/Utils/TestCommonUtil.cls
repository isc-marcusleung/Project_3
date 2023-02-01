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

Method TestConvertListOfDataTypeToString1()
{
    set sourceList = ##class(%ListOfDataTypes).%New()
    do sourceList.Insert(100)
    do sourceList.Insert("Hello")
    do sourceList.Insert("World")

    set delimiter = "+"
    set tExpected = sourceList.GetAt(1)_delimiter_sourceList.GetAt(2)_delimiter_sourceList.GetAt(3)

    set tResults = ##class(CDUI.DataGen.Utils.CommonUtil).convertListOfDataTypeToString(sourceList, delimiter)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

Method TestConvertListOfDataTypeToString2()
{
    set sourceList = ##class(%ListOfDataTypes).%New()
    do sourceList.Insert(100)

    set delimiter = "#"
    set tExpected = sourceList.GetAt(1)

    set tResults = ##class(CDUI.DataGen.Utils.CommonUtil).convertListOfDataTypeToString(sourceList, delimiter)
    Do $$$AssertEquals(tResults,tExpected,tExpected_" = "_tResults)
}

}
