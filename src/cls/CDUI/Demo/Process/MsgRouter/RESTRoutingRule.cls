/// 
Class CDUI.Demo.Process.MsgRouter.RESTRoutingRule Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="CDUI.Demo.Production">
<ruleSet name="REST" effectiveBegin="" effectiveEnd="">
<rule name="Location">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.Location"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.Location"></send>
<return></return>
</when>
</rule>
<rule name="" disabled="true">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.NewLocation"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.Location"></send>
<return></return>
</when>
</rule>
<rule name="Patient">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.NewPatient"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.Patient"></send>
<return></return>
</when>
</rule>
<rule name="ARCAuxilInsurType">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.ARCAuxilInsurType"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.ARCAuxilInsurType"></send>
<return></return>
</when>
</rule>
<rule name="Episode">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.NewEpisode"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.Episode"></send>
<return></return>
</when>
</rule>
<rule name="ARCItmMast">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.ARCItmMast"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.ARCItmMast"></send>
<return></return>
</when>
</rule>
<rule name="Order">
<constraint name="source" value="CDUI.Demo.Service.Adaptorless"></constraint>
<constraint name="msgClass" value="CDUI.Demo.Request.NewOrder"></constraint>
<when condition="1">
<send transform="" target="CDUI.Demo.Operation.REST.Order"></send>
<return></return>
</when>
</rule>
</ruleSet>
</ruleDefinition>
}

}
