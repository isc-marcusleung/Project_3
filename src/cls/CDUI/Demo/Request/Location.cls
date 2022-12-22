Class CDUI.Demo.Request.Location Extends (Ens.Request, %JSON.Adaptor)
{

Property count As %Integer(%JSONFIELDNAME = "_count");

Property page As %Integer(%JSONFIELDNAME = "page");

Property Active As %String(%JSONFIELDNAME = "Active", DISPLAYLIST = ",Yes,No", VALUELIST = ",Y,N");

Property Code As %String;

Property DepartmentGroup As %String;

Property Description As %String;

Property Hospital As %String;

Property LocationTypeID As %String;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Index ActiveIndex On Active;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="LocationDefaultData">
<Subscript>"Location"</Subscript>
<Value name="1">
<Value>count</Value>
</Value>
<Value name="2">
<Value>page</Value>
</Value>
<Value name="3">
<Value>Active</Value>
</Value>
<Value name="4">
<Value>Code</Value>
</Value>
<Value name="5">
<Value>DepartmentGroup</Value>
</Value>
<Value name="6">
<Value>Description</Value>
</Value>
<Value name="7">
<Value>Hospital</Value>
</Value>
<Value name="8">
<Value>LocationTypeID</Value>
</Value>
</Data>
<DefaultData>LocationDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
