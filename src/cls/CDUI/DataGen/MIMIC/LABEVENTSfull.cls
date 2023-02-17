Class CDUI.DataGen.MIMIC.LABEVENTSfull Extends %Persistent
{

Property LabEventId As %Integer;

Property SubjectId As %Integer;

Property HadmId As %Integer;

Property SpecimenId As %Integer;

Property ItemId As %Integer;

Property OrderProviderId As %String;

Property Charttime As %String;

Property Storetime As %String;

Property Value As %String;

Property Valuenum As %Decimal;

Property Valueuom As %String;

Storage Default
{
<Data name="LABEVENTSfullDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>LabEventId</Value>
</Value>
<Value name="3">
<Value>SubjectId</Value>
</Value>
<Value name="4">
<Value>HadmId</Value>
</Value>
<Value name="5">
<Value>SpecimenId</Value>
</Value>
<Value name="6">
<Value>ItemId</Value>
</Value>
<Value name="7">
<Value>OrderProviderId</Value>
</Value>
<Value name="8">
<Value>Charttime</Value>
</Value>
<Value name="9">
<Value>Storetime</Value>
</Value>
<Value name="10">
<Value>Value</Value>
</Value>
<Value name="11">
<Value>Valuenum</Value>
</Value>
<Value name="12">
<Value>Valueuom</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen372A.LABEVENTSfullD</DataLocation>
<DefaultData>LABEVENTSfullDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen372A.LABEVENTSfullD</IdLocation>
<IndexLocation>^CDUI.DataGen372A.LABEVENTSfullI</IndexLocation>
<StreamLocation>^CDUI.DataGen372A.LABEVENTSfullS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
