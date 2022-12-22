Class CDUI.Demo.Request.NewPatient Extends (Ens.Request, %JSON.Adaptor)
{

Property PAPERName As %String;

Property PAPERName2 As %String;

Property CTSEXDesc As %String;

Property PAPERDob As %String;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="PatientDefaultData">
<Subscript>"Patient"</Subscript>
<Value name="1">
<Value>PAPERName</Value>
</Value>
<Value name="2">
<Value>PAPERName2</Value>
</Value>
<Value name="3">
<Value>CTSEXDesc</Value>
</Value>
<Value name="4">
<Value>PAPERDob</Value>
</Value>
</Data>
<DefaultData>PatientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
