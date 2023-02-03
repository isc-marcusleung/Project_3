Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ApptService Extends BaseService
{

Method NewAppt(NumOfApptPerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
    set totalSuccess = 0
    set totalFailure = 0
    
    kill failedByPatientIdArr

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
        set servName = servItem.Order
        $$$LOGINFO("[ApptService.NewAppt] Service ID: "_servId_", Name: "_servName)
    }

    // Retrieve the slots list
	$$$LOGINFO("[ApptService.NewAppt] Retrieve the slots")
    set sc = ##class(TrakCareService).GetSlots(,servId,10,.slotsObjList)
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
        #; set apptOutput = patientVo.ApptObjList

        $$$LOGINFO("[ApptService.NewAppt] Calling method to initiate requests")
        do ..InitApptRequestPerPatientByRandom(slotsObjList, NumOfApptPerPatient, patientVo, .apptInput)

        set apptOutput = ##class(CDUI.DataGen.DataGenService.Custom.ApptOutput).%New()
   
        do ..RunWithRetry(apptInput, apptOutput,)

        // Add the ApptObjList back to patientVo for reuse later
        set patientVo.ApptObjList = apptOutput.ApptVoObjList
        set apptIdList = apptOutput.ApptIdList

        set numOfSuccess = apptIdList.Count()

        $$$LOGINFO("[ApptService.NewAppt] Number of successful appointments: "_numOfSuccess)
        
        set numOfFailure = NumOfApptPerPatient - numOfSuccess

        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByPatientIdArr(patientVo.PatientId) = numOfFailure
        }
        
        /// TO DO How to print out the slot details here??? 
        $$$LOGINFO("[ApptService.NewAppt] Results: patient Id: "_patientVo.PatientId_", apptId: "_##class(CommonUtil).convertListOfDataTypeToString(apptIdList,))
        $$$LOGINFO("[ApptService.NewAppt] Success count: "_numOfSuccess_", Failure count: "_numOfFailure)

    }
    set cnt = 0
    set key = $Order(failedByPatientIdArr(""))
    while (key '= "") {
        if (cnt = 0) {
            $$$LOGINFO("[ApptService.NewAppt] Failure per patient")
        }
        $$$LOGINFO("Patient Id: "_key_", Number of Failure: "_failedByPatientIdArr(key))
        set key = $Order(failedByPatientIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[ApptService.NewAppt] Total number of Patient with failed appointment creation: "_cnt)
	$$$LOGINFO("[ApptService.NewAppt] Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method Run(apptInput As CDUI.DataGen.DataGenService.Base.Input, apptOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    #; kill idxOfRemoveOrderObjListArr
    #; kill idxOfRemoveOrderIndexListArr

    set requestObjList = apptInput.RequestObjList
    set slotsObjList = apptInput.SlotsObjList
    set slotsIndexList = apptInput.SlotsIndexList
    set slotDetailObjList = apptInput.SlotDetailObjList


    set apptIdList = ##class(%ListOfDataTypes).%New()
    
    set apptVoObjList = apptOutput.ApptVoObjList

    set numOfLoop = requestObjList.Count()
    set numOfFailed = 0

    // TO CHECK??? 
    if '$Data(apptVoObjList) {
		set apptVoObjList =  ##class(%ListOfObjects).%New()
	}

    
 
    set failedApptRequestObjList =  ##class(%ListOfObjects).%New()

    $$$LOGINFO("[ApptService.Run] Number of appt requests executing: "_numOfLoop)

    for cnt=1:1:numOfLoop {
        set request = requestObjList.GetAt(cnt)
        $$$LOGINFO("[ApptService.Run] Request: "_request.SerialisedGet())
        set isSuccess = 0
        try {
            // Send the request
            set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
            set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

            if $$$ISOK(sc)
            {	
                $$$LOGINFO("[ApptService.Run] Response body: "_response.StringValue)
                set json = {}.%FromJSON(response.StringValue)
                if (json.ERROR = "")
                { 

                    //No error then store the results to AppointmentVo objects
                    do apptVoObjList.Insert(##class(CDUI.DataGen.vo.AppointmentVo).newInstance(request,json.ID,slotDetailObjList.GetAt(cnt)))
                    do apptIdList.Insert(json.ID)
                    set isSuccess = 1
                } 
                else 
                {
                    $$$LOGERROR("[ApptService.Run] Failed to create an appointment. Error(Json): "_json.ERROR)
                } 
            }
            else 
            {
                $$$LOGERROR("[ApptService.NewAppt] Failed to create an appointment. Error(SC): "_$System.Status.DisplayError(sc))
            }
        } 
        catch ex 
        {	
            $$$LOGERROR("[ApptService.NewAppt] Failed to create an appointment. Error(Ex): "_ex.DisplayString())
        }

        if isSuccess '= 1 {
            do failedApptRequestObjList.Insert(request)
            $$$LOGINFO("[ApptService.Run] Request in failedApptRequestObjList:  "_request.SerialisedGet())
            set numOfFailed = numOfFailed + 1
        }
    }

    if (apptOutput.ApptIdList '= "") {     
        $$$LOGINFO("[ApptService.Run] Count of ApptIdList before new appt insertion: "_apptOutput.ApptIdList.Count())   
		for cnt=1:1:apptIdList.Count(){
            $$$LOGINFO("[ApptService.Run] Insertion: "_apptIdList.GetAt(cnt))
			do apptOutput.ApptIdList.Insert(apptIdList.GetAt(cnt))
            $$$LOGINFO("[ApptService.Run] Count after insertion: "_apptOutput.ApptIdList.Count())
		}
	} else { 
        $$$LOGINFO("[ApptService.Run] Reset: "_apptIdList)
		set apptOutput.ApptIdList = apptIdList
	}
    
    //Reset the input for retry
    set apptInput.RequestObjList = failedApptRequestObjList
    set apptInput.SlotsObjList = slotsObjList
    set apptInput.SlotsIndexList = slotsIndexList

    // Set the output
    set apptOutput.NumOfFailed = numOfFailed
	set apptOutput.ApptVoObjList = apptVoObjList

	quit numOfFailed
}

Method InitApptRequestPerPatientByRandom(slotsObjList As %ListOfObjects, NumOfApptPerPatient As %Integer = 1, patientVo As CDUI.DataGen.vo.PatientVo, Output apptInput As CDUI.DataGen.DataGenService.Custom.ApptInput, apptOutput As CDUI.DataGen.DataGenService.Custom.ApptOutput) [ Private ]
{
    kill apptInput
    set apptInput = ##class(CDUI.DataGen.DataGenService.Custom.ApptInput).%New()
    set apptTmpList = ##class(%ListOfObjects).%New()

    set apptVoObjList = apptOutput.ApptVoObjList
    // Store list of slot objects

    /// Double check this as slot details need to go together with the request 
    set slotTmpList = ##class(%ListOfObjects).%New()

    

    for cnt=1:1:NumOfApptPerPatient{

        // Randomly select the slots from slotsObjList	


        // If there is no existing apptVoObjList
        if '$Data(apptVoObjList) {
            $$$LOGINFO("[ApptService.Init] No existing appointments...")
            if $Data(slotsObjList) && (slotsObjList.Count() > 0)
            {
                set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
                $$$LOGINFO("[ApptService.Init] Try slot index: "_randslotIndex)
                set slot = slotsObjList.GetAt(randslotIndex)
            }
		    // Set up the appointment request 
            set request = ##class(CDUI.DataGen.Request.NewAppointment).%New()

            // Convert string PatientId to integer
            set request.PatientID = patientVo.PatientId + 0
            $$$LOGINFO("[ApptService.Init] PatientId: "_request.PatientID)
            $$$LOGINFO("[ApptService.Init] USRN: "_slot.USRN)

            // Remove empty string in the beginning of USRN 
            if ($find(slot.USRN," ")'=0){
                set usrn = $piece(slot.USRN," ", 2)
            }
            set request.USRN = usrn
            set request.UBRN = usrn

            do apptTmpList.Insert(request)
            
            // Store the slot details for comparision between appointments later
            do slotTmpList.Insert(slot)
	    }

        // if there are existing appointments
        else {
            do ..AssignSlot(slotsObjList, apptOutput, .slot)
            

            // Meaning no new slot can be found after 8 trials, so request for new appointment will not be made
            if '$Data(slot) {
                // Set up the appointment request 
                set request = ##class(CDUI.DataGen.Request.NewAppointment).%New()

                // Convert string PatientId to integer
                set request.PatientID = patientVo.PatientId + 0
                $$$LOGINFO("[ApptService.Init] PatientId: "_request.PatientID)
                $$$LOGINFO("[ApptService.Init] USRN: "_slot.USRN)

                // Remove empty string in the beginning of USRN 
                if ($find(slot.USRN," ")'=0){
                    set usrn = $piece(slot.USRN," ", 2)
                }
                set request.USRN = usrn
                set request.UBRN = usrn

                do apptTmpList.Insert(request)
                
                // Store the slot details for comparision between appointments later
                do slotTmpList.Insert(slot)
            }
        }
    }

    // Output of this method is 
    set apptInput.RequestObjList = apptTmpList 
    set apptInput.SlotsObjList = slotsObjList
    set apptInput.SlotDetailObjList = slotTmpList


    /// Check if there is value in requestObjList
    if (apptInput.RequestObjList '= "") {     
        $$$LOGINFO("[ApptService.Init] Count of requestObjList: "_apptInput.RequestObjList.Count())   
        for cnt=1:1:apptInput.RequestObjList.Count(){
            $$$LOGINFO("[ApptService.Init] Get request: "_apptInput.RequestObjList.GetAt(cnt))
        }
	}
    else { 
        $$$LOGINFO("[ApptService.Init] No request found")
	}
}

