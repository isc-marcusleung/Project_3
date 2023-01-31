Class CDUI.DataGen.Request.LocationServices Extends (Ens.Request, %JSON.Adaptor)
{

Property loc As %Integer [ InitialExpression = 241 ];

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="LocationServicesDefaultData">
<Subscript>"LocationServices"</Subscript>
<Value name="1">
<Value>loc</Value>
</Value>
</Data>
<DefaultData>LocationServicesDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
