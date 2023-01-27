Class CDUI.DataGen.Request.ObservationItem Extends (Ens.Request, %JSON.Adaptor)
{

// TODO Marcus to check it

Property ObsItemID As %String;

Property OBSCode As %String;

// TODO Marcus to check it

Property OBSValue As %String;

Storage Default
{
<Data name="ObservationItemDefaultData">
<Subscript>"ObservationItem"</Subscript>
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
<DefaultData>ObservationItemDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
