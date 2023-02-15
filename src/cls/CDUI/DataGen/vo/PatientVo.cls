Class CDUI.DataGen.vo.PatientVo Extends CDUI.DataGen.vo.BaseVo
{

Property PatientId As %String;

Property PAPERName As %String;

Property PAPERName2 As %String;

Property CTSEXDesc As %String;

Property PAPERDob As %String;

Property EpisodeObjList As %ListOfObjects;

Property ApptObjList As %ListOfObjects;

ClassMethod newInstance(NewPatientReq As CDUI.DataGen.Request.NewPatient, patientId As %Integer) As CDUI.DataGen.vo.PatientVo
{
    set obj = ..%New()
    set obj.PatientId = patientId
    set obj.PAPERName = NewPatientReq.PAPERName
    set obj.PAPERName2 = NewPatientReq.PAPERName2
    set obj.CTSEXDesc = NewPatientReq.CTSEXDesc
    set obj.PAPERDob = NewPatientReq.PAPERDob
    
    return obj
}

}
