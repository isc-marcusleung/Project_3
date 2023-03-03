Class CDUI.DataGen.vo.RadResultVo Extends BaseVo
{

Property EpisodeID As %String;

Property OrderID As %String;

Property ID As %String;

Property DateReported As %String;

ClassMethod newInstance(NewResultReq, RadResultID) As CDUI.DataGen.vo.RadResultVo
{
    set obj = ..%New()
    set obj.EpisodeID = NewResultReq.EpisodeID
    set obj.OrderID = NewResultReq.OEOrdItemID
    set obj.DateReported = NewResultReq.DateReported
    set obj.ID = RadResultID

    return obj
}

}
