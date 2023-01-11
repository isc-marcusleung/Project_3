Import CDUI.Demo.Utils.TestPUtil

Class tests.CDUI.TestPUtil Extends %UnitTest.TestCase
{

Method TestFullName()
{
    set exptected = 2
    set actual = $length(##class(CDUI.Demo.Utils.PUtil).FullName()," ")
    Do $$$AssertEquals(actual,exptected,exptected_" = "_actual)
}

Method TestListElement()
{
    set input = $LISTBUILD(1,2,3,4)
    set actual = ##class(CDUI.Demo.Utils.PUtil).ListElement(input)
    Do $$$AssertTrue((actual '= "") && (actual > 0) && (actual < 5))
}

Method TestCustomDate()
{
    set maxDate = $piece($horolog, ",", 1)
    set result = ##class(CDUI.Demo.Utils.PUtil).CustomDate(0,maxDate)
    Do $$$AssertTrue($MATCH(result,"\d\d/\d\d/\d\d\d\d"), "Format is correct. result: "_result)
    set actual = $zdateh(result,4)
    Do $$$AssertTrue((actual <= maxDate), "The date is within the range. min: 0"_", max: "_maxDate_", result: "_actual)
}

Method TestTime()
{
    set maxTime = $piece($horolog, ",", 2)
    set result = ##class(CDUI.Demo.Utils.PUtil).Time(0,maxTime,2)
    Do $$$AssertTrue($MATCH(result,"\d\d:\d\d"), "Format is correct. result: "_result)
    Do $$$AssertTrue(($ztimeh(result,2) <= maxTime), "The date is within the range. min: 0"_", max: "_maxTime_", result: "_$ztimeh(result,2))
}

}
