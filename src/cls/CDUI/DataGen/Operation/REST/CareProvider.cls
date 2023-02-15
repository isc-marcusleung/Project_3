Class CDUI.DataGen.Operation.REST.CareProvider Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetCareProvider">
    <Method>GetCareProvider</Method>
  </MapItem>
</MapItems>
}

Method GetCareProvider(Request As CDUI.DataGen.Request.GetCareProvider, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
