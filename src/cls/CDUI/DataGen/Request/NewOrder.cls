Class CDUI.DataGen.Request.NewOrder Extends (Ens.Request, %JSON.Adaptor)
{

Property DoctorID As %String;

Property AuthDoctorID As %String;

Property EpisodeID As %String;

Property Item As %String;

Property OECPRDesc As %String;

Property OEORIDepProcNotes As %String [ InitialExpression = "comments" ];

Property OEORISttDat As %String;

Property OEORISttTim As %String;

Property PatientID As %String;

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
<Value name="6">
<Value>DoctorID</Value>
</Value>
<Value name="7">
<Value>AuthDoctorID</Value>
</Value>
<Value name="8">
<Value>OECPRDesc</Value>
</Value>
<Value name="9">
<Value>OEORIDepProcNotes</Value>
</Value>
<Value name="10">
<Value>PatientID</Value>
</Value>
</Data>
<DefaultData>NewOrderDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
