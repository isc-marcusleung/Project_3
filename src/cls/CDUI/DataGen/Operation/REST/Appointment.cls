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

  s ^cn($i(^cn),"before") = Request.SerialisedGet()
	set sc = ..httpPut(Request, .Response)
  s ^cn($i(^cn),"after") = Request.SerialisedGet()
  quit sc
}

}
