Class CDUI.DataGen.Operation.REST.GetObsBymradm Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetObsBymradm">
    <Method>GetObsBymradm</Method>
  </MapItem>
</MapItems>
}

Method GetObsBymradm(Request As CDUI.DataGen.Request.GetObsBymradm, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
