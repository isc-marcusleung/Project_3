Class CDUI.DataGen.Request.GetApptById Extends (Ens.Request, %JSON.Adaptor)
{

Property id As %String;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetApptByIdDefaultData">
<Subscript>"GetApptById"</Subscript>
<Value name="1">
<Value>id</Value>
</Value>
</Data>
<DefaultData>GetApptByIdDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
