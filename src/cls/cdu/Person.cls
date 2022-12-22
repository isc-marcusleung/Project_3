Class cdu.Person Extends (%Persistent, %Populate)
{

Parameter USEEXTENTSET = 1;

ClassMethod newmethod(Count As %Integer)
{
	#Dim sc As %Status
	#Dim res As %Integer

	set res = ..Populate(Count,1)
	if (res'=Count)
	{
	    set sc = $$$ERROR($$$GeneralError,"Unable to create specified number of records.")
	}
}

ClassMethod PopulateData(
	Count As %Integer = 10,
	Reset As %Boolean = 0) As %Status
{
	#dim sc as %Status = $$$OK
	#dim res as %Integer
	#dim ex As %Exception.AbstractException
	if Reset
	{
		try 
		{
			do ..%KillExtent(1,1)
		} 
		catch ex 
		{
			return ex.AsStatus()
		} 
	}
    do ..newmethod(Count)
	quit sc
}

ClassMethod TestJES()
{
	write !,"Hello World."
	quit:$quit ""
}

ClassMethod TestJES1() [ Language = python ]
{
	print('Hello world')
	return
}

Property GivenName As %String(COLLATION = "SQLUPPER", POPSPEC = "FirstName()");

Property Surname As %String(COLLATION = "SQLUPPER", POPSPEC = "LastName()");

Property Name As %String [ Calculated, SqlComputeCode = { set {Name} = {Surname}_", "_{GivenName} }, SqlComputed ];

Method NameGet() As %String
{
	return i%Surname_", "_i%GivenName
}

Property Sex As %String;

Property DateOfBirth As %Date;

Index SurnameIndex On Surname;

Index SexIndex On Sex;

Index DateOfBirthIndex On DateOfBirth;

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>GivenName</Value>
</Value>
<Value name="3">
<Value>Surname</Value>
</Value>
<Value name="4">
<Value>Sex</Value>
</Value>
<Value name="5">
<Value>DateOfBirth</Value>
</Value>
</Data>
<DataLocation>^CiFK.wPC9.1</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<ExtentLocation>^CiFK.wPC9</ExtentLocation>
<IdLocation>^CiFK.wPC9.1</IdLocation>
<Index name="DateOfBirthIndex">
<Location>^CiFK.wPC9.2</Location>
</Index>
<Index name="IDKEY">
<Location>^CiFK.wPC9.1</Location>
</Index>
<Index name="SexIndex">
<Location>^CiFK.wPC9.3</Location>
</Index>
<Index name="SurnameIndex">
<Location>^CiFK.wPC9.4</Location>
</Index>
<IndexLocation>^CiFK.wPC9.I</IndexLocation>
<StreamLocation>^CiFK.wPC9.S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
