Class CDUI.DataGen.Request.NewRadResult Extends (Ens.Request, %JSON.Adaptor)
{

Property OEOrdItemID As %String;

Method SerialisedGet() As %RawString
{
    do ..%JSONExportToString(.json)
    return json
}

Storage Default
{
<Data name="NewRadResultDefaultData">
<Subscript>"NewRadResult"</Subscript>
<Value name="1">
<Value>OEOrdItemID</Value>
</Value>
</Data>
<DefaultData>NewRadResultDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
