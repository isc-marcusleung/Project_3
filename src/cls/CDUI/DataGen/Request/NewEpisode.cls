Class CDUI.DataGen.Request.NewEpisode Extends (Ens.Request, %JSON.Adaptor)
{

Property PatientID As %String;

Property PAADMType As %String;

Property PAADMAdmDate As %String;

Property PAADMAdmTime As %String;

Property CTLOCDesc As %String;

Property PAADMVisitStatus As %String;

Property PAADMDischgDate As %String;

Property PAADMDischgTime As %String;

Property TOVERRIDE As %Boolean;

Property jobId As %Integer(%JSONINCLUDE = "INPUTONLY");

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="NewEpisodeDefaultData">
<Subscript>"NewEpisode"</Subscript>
<Value name="1">
<Value>PatientID</Value>
</Value>
<Value name="2">
<Value>PAADMType</Value>
</Value>
<Value name="3">
<Value>PAADMAdmDate</Value>
</Value>
<Value name="4">
<Value>PAADMAdmTime</Value>
</Value>
<Value name="5">
<Value>CTLOCDesc</Value>
</Value>
<Value name="6">
<Value>PAADMVisitStatus</Value>
</Value>
<Value name="7">
<Value>PAADMDischgDate</Value>
</Value>
<Value name="8">
<Value>PAADMDischgTime</Value>
</Value>
<Value name="9">
<Value>jobId</Value>
</Value>
<Value name="10">
<Value>TOVERRIDE</Value>
</Value>
</Data>
<DefaultData>NewEpisodeDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
