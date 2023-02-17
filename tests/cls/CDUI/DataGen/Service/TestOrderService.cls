Import CDUI.DataGen.DataGenService.Base

Class CDUI.DataGen.Service.TestOrderService Extends (%UnitTest.TestCase, Ens.Util.IOLogger, BaseService)
{

// Test if number of new orders request is same as number of orders created

Method TestNewOrder() As %Status
{
    
    #dim sc, status as %Status = $$$OK
    
    set input = 1
    set tExpected = 1
    set isSuccess = 0
    do ..CreatePatientVo(.patientVoObjList)

    set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set NumOfEpisode = patientVoObjList.GetAt(cnt)."EpisodeObjList".Count()

        set episodeVo = patientVo.EpisodeObjList	

        // TO DO - CN to uncomment and make category random - currently testing Laboratory only
        #; set list = $LISTBUILD("Radiology", "Consultation", "Laboratory")
        #; set category = $LIST(list, ##class(%Library.PopulateUtils).Random($LL(list)) + 1)	

        #; do $$$LogMessage("Category requested: "_category)
		#; do orderService.NewOrder(input, category, episodeVo)

        do orderService.NewOrder(input, "Laboratory", episodeVo)

        for k=1:1:episodeVo.Count(){
            do $$$LogMessage("Check number of orders created in each episode for patient ID "_patientVo.PatientId)
            set epItem = episodeVo.GetAt(k)
            set NumOfOrder = epItem.OrderObjList.Count()
            set sc = $$$AssertEquals(tExpected,NumOfOrder,"Episode: " _epItem.ID_", NumOrders requested: "_tExpected_ " = NumOrders created: "_NumOfOrder)
            set status = $$$ADDSC(status,sc)

            
            do $$$LogMessage("Get list of orders for patient: "_patientVo.PatientId_ " in database")

            set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetOrderByPatientId(patientVo.PatientId, .orderDBRecordList)
            set status = $$$AssertStatusOK(sc,"Get Order Record List")
            set status = $$$ADDSC(status,sc)

            do $$$LogMessage("Check if orders are in database")
            for i=1:1:NumOfOrder{
                
                set ordItem = epItem.OrderObjList.GetAt(i)
                do $$$LogMessage("Episode Id: "_ordItem.EpisodeID_" - Check if order ID: "_ordItem.ID_ " is in database")

                // Check if created order ID is in patient's orders database list
                set posFound = $LISTFIND(orderDBRecordList, ordItem.ID)
                do $$$LogMessage("Order position: "_posFound)
                if posFound '=0{
                    set isSuccess = 1
                }

                set sc = $$$AssertTrue(isSuccess, "Created order is found in database")
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
	set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,12078))
	set patient1 = patientVoObjList.GetAt(1)
	set status = $$$ADDSC(sc, status)

    /// Set EpVoObjList 1
	set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    set requestEp.ID = "15775"
	set requestEp.PatientID = "12078"
	set requestEp.PAADMType = "O"
	set requestEp.PAADMAdmDate = "09/10/1974"
	set requestEp.PAADMAdmTime = "12:10"
	set requestEp.CTLOCDesc = "ENT Ears Nose Throat H2"
    do patient1.EpisodeObjList.Insert(requestEp)  

    /// Set EpVoObjList 2
	set requestEp = ##class(CDUI.DataGen.vo.EpisodeVo).%New()
    set requestEp.ID = "15776"
	set requestEp.PatientID = "12078"
	set requestEp.PAADMType = "O"
	set requestEp.PAADMAdmDate = "04/05/2015"
	set requestEp.PAADMAdmTime = "19:08"
	set requestEp.CTLOCDesc = "Endocrinology H1"
    do patient1.EpisodeObjList.Insert(requestEp)  

	quit status
}

}
