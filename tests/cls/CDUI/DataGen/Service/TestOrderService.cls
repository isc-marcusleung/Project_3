Import CDUI.DataGen.DataGenService.Base

Class CDUI.DataGen.Service.TestOrderService Extends (%UnitTest.TestCase, Ens.Util.IOLogger, BaseService)
{

// Test if number of new orders request is same as number of orders created

Method TestNewOrder() As %Status
{
    
    #dim sc, status as %Status = $$$OK
    
    set input = 2
    set tExpected = 2
    do ..CreatePatientVo(.patientVoObjList)

    set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set NumOfEpisode = patientVoObjList.GetAt(cnt)."EpisodeObjList".Count()

        set episodeVo = patientVo.EpisodeObjList	

        set list = $LISTBUILD("Radiology", "Consultation", "Laboratory")
        set category = $LIST(list, ##class(%Library.PopulateUtils).Random($LL(list)) + 1)	

        do $$$LogMessage("Category requested: "_category)
		do orderService.NewOrder(input, category, episodeVo)

        for k=1:1:episodeVo.Count(){
            do $$$LogMessage("Check number of orders created in each episode for patient ID "_patientVo.PatientId)
            set epItem = episodeVo.GetAt(k)
            set val = epItem.OrderObjList.Count()
            set sc = $$$AssertEquals(tExpected,val,"Episode: " _epItem.ID_", NumOrders requested: "_tExpected_ " = NumOrders created: "_val)
            set status = $$$ADDSC(status,sc)
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
	set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11995))
	set patient1 = patientVoObjList.GetAt(1)
	set status = $$$ADDSC(sc, status)

    /// Set EpVoObjList
	set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    set requestEp.ID = "15733"
	set requestEp.PatientID = "11995"
	set requestEp.PAADMType = "O"
	set requestEp.PAADMAdmDate = "09/07/1984"
	set requestEp.PAADMAdmTime = "08:20"
	set requestEp.CTLOCDesc = "Cardiology H2"
    do patient1.EpisodeObjList.Insert(requestEp)  

    /// Set EpVoObjList
	set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    set requestEp.ID = "15734"
	set requestEp.PatientID = "11995"
	set requestEp.PAADMType = "E"
	set requestEp.PAADMAdmDate = "25/12/1975"
	set requestEp.PAADMAdmTime = "23:30"
	set requestEp.CTLOCDesc = "Rehabilitation H1"
    do patient1.EpisodeObjList.Insert(requestEp)  


	quit status
}

}
