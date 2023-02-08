Class CDUI.DataGen.MIMIC.LABEVENTS Extends %Persistent
{

Property RowId As %Integer;

Property SubjectId As %Integer;

Property HadmId As %Integer;

Property ItemId As %Integer;

Property Charttime As %String;

Property Value As %String;

Property Valuenum As %Decimal;

Property Valueuom As %String;

Storage Default
{
<Data name="LABEVENTSDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RowId</Value>
</Value>
<Value name="3">
<Value>SubjectId</Value>
</Value>
<Value name="4">
<Value>HadmId</Value>
</Value>
<Value name="5">
<Value>ItemId</Value>
</Value>
<Value name="6">
<Value>Charttime</Value>
</Value>
<Value name="7">
<Value>Value</Value>
</Value>
<Value name="8">
<Value>Valuenum</Value>
</Value>
<Value name="9">
<Value>Valueuom</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen.MIMIC.LABEVENTSD</DataLocation>
<DefaultData>LABEVENTSDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen.MIMIC.LABEVENTSD</IdLocation>
<IndexLocation>^CDUI.DataGen.MIMIC.LABEVENTSI</IndexLocation>
<StreamLocation>^CDUI.DataGen.MIMIC.LABEVENTSS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
