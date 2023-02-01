Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ApptService Extends BaseService
{

Method NewAppt(NumOfApptPerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
    set totalSuccess = 0
    set totalFailure = 0
    
    // kill failedByPatientIdArr

	//Retrieve the location service list
	$$$LOGINFO("[ApptService.NewAppt] Retrieve the location service")
    set sc = ##class(TrakCareService).GetLocationServices(,.locServObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[ApptService.NewAppt] Failed to get location Service")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    // Get a random serviceId
    if $Data(locServObjList) && (locServObjList.Count() > 0)
    {
        set randServIndex = ##class(PUtil).Random(locServObjList.Count()) + 1
        set servItem = locServObjList.GetAt(randServIndex)
        set servId = servItem.RowID
        $$$LOGINFO("[ApptService.NewAppt] Service ID: "_servId)
    }

    // Retrieve the slots list
	$$$LOGINFO("[ApptService.NewAppt] Retrieve the slots")
    set sc = ##class(TrakCareService).GetSlots(,servId,,.slotsObjList)
	if $$$ISERR(sc)
	{
	    $$$LOGERROR("[ApptService.NewAppt] Failed to get slots")
	    Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    $$$LOGINFO("[ApptService.NewAppt] Number of patient: "_PatientVoObjList.Count())
    $$$LOGINFO("[ApptService.NewAppt] Number of appointments per patient: "_NumOfApptPerPatient)

    set numOfLoop = PatientVoObjList.Count()

    for cnt=1:1:numOfLoop{
        set patientVo = PatientVoObjList.GetAt(cnt)

        $$$LOGINFO("[ApptService.NewAppt] Initialize appointment request, patient Id: "_patientVo.PatientId)

        $$$LOGINFO("[ApptService.NewAppt] Create new appointment")
        
        // Is this ByRef ApptOutput here??? 
        // Need to put in the list of existing appointments of a patient

        // Get existing appointment object lists of a patient
        set apptOutput = patientVo.ApptObjList

        do ..InitApptRequestPerPatientByRandom(slotsObjList, NumOfApptPerPatient, patientVo, .apptOutput)
    #;     set episodeOutput = ##class(CDUI.DataGen.DataGenService.Custom.EpisodeOutput).%New()

    #;     do ..RunWithRetry(episodeInput, episodeOutput,)

    #;     //set the inserted episodeVo back to patient for further use if necessary
    #;     set patientVo.EpisodeObjList = episodeOutput.EpisodeVoObjList

    #;     set episodeIdList = episodeOutput.EpisodeIdList

    }
}

Method InitApptRequestPerPatientByRandom(slotsObjList As %ListOfObjects, NumOfApptPerPatient As %Integer, patientVo As CDUI.DataGen.vo.PatientVo, ByRef apptOutput As %ListOfObjects) [ Private ]
{
    for cnt=1:1:NumOfApptPerPatient{

        // Randomly select the insurance record from insurTypeObjList 		
        if $Data(slotsObjList) && (slotsObjList.Count() > 0)
        {
            set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
            set slot = slotsObjList.GetAt(randslotIndex)
            
        }

        // Get slot time
        set slotDate = slot.Date 
        set slotStartTime = slot.StartTime
        set slotEndTime = slot.EndTime 

        // Get date, start time, end time of existing appointments


        // Compare if appoinments don't clash



        // Handle USRN with blank string in the beginning 



        // Set up the appointment request 
        set request = ##class(CDUI.DataGen.Request.NewAppointment).%New()
        set PatientID = patientVo.PatientId 
        set request.USRN = slot.USRN
        set request.UBRN = slot.UBRN

    }
}

}
