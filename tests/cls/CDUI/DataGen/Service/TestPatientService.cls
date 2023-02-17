Import CDUI.DataGen.DataGenService.Base

Class CDUI.DataGen.Service.TestPatientService Extends (%UnitTest.TestCase, Ens.Util.IOLogger, BaseService)
{

// Test if number of new patients request is same as number of patients created

Method TestNewPatient() As %Status
{
    
    #dim sc, status as %Status = $$$OK

    set input = 2
    set tExpected = 2
    set patientService = ##class(CDUI.DataGen.DataGenService.PatientService).%New()
	do patientService.NewPatient(input, .PatientVoObjList)
    set numOfPat = PatientVoObjList.Count()
    set sc = $$$AssertEquals(tExpected, numOfPat,"Correct number of patients created")
    set status = $$$ADDSC(status,sc)
    
    do $$$LogMessage("Check if patient records are in database")

    for cnt=1:1:numOfPat{

        k patRecordList
        set patientVo = PatientVoObjList.GetAt(cnt)

        do $$$LogMessage("Check if patient Id: "_patientVo.PatientId_" is in database")
        set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetPatientById(patientVo.PatientId, .patRecordList)
        set status = $$$AssertStatusOK(sc,"Get Patient Record List")
        set status = $$$ADDSC(status,sc)
        
        set patDetailsList = $listbuild(
            $listbuild("PAPERName",patientVo.PAPERName),
            $listbuild("PAPERName2",patientVo.PAPERName2),
            $listbuild("CTSEXDesc",patientVo.CTSEXDesc),
            $listbuild("PAPERDob",patientVo.PAPERDob)
		)
        
        do $$$LogMessage("Check if patients details are the same with database's details for patient Id "_patientVo.PatientId)
        set sc = $$$AssertTrue($LISTSAME(patRecordList,patDetailsList),"Same details")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

}
