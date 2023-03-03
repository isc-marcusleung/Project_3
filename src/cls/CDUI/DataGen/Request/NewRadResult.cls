Class CDUI.DataGen.Request.NewRadResult Extends (Ens.Request, %JSON.Adaptor)
{

Property PatientID As %String;

Property EpisodeID As %String;

Property OEOrdItemID As %String;

Property Action As %String [ InitialExpression = "Y" ];

Property MarkAsVerified As %String [ InitialExpression = "Y" ];

Property Radiologist As %String [ InitialExpression = "Rad" ];

Property DateReported As %String;

Property PlainText As %String;

Property jobId As %Integer(%JSONINCLUDE = "INPUTONLY");

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
<Value>PatientID</Value>
</Value>
<Value name="2">
<Value>EpisodeID</Value>
</Value>
<Value name="3">
<Value>OEOrdItemID</Value>
</Value>
<Value name="4">
<Value>Action</Value>
</Value>
<Value name="5">
<Value>MarkAsVerified</Value>
</Value>
<Value name="6">
<Value>Radiologist</Value>
</Value>
<Value name="7">
<Value>DateReported</Value>
</Value>
<Value name="8">
<Value>PlainText</Value>
</Value>
<Value name="9">
<Value>jobId</Value>
</Value>
</Data>
<DefaultData>NewRadResultDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
