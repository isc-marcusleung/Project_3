Class CDUI.DataGen.vo.PatientVo Extends CDUI.DataGen.vo.BaseVo
{

Property PatientId As %String;

Property EpisodeObjList As %ListOfObjects;

Property ApptObjList As %ListOfObjects;

ClassMethod newInstance(NewPatientReq As CDUI.DataGen.Request.NewPatient, patientId As %Integer) As CDUI.DataGen.vo.PatientVo
{
    set obj = ..%New()
    set obj.PatientId = patientId
    #; set obj.ApptObjList = ##class(%ListOfObjects).%New()

    return obj
}

}
