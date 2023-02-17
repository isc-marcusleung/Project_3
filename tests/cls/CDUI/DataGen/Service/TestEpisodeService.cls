Import CDUI.DataGen.DataGenService.Base

Class CDUI.DataGen.Service.TestEpisodeService Extends (%UnitTest.TestCase, Ens.Util.IOLogger, BaseService)
{

// Test if number of new episodes request is same as number of episodes created

Method TestNewEpisode() As %Status
{
    
    #dim sc, status as %Status = $$$OK
    
    set input = 2
    set tExpected = 2
    do ..CreatePatientVo(.patientVoObjList)

    set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()
	do episodeService.NewEpisode(input, .patientVoObjList)

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set NumOfEpisode = patientVo.EpisodeObjList.Count()
        set sc = $$$AssertEquals(tExpected,NumOfEpisode,"Correct number of episodes created")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("NumOfEpisode: "_NumOfEpisode)
        for i=1:1:NumOfEpisode{
            
            set epVo = patientVo.EpisodeObjList.GetAt(i)
            do $$$LogMessage("Check if episode id: "_epVo.ID_" is in database")

            set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetEpisodeById(epVo.ID, .epRecordList)
            set status = $$$AssertStatusOK(sc,"Get Episode Record List")
            set status = $$$ADDSC(status,sc)

            do $$$LogMessage("Check if episode details are the same with database's details for episode Id "_epVo.ID)
            set sc = $$$AssertEquals(epVo.ID,$listget($listget(epRecordList,1),-1))
            set sc = $$$AssertEquals(epVo.PatientID,$listget($listget(epRecordList,2),-1))
            set sc = $$$AssertEquals(epVo.PAADMType,$listget($listget(epRecordList,3),-1))
            set sc = $$$AssertEquals(epVo.PAADMAdmDate,$listget($listget(epRecordList,4),-1))
            set sc = $$$AssertEquals(epVo.PAADMAdmTime,$listget($listget(epRecordList,5),-1))
            set sc = $$$AssertEquals(epVo.CTLOCDesc,$listget($listget(epRecordList,6),-1))
            set status = $$$ADDSC(status,sc)
        }

    }
    quit status
}

// Create patients to test

Method CreatePatientVo(ByRef patientVoObjList) As %Status
{
	#dim sc, status as %Status = $$$OK
    set patientVoObjList =  ##class(%ListOfObjects).%New()

	// Patient 1 
	set patient1 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11995))
	set patient1 = patientVoObjList.GetAt(1)
	set status = $$$ADDSC(sc, status)

	#; // Patient 2 
	#; set patient2 =  ##class(%ListOfObjects).%New()
	#; set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
    #; set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11996))
	#; set patient2 = patientVoObjList.GetAt(2)
    #; set status = $$$ADDSC(sc, status)

	quit status
}

}
