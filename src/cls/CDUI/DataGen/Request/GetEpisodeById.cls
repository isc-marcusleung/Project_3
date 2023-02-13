Class CDUI.DataGen.Request.GetEpisodeById Extends (Ens.Request, %JSON.Adaptor)
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
<Data name="GetEpisodeByIdDefaultData">
<Subscript>"GetEpisodeById"</Subscript>
<Value name="1">
<Value>id</Value>
</Value>
</Data>
<DefaultData>GetEpisodeByIdDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
