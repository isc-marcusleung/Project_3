Class CDUI.DataGen.Request.GetOrderByPatientId Extends (Ens.Request, %JSON.Adaptor)
{

Property PatientID As %Integer;

Property Serialised As %RawString(%JSONINCLUDE = "NONE") [ Transient ];

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="GetOrderByPatientIdDefaultData">
<Subscript>"GetOrderByPatientId"</Subscript>
<Value name="1">
<Value>PatientID</Value>
</Value>
</Data>
<DefaultData>GetOrderByPatientIdDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
