Class CDUI.DataGen.MIMIC.CHARTEVENTfull Extends %Persistent
{

Property SubjectId As %Integer;

Property StayId As %Integer;

Property Temp As %Double;

Property HeartRate As %Integer;

Property Respirations As %Integer;

Property O2Sat As %Integer;

Property SBP As %Integer;

Property DBP As %Integer;

Storage Default
{
<Data name="CHARTEVENTfullDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SubjectId</Value>
</Value>
<Value name="3">
<Value>StayId</Value>
</Value>
<Value name="4">
<Value>Temp</Value>
</Value>
<Value name="5">
<Value>HeartRate</Value>
</Value>
<Value name="6">
<Value>Respirations</Value>
</Value>
<Value name="7">
<Value>O2Sat</Value>
</Value>
<Value name="8">
<Value>SBP</Value>
</Value>
<Value name="9">
<Value>DBP</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGe372A.CHARTEVENTfullD</DataLocation>
<DefaultData>CHARTEVENTfullDefaultData</DefaultData>
<IdLocation>^CDUI.DataGe372A.CHARTEVENTfullD</IdLocation>
<IndexLocation>^CDUI.DataGe372A.CHARTEVENTfullI</IndexLocation>
<StreamLocation>^CDUI.DataGe372A.CHARTEVENTfullS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
