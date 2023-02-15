Class CDUI.DataGen.Request.NewObservationItem Extends (Ens.Request, %JSON.Adaptor)
{

Property ObsItemID As %Integer;

Property OBSCode As %String;

Property OBSValue;

Storage Default
{
<Data name="NewObservationItemDefaultData">
<Subscript>"NewObservationItem"</Subscript>
<Value name="1">
<Value>ObsItemID</Value>
</Value>
<Value name="2">
<Value>OBSCode</Value>
</Value>
<Value name="3">
<Value>OBSValue</Value>
</Value>
</Data>
<DefaultData>NewObservationItemDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
