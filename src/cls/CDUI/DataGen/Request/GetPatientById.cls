Class CDUI.DataGen.Request.GetPatientById Extends (Ens.Request, %JSON.Adaptor)
{

Property id As %Integer;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetPatientByIdDefaultData">
<Subscript>"GetPatientById"</Subscript>
<Value name="1">
<Value>id</Value>
</Value>
</Data>
<DefaultData>GetPatientByIdDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
