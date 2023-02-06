Class CDUI.DataGen.Operation.REST.Observation Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewObservation">
    <Method>createNewObservation</Method>
  </MapItem>
</MapItems>
}

Method createNewObservation(Request As CDUI.DataGen.Request.NewObservation, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
