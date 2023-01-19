/// 
Class CDUI.DataGen.Process.MsgRouter.RESTRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="CDUI.DataGen.Production">
<ruleSet name="REST" effectiveBegin="" effectiveEnd="">
<rule name="Location">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.Location"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.Location"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="true">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewLocation"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.Location"></send>
<return></return>
</when>
</rule>
<rule name="Patient">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewPatient"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.Patient"></send>
<return></return>
</when>
</rule>
<rule name="ARCAuxilInsurType">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.ARCAuxilInsurType"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.ARCAuxilInsurType"></send>
<return></return>
</when>
</rule>
<rule name="Episode">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewEpisode"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.Episode"></send>
<return></return>
</when>
</rule>
<rule name="ARCItmMast">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.ARCItmMast"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.ARCItmMast"></send>
<return></return>
</when>
</rule>
<rule name="Order">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewOrder"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.Order"></send>
<return></return>
</when>
</rule>
<rule name="LabOrder">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewLabOrder"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.LabOrder"></send>
<return></return>
</when>
</rule>
<rule name="RadResult">
<constraint name="source" value="CDUI.DataGen.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.DataGen.Request.NewRadResult"></constraint>
<when condition="1">
<send transform="" target="CDUI.DataGen.Operation.REST.RadResult"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
