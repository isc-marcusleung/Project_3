Class CDUI.DataGen.Utils.PUtil Extends %PopulateUtils
{

ClassMethod FullName() As %String
{
    Quit ..FirstName()_" "_..LastName()
}

ClassMethod ListElement(list As %List) As %String
{
    Quit $listget(list, ..Integer(1, $listlength(list)))
}

ClassMethod CustomDate(min As %Date, max As %Integer, dformat As %Integer = 4, yearopt As %Integer = 4) As %String
{
    Quit $zdate(..Date(min,max),dformat,,yearopt)
}

ClassMethod Time(min As %Integer, max As %Integer, format As %Integer)
{
   //the min and max should be 0 <= min <= 86399
    set defaultMin = 0
    set defaultMax = 86399
 	if '$Get(min) { set min = defaultMin }
	if '$Get(max) { set max = defaultMax }
	if min>max Quit 0
    if (min < defaultMin) || (min > defaultMax) Quit 0
    if (max < defaultMin) || (max > defaultMax) Quit 0

    set randMax = max - min + 1
    Quit $ztime((..Random(randMax) + min ), format)
}

}
