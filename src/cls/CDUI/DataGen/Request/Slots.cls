Class CDUI.DataGen.Request.Slots Extends (Ens.Request, %JSON.Adaptor)
{

Property count As %Integer(%JSONFIELDNAME = "_count");

// Set LocId = 241 (Cadiology H1) as mentor Yuting have create slots for this location

Property LocId As %Integer [ InitialExpression = 241 ];

Property ServId As %Integer;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="SlotsDefaultData">
<Subscript>"Slots"</Subscript>
<Value name="1">
<Value>LocId</Value>
</Value>
<Value name="2">
<Value>ServId</Value>
</Value>
<Value name="3">
<Value>Rows</Value>
</Value>
<Value name="4">
<Value>MultiSelect</Value>
</Value>
<Value name="5">
<Value>count</Value>
</Value>
</Data>
<DefaultData>SlotsDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
