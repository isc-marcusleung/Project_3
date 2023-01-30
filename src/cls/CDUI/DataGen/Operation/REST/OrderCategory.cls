Class CDUI.DataGen.Operation.REST.OrderCategory Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetOrderByCategory">
    <Method>GetOrderByCat</Method>
  </MapItem>
</MapItems>
}

Method GetOrderByCat(Request As CDUI.DataGen.Request.GetOrderByCategory, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
