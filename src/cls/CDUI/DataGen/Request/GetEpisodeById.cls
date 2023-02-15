Class CDUI.DataGen.Request.GetEpisodeById Extends (Ens.Request, %JSON.Adaptor)
{

Property EpisodeIDs As %String;

Storage Default
{
<Data name="GetEpisodeByIdDefaultData">
<Subscript>"GetEpisodeById"</Subscript>
<Value name="1">
<Value>EpisodeIDs</Value>
</Value>
</Data>
<DefaultData>GetEpisodeByIdDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
