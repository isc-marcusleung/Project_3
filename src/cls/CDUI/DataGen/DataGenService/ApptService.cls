Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ApptService Extends BaseService
{

Method NewApptByRange(MinNumOfAppt As %Integer = 1, MaxNumOfAppt As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
    set diff = MaxNumOfAppt - MinNumOfAppt
    set totalSuccess = 0
    set totalFailure = 0
    set failedByPatientIdArr = []
    for i=1:1:PatientVoObjList.Count(){

        set servIdList = ##class(%ListOfDataTypes).%New()

        //Retrieve the location service list
        $$$LOGINFO("[ApptService.NewAppt] Retrieve the location service")
        set sc = ##class(TrakCareService).GetLocationServices(,.locServObjList)
        if $$$ISERR(sc)
        {
            $$$LOGERROR("[ApptService.NewAppt] Failed to get location Service")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }

        for k=1:1:locServObjList.Count() {
            set servItem = locServObjList.GetAt(k)
            do servIdList.Insert(servItem.RowID) 
        }

        $$$LOGERROR("[ApptService.NewApptByRange] Why?")
        set ranNum = ##class(PUtil).Random(diff) + MinNumOfAppt
        $$$LOGINFO("[ApptService.NewApptByRange] Number of appt: "_ranNum)
        do ..NewApptPerPatient(ranNum, PatientVoObjList.GetAt(i), .servIdList, .numOfSuccess)
        set numOfFailure = ranNum - numOfSuccess
        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByPatientIdArr(PatientVoObjList.GetAt(i).PatientId) = numOfFailure
        }
    }

    do ..PrintResult(failedByPatientIdArr, totalSuccess, totalFailure)
}

Method NewApptPerPatient(NumOfApptPerPatient As %Integer = 1, PatientVo As CDUI.DataGen.vo.PatientVo, ByRef servIdList, Output totalSuccessPerPatient As %Integer) [ Private ]
{
    set numOfSuccess = 0
    set numOfFailure = 0

    set totalSuccessPerPatient = 0
    set totalFailurePerPatient = 0

    /// Need for loop here, only one appointment request at a time because then you need to update the exApptOutput
    for k=1:1:NumOfApptPerPatient {

        // Get existing appointment object lists of a patient
        set exApptOutput = PatientVo.ApptObjList

        $$$LOGINFO("[ApptService.NewApptPerPatient] New appt request number: "_k)
        $$$LOGINFO("[ApptService.NewApptPerPatient] Number of existing appointments for patient Id "_PatientVo.PatientId_": "_exApptOutput.Count())

        $$$LOGINFO("[ApptService.NewApptPerPatient] Initialising appt requests...")
        do ..InitApptRequestPerPatientByRandom(servIdList, PatientVo, .apptInput, exApptOutput)

        set apptOutput = ##class(CDUI.DataGen.DataGenService.Custom.ApptOutput).%New()

        do ..RunWithRetry(apptInput, apptOutput,)

        /// If ApptVo is not empty, insert it back into patientVo for future use
        if (apptOutput.ApptVo '= "") {

            $$$LOGINFO("[ApptService.NewApptPerPatient] Insert appt to existing ApptObjList...")
            do PatientVo.ApptObjList.Insert(apptOutput.ApptVo)
        } 
        
        set apptIdList = apptOutput.ApptIdList
        set numOfSuccess = apptIdList.Count()
        set numOfFailure = 1 - apptIdList.Count()
        if numOfSuccess '= 0 {
            $$$LOGINFO("[ApptService.NewApptPerPatient] Results: patient Id: "_PatientVo.PatientId_", apptId: "_##class(CommonUtil).convertListOfDataTypeToString(apptIdList,))
        }
        set totalSuccessPerPatient = totalSuccessPerPatient + numOfSuccess
        set totalFailurePerPatient = totalFailurePerPatient + numOfFailure
    }
    
    $$$LOGINFO("[ApptService.NewApptPerPatient] Success count: "_totalSuccessPerPatient_", Failure count: "_totalFailurePerPatient)
}

