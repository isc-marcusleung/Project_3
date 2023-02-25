Import CDUI.DataGen.DataGenService.Base

Class CDUI.DataGen.Service.TestObsService Extends (%UnitTest.TestCase, Ens.Util.IOLogger, BaseService)
{

Method TestNewObs() As %Status
{
    #dim sc, status as %Status = $$$OK
    
    set input = 2
    set tExpected = 2
    do ..CreatePatientVo(.patientVoObjList)

    set obsService = ##class(CDUI.DataGen.DataGenService.ObsService).%New()

    set jobId = ##class(%PopulateUtils).Integer(1000,9999)

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set NumOfEpisode = patientVoObjList.GetAt(cnt)."EpisodeObjList".Count()

        set episodeVo = patientVo.EpisodeObjList	

        do obsService.NewObs(input, episodeVo, jobId)

        for k=1:1:episodeVo.Count(){
            do $$$LogMessage("Check number of observation sets created in each episode for patient ID "_patientVo.PatientId)
            set epItem = episodeVo.GetAt(k)
            set NumOfObs = epItem.ObsObjList.Count()
            set sc = $$$AssertEquals(tExpected,NumOfObs,"Episode: " _epItem.ID_", NumObs requested: "_tExpected_ " = NumObs created: "_NumOfObs)
            set status = $$$ADDSC(status,sc)

            
            do $$$LogMessage("Get list of observations for patient: "_patientVo.PatientId_ " in database")

            do $$$LogMessage("Check if observations are in database")
            for i=1:1:NumOfObs{
            
                set obsItem = epItem.ObsObjList.GetAt(i)
                do $$$LogMessage("Episode Id: "_obsItem.EpisodeID_" - Check if mradm: "_obsItem.mradm_ " is in database")

                set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetObsBymradm(obsItem.mradm, .obsRecordList)
                set status = $$$AssertStatusOK(sc,"Get Observations Record List")
                set status = $$$ADDSC(status,sc)

                // Check if created observation ID is in mradm database list
                set posFound = obsRecordList.Find(obsItem.ObsId)
                do $$$LogMessage("Observation position: "_posFound)
                if posFound '=0{
                     set isSuccess = 1
                 }

                set sc = $$$AssertTrue(isSuccess, "Created observation is found in database by mradm")
                set status = $$$ADDSC(status,sc)

            }
        }
    }
    quit status
}

// Create patients to test

ClassMethod CreatePatientVo(ByRef patientVoObjList) As %Status
{
	#dim sc, status as %Status = $$$OK
    set patientVoObjList =  ##class(%ListOfObjects).%New()

	// Patient 1 
	set patient1 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,18381))
	set patient1 = patientVoObjList.GetAt(1)
	set status = $$$ADDSC(sc, status)

    /// Set EpVoObjList 1
	set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    set requestEp.ID = "32529"
	set requestEp.PatientID = "18381"
	set requestEp.PAADMType = "I"
	set requestEp.PAADMAdmDate = "16/10/2002"
	set requestEp.PAADMAdmTime = "12:47"
	set requestEp.CTLOCDesc = "Urology H2"
    do patient1.EpisodeObjList.Insert(requestEp)  

    /// Set EpVoObjList 2
	#; set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    #; set requestEp.ID = "15776"
	#; set requestEp.PatientID = "12078"
	#; set requestEp.PAADMType = "O"
	#; set requestEp.PAADMAdmDate = "04/05/2015"
	#; set requestEp.PAADMAdmTime = "19:08"
	#; set requestEp.CTLOCDesc = "Endocrinology H1"
    #; do patient1.EpisodeObjList.Insert(requestEp)  

	quit status
}

ClassMethod RunTest()
{
    
    do ..CreatePatientVo(.patientVoObjList)

    set obsService = ##class(CDUI.DataGen.DataGenService.ObsService).%New()
    set jobId = ##class(%PopulateUtils).Integer(1000,9999)

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set NumOfEpisode = patientVoObjList.GetAt(cnt)."EpisodeObjList".Count()

        set episodeVo = patientVo.EpisodeObjList	

        do obsService.NewObs(2, episodeVo, jobId)
    }
    return episodeVo
}

}
