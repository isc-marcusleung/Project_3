Class CDUI.DataGen.Operation.REST.LabOrder Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewLabOrder">
    <Method>createNewLabOrder</Method>
  </MapItem>
</MapItems>
}

Method createNewLabOrder(Request As CDUI.DataGen.Request.NewLabOrder, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
