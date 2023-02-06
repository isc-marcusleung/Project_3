Class CDUI.DataGen.Operation.REST.Appointment Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewAppointment">
    <Method>createNewAppointment</Method>
  </MapItem>
</MapItems>
}

Method createNewAppointment(Request As CDUI.DataGen.Request.NewAppointment, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
