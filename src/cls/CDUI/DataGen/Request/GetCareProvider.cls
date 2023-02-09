Class CDUI.DataGen.Request.GetCareProvider Extends (Ens.Request, %JSON.Adaptor)
{

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
