Class CDUI.Demo.Request.ARCItmMast Extends (Ens.Request, %JSON.Adaptor)
{

Property count As %Integer(%JSONFIELDNAME = "_count");

Property page As %Integer(%JSONFIELDNAME = "page");

Property Active As %String(%JSONFIELDNAME = "Active", DISPLAYLIST = ",Yes,No", VALUELIST = ",Y,N");

Property Alias As %String;

Property BillingGroup As %String;

Property BillingSubgroup As %String;

Property Code As %String;

Property Description As %String;

Property Drug As %String;

Property PrescType As %String;

Property ServiceGroup As %String;

Property Subcategory As %String;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

// Index ActiveIndex On Active;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="ARCItmMastDefaultData">
<Subscript>"ARCItmMast"</Subscript>
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
<Value>Alias</Value>
</Value>
<Value name="5">
<Value>BillingGroup</Value>
</Value>
<Value name="6">
<Value>BillingSubgroup</Value>
</Value>
<Value name="7">
<Value>Code</Value>
</Value>
<Value name="8">
<Value>Description</Value>
</Value>
<Value name="9">
<Value>Drug</Value>
</Value>
<Value name="10">
<Value>PrescType</Value>
</Value>
<Value name="11">
<Value>ServiceGroup</Value>
</Value>
<Value name="12">
<Value>Subcategory</Value>
</Value>
</Data>
<DefaultData>ARCItmMastDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
