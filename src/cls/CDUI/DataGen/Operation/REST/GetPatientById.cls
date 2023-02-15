Class CDUI.DataGen.Operation.REST.GetPatientById Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetPatientById">
    <Method>GetPatientById</Method>
  </MapItem>
</MapItems>
}

Method GetPatientById(Request As CDUI.DataGen.Request.GetPatientById, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGetById(Request, .Response)
	quit sc
}

}
