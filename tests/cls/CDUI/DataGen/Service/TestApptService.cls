Class CDUI.DataGen.Service.TestApptService Extends (%UnitTest.TestCase, Ens.Util.IOLogger)
{

Method TestNewAppt()
{
    #dim status, sc as %Status = $$$OK
	#dim val as %String = ""

    set input = 1
    set tExpected = 1
    do ..CreatePatientVo(.patientVoObjList)

	set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()
    do apptService.NewAppt(input, .patientVoObjList)

	// Set apptItemList for testing if time clashes
	set apptItemList = ##class(%ListOfObjects).%New()

    for cnt=1:1:patientVoObjList.Count() {
		
        set patientVo = patientVoObjList.GetAt(cnt)
        set apptVo = patientVo.ApptObjList
        set NumOfAppt = apptVo.Count()

		do $$$LogMessage("Check number of appointments created for patient ID "_patientVo.PatientId_" is: "_NumOfAppt)
        set sc = $$$AssertEquals(tExpected, NumOfAppt,"Correct number of appointments created")
		set status = $$$ADDSC(status,sc)

		do $$$LogMessage("Check if appointments are in database")
		for i=1:1:NumOfAppt{
			set apptItem = apptVo.GetAt(i)
			do apptItemList.Insert(apptItem)
			
			do $$$LogMessage("Check if appt ID: "_apptItem.ID_", date: "_apptItem.Date_", time: "_apptItem.StartTime_" is in database")
			set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetApptById(apptItem.ID, .apptRecordList)
            set status = $$$AssertStatusOK(sc,"Get Appt Record List")
            set status = $$$ADDSC(status,sc)

			do $$$LogMessage("Check if patients details are the same with database's details for appt Id: "_apptItem.ID)
			set sc = $$$AssertEquals(patientVo.PatientId,$listget($listget(apptRecordList,1),-1))
            set sc = $$$AssertEquals(apptItem.Date,$listget($listget(apptRecordList,2),-1))
            set sc = $$$AssertEquals(apptItem.StartTime,$listget($listget(apptRecordList,3),-1))
			set status = $$$ADDSC(status,sc)
		}

    }
    quit status
}

/// Set up patients for test.
Method CreatePatientVo(ByRef patientVoObjList) As %Status
{
    #dim status, sc as %Status = $$$OK
	
	set patientVoObjList =  ##class(%ListOfObjects).%New()

	// Patient 1
	set patient1 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,12265))
	set status = $$$ADDSC(status,sc)
	set patient1 = patientVoObjList.GetAt(1)

	// Patient 2 
	set patient2 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
    set sc = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,12266))
	set status = $$$ADDSC(status,sc)
	set patient2 = patientVoObjList.GetAt(2)

	quit status
}

ClassMethod CheckTime(apptItemList) As %Status
{
	set numOfItem = apptItemList.Count()
	for i=1:1:numOfItem{

		set apptItem = apptItemList.GetAt(i)
		for j=i+1:1:numOfItem {
			// if item(i) same with item(j)
			set sc = ..CheckTwoAppts(apptItem.GetAt(i), apptItem.GetAt(j))
			set status = $$$ADDSC(status,sc)
		}
	}
}

ClassMethod CheckTwoAppts(apptItem1, apptItem2) As %Status
{
	#dim status, sc as %Status = $$$OK

	if apptItem1.Date '= apptItem2.Date {
		set sc = $$$OK
		set status = $$$ADDSC(status,sc)
	}
	// If same date
	else {
		if (($tr(apptItem1.StartTime,":","") > $tr(apptItem2.EndTime,":","")) && ($tr(apptItem2.StartTime,":","") < $tr(apptItem1.EndTime,":",""))){
			set sc = $$$OK
			set status = $$$ADDSC(status,sc)
		}
	}
	quit status
}

}
