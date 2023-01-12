Class CDUI.DataGen.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="CDUI.DataGen.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="CDUI.DataGen.Operation.REST.Location" Category="" ClassName="CDUI.DataGen.Operation.REST.Location" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Credentials">auadm</Setting>
    <Setting Target="Adapter" Name="HTTPPort">52773</Setting>
    <Setting Target="Adapter" Name="HTTPServer">auxxmiscprj.iscinternal.com</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
    <Setting Target="Adapter" Name="URL">/auxxmisc-test-hmfsys/api/CTLoc</Setting>
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="EnsLib.Testing.Service" Category="" ClassName="EnsLib.Testing.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="CDUI.DataGen.Service.Adaptorless" Category="" ClassName="CDUI.DataGen.Service.Adaptorless" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="CDUI.DataGen.Process.MsgRouter.REST" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">CDUI.DataGen.Process.MsgRouter.RESTRoutingRule</Setting>
    <Setting Target="Host" Name="ForceSyncSend">1</Setting>
    <Setting Target="Host" Name="ResponseFrom">CDUI.DataGen.Operation.REST.Location</Setting>
  </Item>
</Production>
}

}
