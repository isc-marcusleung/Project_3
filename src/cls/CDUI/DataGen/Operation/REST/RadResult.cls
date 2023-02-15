Class CDUI.DataGen.Operation.REST.RadResult Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewRadResult">
    <Method>createNewRadResult</Method>
  </MapItem>
</MapItems>
}

Method createNewRadResult(Request As CDUI.DataGen.Request.NewRadResult, Output Response As CDUI.DataGen.DataGenService.Custom.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
