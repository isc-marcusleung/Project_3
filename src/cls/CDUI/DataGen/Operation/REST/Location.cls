Class CDUI.DataGen.Operation.REST.Location Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.Location">
    <Method>getLocationList</Method>
  </MapItem>
  <MapItem MessageType="CDUI.DataGen.Request.NewLocation">
    <Method>createNewLocation</Method>
  </MapItem>
</MapItems>
}

Method getLocationList(Request As CDUI.DataGen.Request.Location, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

Method createNewLocation(Request As CDUI.DataGen.Request.NewLocation, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
