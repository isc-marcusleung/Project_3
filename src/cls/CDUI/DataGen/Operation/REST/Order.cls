Class CDUI.DataGen.Operation.REST.Order Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewOrder">
    <Method>createNewOrder</Method>
  </MapItem>
</MapItems>
}

Method createNewOrder(Request As CDUI.DataGen.Request.NewOrder, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