// Method to check if the slot has same time as the existing appointment

ClassMethod AssignSlot(slotsObjList As %ListOfObjects, apptOutput As CDUI.DataGen.DataGenService.Custom.ApptOutput, Output slotFinal) As %Integer
{
    // Put in retry logic here to try 8 times to get new slot that doesn't clash with existing appointments
    $$$LOGINFO("[ApptService.AssignSlot] Begin...")
    set numOfTrial = 8
    set isSuccess = 0
    for i=1:1:numOfTrial {
    
        $$$LOGINFO("[ApptService.AssignSlot] Trial: "_i)

        // Randomly select the slots from slotsObjList	
        if $Data(slotsObjList) && (slotsObjList.Count() > 0)
        {
            set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
            $$$LOGINFO("[ApptService.AssignSlot] Try slot index: "_randslotIndex)
            set slotTmp = slotsObjList.GetAt(randslotIndex)
            
        }

        // Get slot details
        set slotDate = slotTmp.Date 
        set slotStartTime = slotTmp.StartTime
        set slotEndTime = slotTmp.EndTime 
        $$$LOGINFO("[ApptService.AssignSlot] Slot details: "_slotTmp_", date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)

        // Get existing appointments object list
        set apptVoObjList = apptOutput.ApptVoObjList
        set isFail = 0

        // Check number of success count = number of appointments in the list
        set successCount = 0
        
        $$$LOGINFO("[ApptService.AssignSlot] Count of existing appt: "_apptVoObjList.Count())
        // Loop through apptVoObjList and get date, starttime, endtime
        for cnt=1:1:apptVoObjList.Count(){

            set apptItem = apptVoObjList.GetAt(cnt)
            set exapptDate = apptItem.Date
            set exapptStartTime = apptItem.StartTime
            set exapptEndTime = apptItem.EndTime

            // Check if the slot is same as existing appointment times
            if ((slotDate = exapptDate) && (slotStartTime = exapptStartTime) && (slotEndTime = exapptEndTime))
            {
                //Remove slot from list 
                $$$LOGINFO("[ApptService.AssignSlot] Remove slot index: "_randslotIndex)
                do slotsObjList.RemoveAt(randslotIndex)
                // Use while loop 
                set isFail = 1        
            }
            
            set successCount = successCount + 1
            
            // Quit the for loop & not check the next appointment if the slot clashes with one appointment
            quit:isFail=1
        }

        if (successCount = apptVoObjList.Count) {
            #; set isSuccess = 1
            #; $$$LOGINFO("[ApptService.AssignSlot] Slot found in Trial: "_i_", date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)
            #; return isSuccess
            set slotFinal = slotTmp
        }
    }
    #; return isSuccess

    #; set dateList = ##class(%ListOfDataTypes).%New()
    #; set startTimeList = ##class(%ListOfDataTypes).%New()
    #; set endTimeList = ##class(%ListOfDataTypes).%New() 

    #; // Loop through apptVoObjList
    #; for cnt=1:1:apptVoObjList.Count() {
    #;     set apptItem = apptVoObjList.GetAt(cnt)
    #;     do dateList.Insert(apptItem.Date)
    #;     do startTimeList.Insert(apptItem.StartTime)
    #;     do endTimeList.Insert(apptItem.EndTime)
    #; }

    #; $$$LOGINFO("[ApptService.Init] List of dates: "_##class(CommonUtil).convertListOfDataTypeToString(dateList,))
    #; $$$LOGINFO("[ApptService.Init] List of start times: "_##class(CommonUtil).convertListOfDataTypeToString(startTimeList,))
    #; $$$LOGINFO("[ApptService.Init] List of end times: "_##class(CommonUtil).convertListOfDataTypeToString(endTimeList,))

    // Compare if appoinments don't clash: try compare 1 appointment with 1 appointment first 
    
    #; for cnt=1:1:dateList.Count(){
    #;     set date = dateList.GetAt(cnt)
    #;     set startTime = startTimeList.GetAt(cnt)
    #;     set endTime = endTimeList.GetAt(cnt)

        // Put in another method here
        // Logic to get another slot 
        
        // Compare two appointments

        // If date is the same, either starTime or endTime is the same
}

}
