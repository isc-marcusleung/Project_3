Class CDUI.DataGen.MIMIC.Observations Extends %Persistent
{

Property IcuStayId As %String;

Property Date As %String;

Property Hour As %String;

Property SBP As %Integer;

Property DBP As %Integer;

Property HeartRate As %Integer;

Property Respirations As %Integer;

Property Temp As %Decimal;

Property Height As %Integer;

Property Weight As %Decimal;

Index IcuStayIdIndex On IcuStayId;

Index DateIndex On Date;

Index HourIndex On Hour;

Index SBPIndex On SBP;

Index DBPIndex On DBP;

Index HRIndex On HeartRate;

Index RespIndex On Respirations;

Index TempIndex On Temp;

Index HeightIndex On Height;

Index WeightIndex On Weight;

Storage Default
{
<Data name="ObservationsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>IcuStayId</Value>
</Value>
<Value name="3">
<Value>Date</Value>
</Value>
<Value name="4">
<Value>Hour</Value>
</Value>
<Value name="5">
<Value>SBP</Value>
</Value>
<Value name="6">
<Value>DBP</Value>
</Value>
<Value name="7">
<Value>HeartRate</Value>
</Value>
<Value name="8">
<Value>Respirations</Value>
</Value>
<Value name="9">
<Value>Temp</Value>
</Value>
<Value name="10">
<Value>Height</Value>
</Value>
<Value name="11">
<Value>Weight</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen372A.ObservationsD</DataLocation>
<DefaultData>ObservationsDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen372A.ObservationsD</IdLocation>
<IndexLocation>^CDUI.DataGen372A.ObservationsI</IndexLocation>
<StreamLocation>^CDUI.DataGen372A.ObservationsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
