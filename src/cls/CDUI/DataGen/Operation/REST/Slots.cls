Class CDUI.DataGen.Operation.REST.Slots Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.Slots">
    <Method>getSlots</Method>
  </MapItem>
</MapItems>
}

Method getSlots(Request As CDUI.DataGen.Request.Slots, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
