Class CDUI.DataGen.Operation.REST.GetOrderByPatientId Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetOrderByPatientId">
    <Method>GetOrderByPatientId</Method>
  </MapItem>
</MapItems>
}

Method GetOrderByPatientId(Request As CDUI.DataGen.Request.GetOrderByPatientId, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
