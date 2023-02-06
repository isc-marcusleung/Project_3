Class CDUI.DataGen.Request.NewAppointment Extends (Ens.Request, %JSON.Adaptor)
{

Property PatientID As %Integer;

Property USRN As %String;

Property UBRN As %String;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="NewAppointmentDefaultData">
<Subscript>"NewAppointment"</Subscript>
<Value name="1">
<Value>PatientID</Value>
</Value>
<Value name="2">
<Value>USRN</Value>
</Value>
<Value name="3">
<Value>UBRN</Value>
</Value>
</Data>
<DefaultData>NewAppointmentDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