Method NewAppt(NumOfApptPerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
    set totalSuccess = 0
    set totalFailure = 0
    
    kill failedByPatientIdArr 

    $$$LOGINFO("[ApptService.NewAppt] Number of patient: "_PatientVoObjList.Count())
    $$$LOGINFO("[ApptService.NewAppt] Number of new appointments requested per patient: "_NumOfApptPerPatient)

    set numOfLoop = PatientVoObjList.Count()

    // Loop through each patient
    for i=1:1:numOfLoop {

        // Get patient object
        set patientVo = PatientVoObjList.GetAt(i)
        $$$LOGINFO("[ApptService.NewAppt] Initialise appointment request, patient Id: "_patientVo.PatientId)

        set servIdList = ##class(%ListOfDataTypes).%New()

        //Retrieve the location service list
        $$$LOGINFO("[ApptService.NewAppt] Retrieve the location service")
        set sc = ##class(TrakCareService).GetLocationServices(,.locServObjList)
        if $$$ISERR(sc)
        {
            $$$LOGERROR("[ApptService.NewAppt] Failed to get location Service")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }

        for k=1:1:locServObjList.Count() {
            set servItem = locServObjList.GetAt(k)
            do servIdList.Insert(servItem.RowID) 
        }

        do ..NewApptPerPatient(NumOfApptPerPatient, patientVo, .servIdList, .totalSuccessPerPatient)
        
        set totalSuccess = totalSuccess + totalSuccessPerPatient
        set numOfFailure = NumOfApptPerPatient - totalSuccessPerPatient
        set totalFailure = totalFailure + numOfFailure
        #; set failedByPatientIdArr = []

        if (numOfFailure > 0) {
            set failedByPatientIdArr(patientVo.PatientId) = numOfFailure
        }   

    }

    do ..PrintResult(.failedByPatientIdArr, totalSuccess, totalFailure)
}

Method GetSlotList(ServId As %Integer, Rows As %Integer, Output SlotsObjList As %ListOfObjects)
{
    set sc = ##class(TrakCareService).GetSlots(,ServId,,Rows,.SlotsObjList)
    if $$$ISERR(sc)
    {
        $$$LOGERROR("[ApptService.GetSlotList] Failed to get slots")
        Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
    }
}

