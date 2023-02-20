Class CDUI.DataGen.Request.NewObservation Extends (Ens.Request, %JSON.Adaptor)
{

Property PatientID As %String;

Property mradm As %String;

Property EpisodeID As %String;

Property ObsDate As %String;

Property ObsTime As %String;

Property OEOREDateExecuted As %String;

Property OEORETimeExecuted As %String;

Property OBSENTRYPatLocDesc As %String;

Property TableItems As list Of CDUI.DataGen.Request.NewObservationItem;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="NewObservationDefaultData">
<Subscript>"NewObservation"</Subscript>
<Value name="1">
<Value>PatientID</Value>
</Value>
<Value name="2">
<Value>mradm</Value>
</Value>
<Value name="3">
<Value>EpisodeID</Value>
</Value>
<Value name="4">
<Value>ObsDate</Value>
</Value>
<Value name="5">
<Value>ObsTime</Value>
</Value>
<Value name="6">
<Value>OBSENTRYPatLocDesc</Value>
</Value>
<Value name="7">
<Value>OEOREDateExecuted</Value>
</Value>
<Value name="8">
<Value>OEORETimeExecuted</Value>
</Value>
</Data>
<Data name="TableItems">
<Attribute>TableItems</Attribute>
<Structure>subnode</Structure>
<Subscript>"CDUI.DataGen.Request.NewObservation.TableItems"</Subscript>
</Data>
<DefaultData>NewObservationDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
