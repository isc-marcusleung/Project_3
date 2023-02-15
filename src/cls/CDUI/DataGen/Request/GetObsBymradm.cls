Class CDUI.DataGen.Request.GetObsBymradm Extends (Ens.Request, %JSON.Adaptor)
{

Property mradm As %Integer;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetObsBymradmDefaultData">
<Subscript>"GetObsBymradm"</Subscript>
<Value name="1">
<Value>mradm</Value>
</Value>
</Data>
<DefaultData>GetObsBymradmDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
