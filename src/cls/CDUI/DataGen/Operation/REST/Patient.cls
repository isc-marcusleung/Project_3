Class CDUI.DataGen.Operation.REST.Patient Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewPatient">
    <Method>createNewPatient</Method>
  </MapItem>
</MapItems>
}

Method createNewPatient(Request As CDUI.DataGen.Request.NewPatient, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
