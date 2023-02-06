Class CDUI.DataGen.Operation.REST.ARCItmMast Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.ARCItmMast">
    <Method>getARCItmMastList</Method>
  </MapItem>
</MapItems>
}

Method getARCItmMastList(Request As CDUI.DataGen.Request.ARCItmMast, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
