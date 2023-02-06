Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ApptService Extends BaseService
{

/// Todo - if there is no request found, can't put in into ApptVoObj
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
        
        // Get existing appointment object lists of a patient
        set exApptOutput = patientVo.ApptObjList

        #; $$$LOGINFO("[ApptService.NewAppt] patientVo.ApptObjList: "_exApptOutput)
        $$$LOGINFO("[ApptService.NewAppt] Number of existing appointments for patient Id "_patientVo.PatientId_": "_exApptOutput.Count())

        $$$LOGINFO("[ApptService.NewAppt] Initialising appt requests...")
        do ..InitApptRequestPerPatientByRandom(slotsObjList, NumOfApptPerPatient, patientVo, .apptInput, exApptOutput)

        set apptOutput = ##class(CDUI.DataGen.DataGenService.Custom.ApptOutput).%New()

        do ..RunWithRetry(apptInput, apptOutput,)

        // Combine appointments list or add to ApptObjList

        /// Need to check this part so as to keep existing appointments list, not override it
        $$$LOGINFO("[ApptService.NewAppt] Count of ApptObjList for this patient before insertion: "_patientVo.ApptObjList.Count())
        $$$LOGINFO("[ApptService.NewAppt] Insert appt to existing ApptObjList...")
        
        /// If ApptVoObjList is not empty, insert it back into patientVo for future use
        if (apptOutput.ApptVoObjList '= "") {
            do patientVo.ApptObjList.Insert(apptOutput.ApptVoObjList)
             $$$LOGINFO("[ApptService.NewAppt] Count of ApptObjList for this patient after insertion: "_patientVo.ApptObjList.Count())
        }

        set apptIdList = apptOutput.ApptIdList

        set numOfSuccess = apptIdList.Count()

        $$$LOGINFO("[ApptService.NewAppt] Number of successful appointments: "_numOfSuccess)
        
        set numOfFailure = NumOfApptPerPatient - numOfSuccess

        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByPatientIdArr(patientVo.PatientId) = numOfFailure
        }
        
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
    set requestObjList = apptInput.RequestObjList
    set slotsObjList = apptInput.SlotsObjList
    set slotsIndexList = apptInput.SlotsIndexList
    set slotDetailObjList = apptInput.SlotDetailObjList


    set apptIdList = ##class(%ListOfDataTypes).%New()

    set numOfLoop = requestObjList.Count()
    set numOfFailed = 0

    set failedApptRequestObjList =  ##class(%ListOfObjects).%New()
    set failedServerError =  ##class(%ListOfObjects).%New()

    $$$LOGINFO("[ApptService.Run] Number of appt requests executing: "_numOfLoop)

    if numOfLoop '=0 {

        // Can remove the for loop here as the number of request each time is only 1???

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
                    set apptOutput.ApptVoObjList = ##class(CDUI.DataGen.vo.AppointmentVo).newInstance(request,json.ID,slotDetailObjList.GetAt(cnt))
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
                do failedServerError.Insert(request)
                $$$LOGINFO("[ApptService.Run] Failed by Internal Server Error:  "_request.SerialisedGet())
                $$$LOGINFO("[ApptService.Run] No more request will be made for this patient  ")
                set isSuccess = 2
            }
        } 
        catch ex 
        {	
            $$$LOGERROR("[ApptService.NewAppt] Failed to create an appointment. Error(Ex): "_ex.DisplayString())
        }

        if ((isSuccess '= 1) && (isSuccess '= 2)){
            do failedApptRequestObjList.Insert(request)
            $$$LOGINFO("[ApptService.Run] Request in failedApptRequestObjList:  "_request.SerialisedGet())
            set numOfFailed = numOfFailed + 1
        }
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
    set apptInput.SlotDetailObjList = slotDetailObjList

    // Set the output
    set apptOutput.NumOfFailed = numOfFailed

	quit numOfFailed
}

