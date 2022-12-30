Class CDUI.Demo.Utils.PUtils Extends %PopulateUtils
{

ClassMethod FullName() As %String
{
    Quit ..FirstName()_" "_..LastName()
}

ClassMethod Gender() As %String
{
    set genders = $listbuild("Female", "Indeterminate", "Male", "Other", "Unknown")
    Quit $list(genders, ..Integer(1,5))
}

ClassMethod CustomDate(dformat As %Integer = 4, yearopt As %Integer = 4) As %String
{
    Quit $zdate(..Date(),dformat,,yearopt)
}

}
