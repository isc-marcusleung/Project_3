Class CDUI.DataGen.Request.GetOrderByCategory Extends (Ens.Request, %JSON.Adaptor)
{

Property count As %Integer(%JSONFIELDNAME = "_count");

Property category As %String;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

// Index ActiveIndex On Active;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetOrderByCategoryDefaultData">
<Subscript>"GetOrderByCategory"</Subscript>
<Value name="1">
<Value>count</Value>
</Value>
<Value name="2">
<Value>category</Value>
</Value>
</Data>
<DefaultData>GetOrderByCategoryDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
