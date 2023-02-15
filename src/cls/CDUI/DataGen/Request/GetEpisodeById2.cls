Class CDUI.DataGen.Request.GetEpisodeById2 Extends (Ens.Request, %JSON.Adaptor)
{

Property EpisodeIDs As %Integer;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetEpisodeById2DefaultData">
<Subscript>"GetEpisodeById2"</Subscript>
<Value name="1">
<Value>EpisodeIDs</Value>
</Value>
</Data>
<DefaultData>GetEpisodeById2DefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
