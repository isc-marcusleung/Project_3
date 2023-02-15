Class CDUI.DataGen.Operation.REST.Episode Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewEpisode">
    <Method>createNewEpisode</Method>
  </MapItem>
  <MapItem MessageType="CDUI.DataGen.Request.GetEpisodeById">
    <Method>getEpisodeById</Method>
  </MapItem>
</MapItems>
}

Method createNewEpisode(Request As CDUI.DataGen.Request.NewEpisode, Output Response As CDUI.DataGen.DataGenService.Custom.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

Method getEpisodeById(Request As CDUI.DataGen.Request.GetEpisodeById, Output Response As Ens.StringResponse) As %Status
{
  set sc = ..httpGet(Request, .Response)
  quit sc
}

}
