Class CDUI.DataGen.Operation.REST.GetEpisodeById Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.GetEpisodeById">
    <Method>GetEpisodeById</Method>
  </MapItem>
</MapItems>
}

Method GetEpisodeById(Request As CDUI.DataGen.Request.GetEpisodeById, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpGetById(Request, .Response)
	quit sc
}

}
