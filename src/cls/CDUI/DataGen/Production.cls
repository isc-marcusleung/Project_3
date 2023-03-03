Class CDUI.DataGen.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="CDUI.DataGen.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="CDUI.DataGen.Operation.REST.Location" Category="" ClassName="CDUI.DataGen.Operation.REST.Location" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting> <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/CTLoc</Setting>  <!-- Please config it -->
    <Setting Target="Host" Name="ArchiveIO">1</Setting>
  </Item>
  <Item Name="EnsLib.Testing.Service" Category="" ClassName="EnsLib.Testing.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="CDUI.DataGen.Service.Adaptorless" Category="" ClassName="CDUI.DataGen.Service.Adaptorless" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="CDUI.DataGen.Process.MsgRouter.REST" Category="" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">CDUI.DataGen.Process.MsgRouter.RESTRoutingRule</Setting>
    <Setting Target="Host" Name="ForceSyncSend">1</Setting>
    <Setting Target="Host" Name="ResponseFrom">CDUI.DataGen.Operation.REST.Location,CDUI.DataGen.Operation.REST.ARCAuxilInsurType,CDUI.DataGen.Operation.REST.ARCItmMast,CDUI.DataGen.Operation.REST.Episode,CDUI.DataGen.Operation.REST.Order,CDUI.DataGen.Operation.REST.Patient,CDUI.DataGen.Operation.REST.OrderCategory,CDUI.DataGen.Operation.REST.LocationServices,CDUI.DataGen.Operation.REST.Slots,CDUI.DataGen.Operation.REST.Appointment,CDUI.DataGen.Operation.REST.CareProvider,CDUI.DataGen.Operation.REST.GetPatient,CDUI.DataGen.Operation.REST.GetPatientById,CDUI.DataGen.Operation.REST.GetEpisodeById,CDUI.DataGen.Operation.REST.GetOrderByPatientId,CDUI.DataGen.Operation.REST.GetApptById,CDUI.DataGen.Operation.REST.Observation</Setting>
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.ARCAuxilInsurType" Category="" ClassName="CDUI.DataGen.Operation.REST.ARCAuxilInsurType" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">auxxmisc-test/api/ARCAuxilInsurType</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.ARCItmMast" Category="" ClassName="CDUI.DataGen.Operation.REST.ARCItmMast" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/ARCItmMast</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Order" Category="" ClassName="CDUI.DataGen.Operation.REST.Order" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/OEOrder/Order</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Patient" Category="" ClassName="CDUI.DataGen.Operation.REST.Patient" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/PAPerson</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Episode" Category="" ClassName="CDUI.DataGen.Operation.REST.Episode" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/PAAdm</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.OrderCategory" Category="" ClassName="CDUI.DataGen.Operation.REST.OrderCategory" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/csp/CDUI/cdu/GetOrders</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.LocationServices" Category="" ClassName="CDUI.DataGen.Operation.REST.LocationServices" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/RBCServicesResource/FindList</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Slots" Category="" ClassName="CDUI.DataGen.Operation.REST.Slots" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/RBAppointment/ApptList</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Appointment" Category="" ClassName="CDUI.DataGen.Operation.REST.Appointment" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/RBAppointment/BookAppt</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.CareProvider" Category="" ClassName="CDUI.DataGen.Operation.REST.CareProvider" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/csp/CDUI/cdu/GetCareProviders</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.GetPatientById" Category="" ClassName="CDUI.DataGen.Operation.REST.GetPatientById" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/PAPerson</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.GetEpisodeById" Category="" ClassName="CDUI.DataGen.Operation.REST.GetEpisodeById" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/PAAdm</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.GetOrderByPatientId" Category="" ClassName="CDUI.DataGen.Operation.REST.GetOrderByPatientId" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/OEOrdItemEMR</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.GetApptById" Category="" ClassName="CDUI.DataGen.Operation.REST.GetApptById" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/RBAppointment</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.Observation" Category="" ClassName="CDUI.DataGen.Operation.REST.Observation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/MRObservations</Setting>  <!-- Please config it -->
  </Item>
  <Item Name="CDUI.DataGen.Operation.REST.RadResult" Category="" ClassName="CDUI.DataGen.Operation.REST.RadResult" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPPort"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="HTTPServer"></Setting>  <!-- Please config it -->
    <Setting Target="Adapter" Name="URL">/auxxmisc-test/api/OETextResult</Setting>  <!-- Please config it -->
  </Item>  
</Production>
}

}
