Class CDUI.DataGen.vo.AppointmentVo Extends BaseVo
{

Property PatientID As %String;

Property ID As %String;

// Property Date As %String;

// Property SessStartTime As %String;

// Property SessEndTime As %String;

ClassMethod newInstance(NewApptReq, ApptID) As CDUI.DataGen.vo.AppointmentVo
{
    set obj = ..%New()
    set obj.PatientID = NewApptReq.PatientID
    set obj.ID = ApptID
    #; set obj.Date = NewApptReq.Date
    #; set obj.SessStartTime = NewApptReq.SessStartTime
    #; set obj.SessEndTime = NewApptReq.SessEndTime   

    return obj
}

}
