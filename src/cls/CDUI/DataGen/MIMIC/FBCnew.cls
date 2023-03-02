Class CDUI.DataGen.MIMIC.FBCnew Extends %Persistent
{

Property SubjectId As %String;

Property Date As %String;

Property Hour As %String;

Property WBC As %Integer;

Property RBC As %Integer;

Property HB As %Integer;

Property HCT As %Integer;

Property MCV As %Integer;

Property MCH As %Integer;

Property MCHC As %Integer;

Property RDW As %Integer;

Property PLT As %Integer;

Storage Default
{
<Data name="FBCnewDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SubjectId</Value>
</Value>
<Value name="3">
<Value>Date</Value>
</Value>
<Value name="4">
<Value>Hour</Value>
</Value>
<Value name="5">
<Value>WBC</Value>
</Value>
<Value name="6">
<Value>RBC</Value>
</Value>
<Value name="7">
<Value>HB</Value>
</Value>
<Value name="8">
<Value>HCT</Value>
</Value>
<Value name="9">
<Value>MCV</Value>
</Value>
<Value name="10">
<Value>MCH</Value>
</Value>
<Value name="11">
<Value>MCHC</Value>
</Value>
<Value name="12">
<Value>RDW</Value>
</Value>
<Value name="13">
<Value>PLT</Value>
</Value>
</Data>
<DataLocation>^CDUI.DataGen.MIMIC.FBCnewD</DataLocation>
<DefaultData>FBCnewDefaultData</DefaultData>
<IdLocation>^CDUI.DataGen.MIMIC.FBCnewD</IdLocation>
<IndexLocation>^CDUI.DataGen.MIMIC.FBCnewI</IndexLocation>
<StreamLocation>^CDUI.DataGen.MIMIC.FBCnewS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
