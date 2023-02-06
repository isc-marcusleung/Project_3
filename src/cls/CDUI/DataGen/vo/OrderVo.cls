Class CDUI.DataGen.vo.OrderVo Extends BaseVo
{

Property EpisodeID As %String;

Property ID As %String;

Property Item As %String;

Property OEORISttDat As %String;

Property OEORISttTim As %String;

ClassMethod newInstance(NewOrderReq, OrderID) As CDUI.DataGen.vo.OrderVo
{
    set obj = ..%New()
    set obj.EpisodeID = NewOrderReq.EpisodeID
    set obj.ID = OrderID
    set obj.Item = NewOrderReq.Item
    set obj.OEORISttDat = NewOrderReq.OEORISttDat
    set obj.OEORISttTim = NewOrderReq.OEORISttTim   

    return obj
}

}
