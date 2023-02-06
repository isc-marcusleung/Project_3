Class CDUI.DataGen.MIMIC.CHARTEVENTS Extends %Persistent
{

Property RowId As %Integer;

Property SubjectId As %Integer;

Property HadmId As %Integer;

Property IcustayId As %Integer;

Property ItemId As %Integer;

Property Charttime As %String;

Property Storetime As %String;

Property Cgid As %Integer;

Property Value As %String;

Property Valuenum As %Decimal;

Property Valueuom As %String;

Storage Default
{
<Data name="CHARTEVENTSDefaultData">
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
<Value>IcustayId</Value>
</Value>
<Value name="6">
<Value>ItemId</Value>
</Value>
<Value name="7">
<Value>Charttime</Value>
</Value>
<Value name="8">
<Value>Storetime</Value>
</Value>
<Value name="9">
<Value>Cgid</Value>
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
<DataLocation>^CDUI.DataGen.M372A.CHARTEVENTSD</DataLocation>
<DefaultData>CHARTEVENTSDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen.M372A.CHARTEVENTSD</IdLocation>
<IndexLocation>^CDUI.DataGen.M372A.CHARTEVENTSI</IndexLocation>
<StreamLocation>^CDUI.DataGen.M372A.CHARTEVENTSS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
