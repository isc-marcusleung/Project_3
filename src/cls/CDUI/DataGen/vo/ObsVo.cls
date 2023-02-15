Class CDUI.DataGen.vo.ObsVo Extends BaseVo
{

Property ObsId As %String;

Property PatientID As %String;

Property mradm As %String;

Property EpisodeID As %String;

Property ObsDate As %String;

Property ObsTime As %String;

Property OBSENTRYPatLocDesc As %String;

Property TableItems As %ListOfObjects;

// req is from request body, ObsId is from response body

ClassMethod newInstance(NewObsReq, ObsId) As CDUI.DataGen.vo.ObsVo
{
    set obj = ..%New()
    set obj.ObsId = ObsId
    set obj.PatientID = NewObsReq.PatientID
    set obj.mradm = NewObsReq.mradm
    set obj.EpisodeID = NewObsReq.EpisodeID
    set obj.ObsDate = NewObsReq.ObsDate
    set obj.ObsTime = NewObsReq.ObsTime
    set obj.OBSENTRYPatLocDesc = NewObsReq.OBSENTRYPatLocDesc
    set obj.TableItems = NewObsReq.TableItems
    return obj
}

}
