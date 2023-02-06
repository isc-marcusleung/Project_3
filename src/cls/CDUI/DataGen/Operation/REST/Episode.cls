Class CDUI.DataGen.Operation.REST.Episode Extends CDUI.DataGen.Operation.REST.BaseOperation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.DataGen.Request.NewEpisode">
    <Method>createNewEpisode</Method>
  </MapItem>
</MapItems>
}

Method createNewEpisode(Request As CDUI.DataGen.Request.NewEpisode, Output Response As Ens.StringResponse) As %Status
{
	set sc = ..httpPut(Request, .Response)
	quit sc
}

}
