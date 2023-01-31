Class CDUI.DataGen.Operation.REST.LocationServices Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.LocationServices">
    <Method>getLocationServicesList</Method>
  </MapItem>
</MapItems>
}

Method getLocationServicesList(Request As CDUI.DataGen.Request.LocationServices, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
