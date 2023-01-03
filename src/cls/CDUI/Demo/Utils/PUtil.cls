Class CDUI.Demo.Utils.PUtil Extends %PopulateUtils
{

ClassMethod FullName() As %String
{
    Quit ..FirstName()_" "_..LastName()
}

ClassMethod ListElement(list As %List) As %String
{
    Quit $list(list, ..Integer(1, $listlength(list)))
}

ClassMethod CustomDate(min As %Date, max As %Integer, dformat As %Integer = 4, yearopt As %Integer = 4) As %String
{
    Quit $zdate(..Date(min,max),dformat,,yearopt)
}

ClassMethod Time(format As %Integer)
{
   Quit $ztime(..Random(86399), format)
}

}