Method PrintResult(failedByPatientIdArr, totalSuccess, totalFailure)
{
    set cnt = 0
    set key = $Order(failedByPatientIdArr(""))
    while (key '= "") {
        if (cnt = 0) {
            $$$LOGINFO("[ApptService.PrintResult] Failure per patient")
        }
        $$$LOGINFO("[ApptService.PrintResult] Patient Id: "_key_", Number of Failure: "_failedByPatientIdArr(key))
        set key = $Order(failedByPatientIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[ApptService.PrintResult] Total number of Patient with failed appointment creation: "_cnt)
	$$$LOGINFO("[ApptService.PrintResult] Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method Run(apptInput As CDUI.DataGen.DataGenService.Base.Input, apptOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    kill idxOfRemoveSlotObjListArr
    kill idxOfRemoveSlotIndexListArr
    
    set requestObjList = apptInput.RequestObjList
    set slotsObjList = apptInput.SlotsObjList
    set slotsIndexList = apptInput.SlotsIndexList
    set slotDetailObjList = apptInput.SlotDetailObjList
    set exApptOutput = apptInput.ExApptOutput
    
    set servIdList = apptInput.ServIdList
    set servId = apptInput.ServId

    $$$LOGINFO("[ApptService.Run] Current servId: "_servId)

    set currentTrial = apptInput.CurrentTrial

    set apptIdList = ##class(%ListOfDataTypes).%New()

    set numOfLoop = requestObjList.Count()
    set numOfFailed = 0
    

    set failedApptRequestObjList = ##class(%ListOfObjects).%New()

    $$$LOGINFO("[ApptService.Run] Number of appt requests executing: "_numOfLoop)

    if numOfLoop '=0 {

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
                        set apptOutput.ApptVo = ##class(CDUI.DataGen.vo.AppointmentVo).newInstance(request,json.ID,slotDetailObjList.GetAt(cnt))
                        do apptIdList.Insert(json.ID)

                        // Remove successful slot from slotsObjList
                        do slotsObjList.RemoveAt(slotsIndexList.GetAt(cnt))
                        set isSuccess = 1
                    } 
                    else 
                    {
                        $$$LOGERROR("[ApptService.Run] Failed to create an appointment. Error(Json): "_json.ERROR)
                    } 
                }
                else 
                {   
                    // Print out the errors
                    $$$LOGERROR("[ApptService.NewAppt] Failed to create an appointment. Error(SC): "_$System.Status.DisplayError(sc))
                    $$$LOGINFO("[ApptService.Run] Slot index to be removed due to internal server error: "_slotsIndexList.GetAt(cnt))
                    set idxOfRemoveSlotObjListArr(slotsIndexList.GetAt(cnt)) = ""
                    set idxOfRemoveSlotIndexListArr(cnt) = ""

                    // Remove slot details of failed slot request
                    do slotDetailObjList.RemoveAt(cnt)
            
                }
            } 
            catch ex 
            {	
                $$$LOGERROR("[ApptService.NewAppt] Failed to create an appointment. Error(Ex): "_ex.DisplayString())
            }

            if (isSuccess '= 1) {
                do failedApptRequestObjList.Insert(request)
                $$$LOGINFO("[ApptService.Run] Request in failedApptRequestObjList:  "_request.SerialisedGet())
                set numOfFailed = numOfFailed + 1
            }
    }

    }

    if $Order(idxOfRemoveSlotObjListArr("")) {
        do ..RemoveItemsInverseFromList(slotsObjList, .idxOfRemoveSlotObjListArr)
    }

    if $Order(idxOfRemoveSlotIndexListArr("")) {
        do ..RemoveItemsInverseFromList(slotsIndexList, .idxOfRemoveSlotIndexListArr)
    }

    // Set request with new slot
    // Need existing appointments, slotsObjList
    for cnt=1:1:failedApptRequestObjList.Count(){

        set newRequestMade = 0
        set currentTrial = currentTrial + 1
        $$$LOGINFO("[ApptService.Run.FailedRequest] Current Trial: "_currentTrial)

        // If currentTrial = MaxNumOfRetry, no need to run the AssignSlot Method anymore
        if (currentTrial '= ..MaxNumOfRetry) && (servIdList.Count() '=0) {
            $$$LOGINFO("[ApptService.Run.FailedRequest] Running AssignSlot again to get new slot for failed request...") 
            $$$LOGINFO("[ApptService.Run.FailedRequest] Check slotsObjList count: "_slotsObjList.Count()) 

            while newRequestMade=0 
            {
                set isSuccess = ..AssignSlot(slotsObjList, exApptOutput, .slot, .randslotIndex)
            
                if isSuccess = 1 {
                    $$$LOGINFO("[ApptService.Run.FailedRequest] Successfully found slot for failed request... ") 
                    // Remove empty string in the beginning of USRN
                    if ($find(slot.USRN," ")'=0){
                        set formattedUSRN = $piece(slot.USRN," ",2)
                    }

                    set failedApptRequestObjList.GetAt(cnt).USRN = formattedUSRN
                    set failedApptRequestObjList.GetAt(cnt).UBRN = formattedUSRN

                    // Update slot details object list
                    $$$LOGINFO("[ApptService.Run.FailedRequest] Check new slot details for new request: "_"Date: "_slot.Date_", Start Time: "_slot.SessStartTime_", End Time: "_slot.SessEndTime) 
                    do slotDetailObjList.Insert(slot)
                    $$$LOGINFO("[ApptService.Run.FailedRequest] Check count of slotDetailObjList: "_slotDetailObjList.Count()) 
                    

                    $$$LOGINFO("[ApptService.Run.FailedRequest] Get new USRN & new request: "_slot.USRN) 
                    do slotsIndexList.Insert(randslotIndex)
                    $$$LOGINFO("[ApptService.Run.FailedRequest] Slot index used: "_randslotIndex) 
                    $$$LOGINFO("[ApptService.Run.FailedRequest] Count of slotsIndexList: "_slotsIndexList.Count())
                    set newRequestMade = 1
                }
                else
                {
                    $$$LOGINFO("[ApptService.Run.FailedRequest] No more slot found in existing servId for failed request in trial "_currentTrial_", so get new servId and slotObjList")
                    
                    // Find servId position and Remove servId
                    set servIdIndex = servIdList.Find(servId)
                    do servIdList.RemoveAt(servIdIndex)

                    // Get new servId and get new slots
                    set ranNum = ##class(PUtil).Random(servIdList.Count()) + 1
                    set servId = servIdList.GetAt(ranNum)
                    set Rows = ##class(PUtil).Integer(1,20)
                    // Retrieve the slots list
                    do ..GetSlotList(servId, Rows,.slotsObjList) 
                    set newRequestMade = 0
                }
            }
            
        }
        if servIdList.Count() = 0 {
            $$$LOGINFO("[ApptService.Run] ServIdList run out. Failed request in last trial "_currentTrial)
            // Set numOfFailed = 0 so no more trial is run after this
            set numOfFailed = 0
        }

        if currentTrial = ..MaxNumOfRetry{
            $$$LOGINFO("[ApptService.Run] Max number of retry is reached in "_currentTrial_". No more request will be made.")
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
    set apptInput.CurrentTrial = currentTrial
    set apptInput.ServIdList = servIdList
    set apptInput.ServId = servId

    // Set the output
    set apptOutput.NumOfFailed = numOfFailed

	quit numOfFailed
}

// One request each time

Method InitApptRequestPerPatientByRandom(servIdList, patientVo As CDUI.DataGen.vo.PatientVo, Output apptInput As CDUI.DataGen.DataGenService.Custom.ApptInput, exApptOutput As %ListOfObjects) [ Private ]
{
    kill apptInput
    set apptInput = ##class(CDUI.DataGen.DataGenService.Custom.ApptInput).%New()
    set apptTmpList = ##class(%ListOfObjects).%New()

    set numOfExAppt = exApptOutput.Count()

    set slotTmpList = ##class(%ListOfObjects).%New()

    if ('$Data(slotsIndexList)) {
        set slotsIndexList = ##class(%ListOfDataTypes).%New()
    }
    
    // Get random servId
    $$$LOGINFO("[ApptService.Init0] Begin - Get random servid & slotsObjList...")

    set ranNum = ##class(PUtil).Random(servIdList.Count()) + 1
    set servId = servIdList.GetAt(ranNum)
    set Rows = ##class(PUtil).Integer(1,20)
    // Retrieve the slots list
    do ..GetSlotList(servId, Rows,.slotsObjList) 

    // If no appointment exists
    if numOfExAppt = 0 
    {
        set retry = 1
        $$$LOGINFO("[ApptService.Init1] No existing appointments...")
        if (retry = 1) && (servIdList.Count()) '=0 {
            if $Data(slotsObjList) && (slotsObjList.Count() > 0)
            {
                set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
                set slot = slotsObjList.GetAt(randslotIndex)
                do slotsIndexList.Insert(randslotIndex)
                $$$LOGINFO("[ApptService.Init1] slotObjList Count: "_slotsObjList.Count())
                $$$LOGINFO("[ApptService.Init1] Try slot index: "_randslotIndex)
                #; $$$LOGINFO("[ApptService.Init1] slotIndexList Count: "_slotsIndexList.Count())
                for cnt=1:1:slotsIndexList.Count() {
                    $$$LOGINFO("[ApptService.Init1] slotsIndexList items: "_slotsIndexList.GetAt(cnt))
                }
            
                // Set up the appointment request 
                $$$LOGINFO("[ApptService.Init1] Set up request...")
                set request = ##class(CDUI.DataGen.Request.NewAppointment).%New()

                // Convert string PatientId to integer
                set request.PatientID = patientVo.PatientId + 0
                $$$LOGINFO("[ApptService.Init1] PatientId: "_request.PatientID)
                $$$LOGINFO("[ApptService.Init1] Slot details: USRN: "_slot.USRN_", Date: "_slot.Date_", StartTime: "_slot.SessStartTime_", EndTime: "_slot.SessEndTime)

                // Remove empty string in the beginning of USRN 
                if ($find(slot.USRN," ")'=0){
                    set usrn = $piece(slot.USRN," ", 2)
                }
                set request.USRN = usrn
                set request.UBRN = usrn

                do apptTmpList.Insert(request)
                
                // Store the slot details for comparision between appointments later
                do slotTmpList.Insert(slot)
                set retry = 0
            }    
            else {
                $$$LOGINFO("[ApptService.Init1] No slot found so remove servId from servIdList then get new slotsObjList to retry")

                // Remove servId from list for retry
                do servIdList.RemoveAt(ranNum)
                set ranNum = ##class(PUtil).Random(servIdList.Count()) + 1
                set servId = servIdList.GetAt(ranNum)
                set Rows = ##class(PUtil).Integer(1,20)
                // Retrieve the slots list
                do ..GetSlotList(servId, Rows,.slotsObjList) 

                set retry = 1
            }
        }

        // Once all slots in all services have run out
        if servIdList.Count() = 0 {
            $$$LOGINFO("[ApptService.Init1] No more services exists for this location.")
        }   
    }	
    // if there are existing appointments
    else {
        set retry = 1
        $$$LOGINFO("[ApptService.Init2] There are "_numOfExAppt _" existing appointments, checking required...")
        
        if (retry = 1) && (servIdList.Count()) '=0 {
        
            // Call AssignSlot method to get slots & check against existing appointments
            set isSuccess = ..AssignSlot(slotsObjList, exApptOutput, .slot, .randslotIndex)
        
            // If a slot is found after passing checks with all existing appointments, a request will be made
            if isSuccess = 1 {

                do slotsIndexList.Insert(randslotIndex)

                // Check value of slotsIndexList
                $$$LOGINFO("[ApptService.Init2] Slot index returned: "_randslotIndex)
                $$$LOGINFO("[ApptService.Init2] slotIndexList Count: "_slotsIndexList.Count())
                for cnt=1:1:slotsIndexList.Count() {
                    $$$LOGINFO("[ApptService.Init2] slotsIndexList items: "_slotsIndexList.GetAt(cnt))
                }

                $$$LOGINFO("[ApptService.Init2] Set up new request... ")

                // Set up the appointment request 
                set request = ##class(CDUI.DataGen.Request.NewAppointment).%New()

                // Convert string PatientId to integer
                set request.PatientID = patientVo.PatientId + 0
                $$$LOGINFO("[ApptService.Init2] PatientId: "_request.PatientID)
                $$$LOGINFO("[ApptService.Init2] USRN: "_slot.USRN)

                // Remove empty string in the beginning of USRN 
                if ($find(slot.USRN," ")'=0){
                    set usrn = $piece(slot.USRN," ", 2)
                }
                set request.USRN = usrn
                set request.UBRN = usrn

                do apptTmpList.Insert(request)
                
                // Store the slot details for comparision between appointments later
                do slotTmpList.Insert(slot)
                set retry = 0
            }

            // Else, meaning no slot that is not different to existing appointments after 8 trials, so get new servId & new slotsObjList for retry
            else
            {
                $$$LOGINFO("[ApptService.Init2] No slot found so try another slotObjList")
                // Remove servId from list for retry
                do servIdList.RemoveAt(ranNum)
                set ranNum = ##class(PUtil).Random(servIdList.Count()) + 1
                set servId = servIdList.GetAt(ranNum)
                set Rows = ##class(PUtil).Integer(1,20)
                // Retrieve the slots list
                do ..GetSlotList(servId, Rows,.slotsObjList) 
                set retry = 1
            }
        }
        
    }

    // Output of this method is 
    set apptInput.RequestObjList = apptTmpList 
    set apptInput.SlotsObjList = slotsObjList
    set apptInput.SlotDetailObjList = slotTmpList
    set apptInput.ExApptOutput = exApptOutput
    set apptInput.SlotsIndexList = slotsIndexList
    set apptInput.ServIdList = servIdList
    set apptInput.ServId = servId

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

