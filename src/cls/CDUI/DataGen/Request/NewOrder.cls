Class CDUI.DataGen.Request.NewOrder Extends (Ens.Request, %JSON.Adaptor)
{

Property Item As %String;

Property EpisodeID As %String;

Property OEORISttDat As %String;

Property OEORISttTim As %String;

Property TOVERRIDE As %String [ InitialExpression = 1 ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="NewOrderDefaultData">
<Subscript>"NewOrder"</Subscript>
<Value name="1">
<Value>Item</Value>
</Value>
<Value name="2">
<Value>EpisodeID</Value>
</Value>
<Value name="3">
<Value>OEORISttDat</Value>
</Value>
<Value name="4">
<Value>OEORISttTim</Value>
</Value>
<Value name="5">
<Value>TOVERRIDE</Value>
</Value>
</Data>
<DefaultData>NewOrderDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
