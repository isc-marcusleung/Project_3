Class CDUI.DataGen.vo.AppointmentVo Extends BaseVo
{

Property PatientID As %String;

Property ID As %String;

Property Date As %String;

Property StartTime As %String;

Property EndTime As %String;

ClassMethod newInstance(NewApptReq, ApptID, SlotDetailObjList) As CDUI.DataGen.vo.AppointmentVo
{
    set obj = ..%New()
    set obj.PatientID = NewApptReq.PatientID
    set obj.ID = ApptID
    set obj.Date = SlotDetailObjList.Date
    set obj.StartTime = SlotDetailObjList.StartTime
    set obj.EndTime = SlotDetailObjList.EndTime 

    return obj
}

}
