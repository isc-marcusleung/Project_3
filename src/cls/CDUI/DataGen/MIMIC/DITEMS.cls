Class CDUI.DataGen.MIMIC.DITEMS Extends %Persistent
{

Property rowId As %Integer;

Property itemid As %Integer;

Property label As %String;

Property abbriviation As %String;

Property dbsource As %String;

Property linksto As %String;

Property category As %String;

Property unitname As %String;

Property paramType As %String;

Property conceptId As %String;

Storage Default
{
<Data name="DITEMSDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>rowId</Value>
</Value>
<Value name="3">
<Value>itemId</Value>
</Value>
<Value name="4">
<Value>label</Value>
</Value>
<Value name="5">
<Value>abbriviation</Value>
</Value>
<Value name="6">
<Value>dbsource</Value>
</Value>
<Value name="7">
<Value>linksto</Value>
</Value>
<Value name="8">
<Value>category</Value>
</Value>
<Value name="9">
<Value>unitname</Value>
</Value>
<Value name="10">
<Value>paramType</Value>
</Value>
<Value name="11">
<Value>conceptId</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen.MIMIC.DITEMSD</DataLocation>
<DefaultData>DITEMSDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen.MIMIC.DITEMSD</IdLocation>
<IndexLocation>^CDUI.DataGen.MIMIC.DITEMSI</IndexLocation>
<StreamLocation>^CDUI.DataGen.MIMIC.DITEMSS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
