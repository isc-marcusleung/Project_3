Class CDUI.DataGen.MIMIC.TriageNew Extends %Persistent
{

Property Temp As %Double;

Property HeartRate As %Integer;

Property Respirations As %Integer;

Property O2Sat As %Integer;

Property SBP As %Integer;

Property DBP As %Integer;

Property Height As %Integer;

Property Weight As %Integer;

Storage Default
{
<Data name="TriageNewDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Temp</Value>
</Value>
<Value name="3">
<Value>HeartRate</Value>
</Value>
<Value name="4">
<Value>Respirations</Value>
</Value>
<Value name="5">
<Value>O2Sat</Value>
</Value>
<Value name="6">
<Value>SBP</Value>
</Value>
<Value name="7">
<Value>DBP</Value>
</Value>
<Value name="8">
<Value>Height</Value>
</Value>
<Value name="9">
<Value>Weight</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen.MIMIC.TriageNewD</DataLocation>
<DefaultData>TriageNewDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen.MIMIC.TriageNewD</IdLocation>
<IndexLocation>^CDUI.DataGen.MIMIC.TriageNewI</IndexLocation>
<StreamLocation>^CDUI.DataGen.MIMIC.TriageNewS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
