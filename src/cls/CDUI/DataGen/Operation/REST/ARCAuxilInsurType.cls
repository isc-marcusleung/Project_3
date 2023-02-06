Class CDUI.DataGen.Operation.REST.ARCAuxilInsurType Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.ARCAuxilInsurType">
    <Method>getARCAuxilInsurTypeList</Method>
  </MapItem>
</MapItems>
}

Method getARCAuxilInsurTypeList(Request As CDUI.DataGen.Request.ARCAuxilInsurType, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGet(Request, .Response)
	quit sc
}

}
