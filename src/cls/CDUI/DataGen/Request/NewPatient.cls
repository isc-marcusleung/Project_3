Class CDUI.DataGen.Request.NewPatient Extends (Ens.Request, %JSON.Adaptor)
{

Property PAPERName As %String;

Property PAPERName2 As %String;

Property CTSEXDesc As %String;

Property PAPERDob As %String;

// payor

Property INSTDesc As %String;

// insurance plan

Property AUXITDesc As %String;

Property jobId As %Integer(%JSONINCLUDE = "INPUTONLY");

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

Storage Default
{
<Data name="NewPatientDefaultData">
<Subscript>"NewPatient"</Subscript>
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
<Value name="5">
<Value>INSTDesc</Value>
</Value>
<Value name="6">
<Value>AUXITDesc</Value>
</Value>
<Value name="7">
<Value>JobId</Value>
</Value>
<Value name="8">
<Value>jobId</Value>
</Value>
</Data>
<DefaultData>NewPatientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