ClassMethod AssignSlot(slotsObjList As %ListOfObjects, exApptOutput As CDUI.DataGen.DataGenService.Custom.ApptOutput, Output slotFinal, Output randslotIndex) As %Integer
{
    // Put in retry logic here to try 8 times to get new slot that doesn't clash with existing appointments
    $$$LOGINFO("[ApptService.AssignSlot] Begin...")
    set numOfTrial = 8
    $$$LOGINFO("[ApptService.AssignSlot] Max number of trial: "_numOfTrial)
    set isSuccess = 0

    for i=1:1:numOfTrial{
    
        $$$LOGINFO("[ApptService.AssignSlot] Get new slot - Trial "_i)

        // Randomly select the slots from slotsObjList	
        if $Data(slotsObjList) && (slotsObjList.Count() > 0)
        {
            $$$LOGINFO("[ApptService.AssignSlot] Count of slotsObjList: "_slotsObjList.Count())
            set randslotIndex = ##class(PUtil).Random(slotsObjList.Count()) + 1
            $$$LOGINFO("[ApptService.AssignSlot] Try slot index: "_randslotIndex)
            set slotTmp = slotsObjList.GetAt(randslotIndex)

            // Get slot details
            set slotDate = slotTmp.Date 
            set slotStartTime = slotTmp.SessStartTime
            set slotEndTime = slotTmp.SessEndTime

            $$$LOGINFO("[ApptService.AssignSlot] Slot details to test: USRN: "_slotTmp.USRN_", Date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)

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
                        #; $$$LOGINFO("[ApptService.AssignSlot] Count before removal: "_slotsObjList.Count())
                        do slotsObjList.RemoveAt(randslotIndex)
                        #; $$$LOGINFO("[ApptService.AssignSlot] Count after removal: "_slotsObjList.Count())
                        set isFail = 1   
                    }
                    #; Elseif same date, no overlap 
                    else {
                        set successCount = successCount + 1
                        $$$LOGINFO("[ApptService.AssignSlot] Same date but no overlap")
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
                $$$LOGINFO("[ApptService.AssignSlot] Slot found in Trial "_i_", date: "_slotDate_", StartTime: "_slotStartTime_", EndTime: "_slotEndTime)
                set slotFinal = slotTmp
            
            }
            // Quit the for loop if a satisfactory slot is found
            quit:isSuccess=1
            
        }
        // If there is no more slot
        else {
            $$$LOGINFO("[ApptService.AssignSlot] Slots run out")
            return isSuccess
        }       
    }
    return isSuccess
}

Method RemoveItemsInverseFromList(sourceList, ByRef removalIndexArray) [ Private ]
{
    set key = $Order(removalIndexArray(""), -1) //inverse order, delete the items in inverse order
    
    while (key '= "") {
        do sourceList.RemoveAt(key)
        set key = $Order(removalIndexArray(key), -1)
    }
}

}
