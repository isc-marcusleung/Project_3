Class CDUI.DataGen.Service.TestApptService Extends (%UnitTest.TestCase, Ens.Util.IOLogger)
{

Method TestNewAppt()
{
    #dim status, sc as %Status = $$$OK
	#dim val as %String = ""

    set input = 2
    set tExpected = 2
    do ..CreatePatientVo(.patientVoObjList)
    do ##class(CDUI.DataGen.DataGenService.ApptService).NewAppt(input, .patientVoObjList)

    for cnt=1:1:patientVoObjList.Count() {
        set patientVo = patientVoObjList.GetAt(cnt)
        set apptVo = patientVo.ApptObjList
        set val = apptVo.Count()
        set status = $$$AssertEquals(val, tExpected,"Correct number of appointments created")
    }
    quit status
}

/// Set up patients for test.
ClassMethod CreatePatientVo(ByRef patientVoObjList) As %Status
{
	#; #dim status, sc as %Status = $$$OK
	#; 
	set sc = $$$OK

    set patientVoObjList =  ##class(%ListOfObjects).%New()

	// Patient 1 YAY Day
	set patient1 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	set status = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11754))

	set patient1 = patientVoObjList.GetAt(1)

    If $$$ISOK(status)
    {
        $$$LOGINFO("Patient 1 created.")
    }

	set sc = $$$ADDSC(sc, status)
	$$$LOGINFO("Value of sc after p1: "_sc)

	/// Set ApptVoObjList
	set requestAppt = ##class(CDUI.DataGen.vo.AppointmentVo).%New()
	set requestAppt.PatientID = "11754"
	set requestAppt.ID = "350||44164||1"
	set requestAppt.Date = "03/02/2023"
	set requestAppt.StartTime = "11:15"
	set requestAppt.EndTime = "13:45"

	do patient1.ApptObjList.Insert(requestAppt)  

	// Patient 2 JOY Day
	set patient2 =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	#; do patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11732))
    #; 
    set status = patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11732))

	set patient2 = patientVoObjList.GetAt(2)

	
	/// Set ApptVoObjList
	#; set requestAppt = ##class(CDUI.DataGen.vo.AppointmentVo).%New()
	#; set requestAppt.PatientID = "11732"
	#; set requestAppt.ID = "350||44157||1"
	#; set requestAppt.Date = "03/02/2023"
	#; set requestAppt.StartTime = "09:30"
	#; set requestAppt.EndTime = "12:00"

	#; do patient2.ApptObjList.Insert(requestAppt)  
	
	#; set status = $$$ADDSC(status,sc)

    If $$$ISOK(status)
    {
        $$$LOGINFO("Patient 2 created.")
    }

	set sc = $$$ADDSC(sc, status)
	$$$LOGINFO("Value of sc after p2: "_sc)

	quit sc
}

Method TestTwo() As %Status
{
    set sc = $$$OK
    #; do $$$AssertEquals("2", "2", "should be equal")

    #; set status = ##class(%ListOfObjects).%New()
	set status = ##class(CDUI.DataGen.Request.NewPatient).%New()
	set sc1 = 1 + 1

    set sc = $$$ADDSC(sc, sc1)

    return sc
}

}