Method InitApptRequestPerPatientByRandom(slotsObjList As %ListOfObjects, NumOfApptPerPatient As %Integer = 1, patientVo As CDUI.DataGen.vo.PatientVo, Output apptInput As CDUI.DataGen.DataGenService.Custom.ApptInput, exApptOutput As %ListOfObjects) [ Private ]
{
    kill apptInput
    set apptInput = ##class(CDUI.DataGen.DataGenService.Custom.ApptInput).%New()
    set apptTmpList = ##class(%ListOfObjects).%New()

    set numOfExAppt = exApptOutput.Count()

    /// Double check this as slot details need to go together with the request 
    set slotTmpList = ##class(%ListOfObjects).%New()

    for cnt=1:1:NumOfApptPerPatient{
        
        // If no appointment exists
        if numOfExAppt = 0 {
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
            $$$LOGINFO("[ApptService.Init] Slot details: USRN: "_slot.USRN_", Date: "_slot.Date_", StartTime: "_slot.SessStartTime_", EndTime: "_slot.SessEndTime)

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
            $$$LOGINFO("[ApptService.Init] There are existing appointments, checking required...")
            set isSuccess = ..AssignSlot(slotsObjList, exApptOutput, .slot)
            

            // If a slot is found after passing checks with all existing appointments, a request will be made
            if isSuccess = 1 {
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

            // Else, meaning no slot that is not different to existing appointments after 8 trials, so no request can be made for this patient
            else
            {
                $$$LOGINFO("[ApptService.Init] No request found")
            }
        }
    }

    // Output of this method is 
    set apptInput.RequestObjList = apptTmpList 
    set apptInput.SlotsObjList = slotsObjList
    set apptInput.SlotDetailObjList = slotTmpList


    /// Check if there is value in requestObjList
    if (apptInput.RequestObjList '= "") {     
        $$$LOGINFO("[ApptService.Init] Count of requests: "_apptInput.RequestObjList.Count())   
	}
    else 
    { 
        $$$LOGINFO("[ApptService.Init] No request found")
	}
}

// Method to check if the slot has same time as the existing appointment

ClassMethod AssignSlot(slotsObjList As %ListOfObjects, exApptOutput As CDUI.DataGen.DataGenService.Custom.ApptOutput, Output slotFinal) As %Integer
{
    // Put in retry logic here to try 8 times to get new slot that doesn't clash with existing appointments
    $$$LOGINFO("[ApptService.AssignSlot] Begin...")
    set numOfTrial = 5

    set isSuccess = 0

    for i=1:1:numOfTrial{
    
        $$$LOGINFO("[ApptService.AssignSlot] Get new slot - Trial: "_i)

        // Randomly select the slots from slotsObjList	
        if $Data(slotsObjList) && (slotsObjList.Count() > 0)
        {
            $$$LOGINFO("[ApptService.AssignSlot] Count of slotsObjList: "_slotsObjList.Count())
            set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
            $$$LOGINFO("[ApptService.AssignSlot] Try slot index: "_randslotIndex)
            set slotTmp = slotsObjList.GetAt(randslotIndex)
            
        }

        // Get slot details
        set slotDate = slotTmp.Date 
        set slotStartTime = slotTmp.SessStartTime
        set slotEndTime = slotTmp.SessEndTime

        $$$LOGINFO("[ApptService.AssignSlot] Slot details: USRN: "_slotTmp.USRN_", Date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)

        set isFail = 0
        set successCount = 0
        
        $$$LOGINFO("[ApptService.AssignSlot] Number of existing appt to check slot details against: "_exApptOutput.Count())

        // Loop through existing appt objects and get date, starttime, endtime
        for cnt=1:1:exApptOutput.Count(){

            set apptItem = exApptOutput.GetAt(cnt)
            set exApptDate = apptItem.Date
            set exApptStartTime = apptItem.StartTime
            set exApptEndTime = apptItem.EndTime

            $$$LOGINFO("[ApptService.AssignSlot] Existing details for appt "_cnt_": "_"Date: "_exApptDate_", StartTime: "_exApptStartTime_", EndTime: "_exApptEndTime)

            #; If overlapped, remove the slot from slotsObjList
            #; If same date
            if (slotDate = exApptDate) 
            {
                #; if ((exApptStartTime < slotEndTime) && (slotStartTime < exApptEndTime))
                if (($tr(exApptStartTime,":","") < $tr(slotEndTime,":","")) && ($tr(slotStartTime,":","") < $tr(exApptEndTime,":","")))
                
                {
                    //Remove slot from list 
                    $$$LOGINFO("[ApptService.AssignSlot] Overlapped, so remove slot index: "_randslotIndex)
                    $$$LOGINFO("[ApptService.AssignSlot] Count before removal: "_slotsObjList.Count())
                    do slotsObjList.RemoveAt(randslotIndex)
                    $$$LOGINFO("[ApptService.AssignSlot] Count after removal: "_slotsObjList.Count())
                    set isFail = 1   
                }
                #; Elseif same date, no overlap 
                else {
                    set successCount = successCount + 1
                    $$$LOGINFO("[ApptService.AssignSlot] successCount: "_successCount)
                }
            }
            else {
                $$$LOGINFO("[ApptService.AssignSlot] Different date so no overlap")
                set successCount = successCount + 1
                $$$LOGINFO("[ApptService.AssignSlot] successCount: "_successCount)
            }
            
            // Quit the for loop & not check the next appointment if the slot clashes with one appointment
            quit:isFail=1
        }

        // If the slot is different to each of the existing appointments
        if (successCount = exApptOutput.Count()) {
            set isSuccess = 1
            $$$LOGINFO("[ApptService.AssignSlot] Slot found in Trial: "_i_", date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)
            set slotFinal = slotTmp
        
        }
        // Quit the for loop if a satisfactory slot is found
        quit:isSuccess=1
    }
    return isSuccess
}

}
