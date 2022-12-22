Class CDUI.Demo.Request.NewLocation Extends (Ens.Request, %JSON.Adaptor)
{

Property CTLOCDesc As %String;

Property CTLOCCode As %String;

Property CTLOCDateActiveFrom As %String [ InitialExpression = {+$h} ];

Storage Default
{
<Data name="NewLocationDefaultData">
<Subscript>"NewLocation"</Subscript>
<Value name="1">
<Value>CTLOCDesc</Value>
</Value>
<Value name="2">
<Value>CTLOCCode</Value>
</Value>
<Value name="3">
<Value>CTLOCDateActiveFrom</Value>
</Value>
</Data>
<DefaultData>NewLocationDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
