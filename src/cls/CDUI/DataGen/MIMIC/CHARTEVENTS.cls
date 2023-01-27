Class CDUI.DataGen.MIMIC.CHARTEVENTS Extends %Persistent
{

Property rowId As %Integer;

Property subjectId As %Integer;

Property hadmId As %Integer;

Property icustayId As %Integer;

Property itemId As %Integer;

Property charttime As %String;

Property storetime As %String;

Property cgid As %Integer;

Property value As %Decimal;

Property valuenum As %Decimal;

Property valueuom As %String;

Storage Default
{
<Data name="CHARTEVENTSDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>rowId</Value>
</Value>
<Value name="3">
<Value>subjectId</Value>
</Value>
<Value name="4">
<Value>hadmId</Value>
</Value>
<Value name="5">
<Value>icustayId</Value>
</Value>
<Value name="6">
<Value>itemId</Value>
</Value>
<Value name="7">
<Value>charttime</Value>
</Value>
<Value name="8">
<Value>stroetime</Value>
</Value>
<Value name="9">
<Value>cgid</Value>
</Value>
<Value name="10">
<Value>value</Value>
</Value>
<Value name="11">
<Value>valuenum</Value>
</Value>
<Value name="12">
<Value>valueuom</Value>
</Value>
<Value name="13">
<Value>storetime</Value>
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
