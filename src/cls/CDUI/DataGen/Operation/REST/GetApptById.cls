Class CDUI.DataGen.Operation.REST.GetApptById Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetApptById">
    <Method>GetApptById</Method>
  </MapItem>
</MapItems>
}

Method GetApptById(Request As CDUI.DataGen.Request.GetApptById, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGetById(Request, .Response)
	quit sc
}

}
