Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.Web.Service.DataGenService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

ClassMethod processRequest(requestParamValues As %String, jobId As %Integer)
{
    //update process id and status to ^DataGen
    try{
        set request = ##class(CDUI.Web.Request.CreateJobRequest).newInstanceFromStringParamValues(requestParamValues)
        set pid = $SYSTEM.SYS.ProcessID()
        set status = ##class(JobService).#StatusInProgress
        do ##class(JobService).UpdateJob(jobId, pid, status,)

        //Handle the request
        set isProcessByBatch = ^DataGen.Job("info","isProcessByBatch")
        set noOfPatientPerBatch = ^DataGen.Job("info","noOfPatientPerBatch") 
    
    //  set isProcessByBatch = isProcessByBatch = 1
        set isProcessByBatch = 0 //TODO marcus
        set isValidNoOfPatientPerBatch = noOfPatientPerBatch > 0
        set noOfPatient = request.NumOfPatient

        if (isProcessByBatch && 'isValidNoOfPatientPerBatch){
            $$$LOGERROR("[DataGenService.prcoessRequest] Setting is incorrect. isProcessByBatch: "_isProcessByBatch_", noOfPatientPerBatch: "_noOfPatientPerBatch )
        }
        if (isProcessByBatch && isValidNoOfPatientPerBatch && (noOfPatient > noOfPatientPerBatch)){
            //Do it by batches
            set noOfBatch = ##class(%SYSTEM.SQL.Functions).CEILING(noOfPatient / noOfPatientPerBatch) 
            //TODO marcus to implement it
        } else {
            //Do it by single  
            do ..doProcess(request.NumOfPatient, request, jobId, .patientVoObjList)
        }
        set isSuccess = ..validateResult(request, jobId, .patientVoObjList)
        if isSuccess = 1{
            do ##class(JobService).FinishJob(jobId)
        }
        else{
            do ##class(JobService).FinishJobWithError(jobId)
        }
        
    } catch ex {
        do LOG^%ETN
        do ##class(JobService).ErrorJob(jobId)
        $$$LOGERROR("[DataGenService.prcoessRequest] Failed to process a job. Job id: "_jobId_", pid: "_pid)
        $$$LOGERROR(ex)
        throw ex
    }
}

ClassMethod validateResult(req As CDUI.Web.Request.CreateJobRequest, jobId As %Integer, PatientVoObjList As %ListOfObjects) As %Boolean [ Private ]
{
    set epCountCheck = 0
    set apptCountCheck = 0

    // orderCountCheck per patient
    set orderCountCheck = 0
    set orderPerEpisodeCheck = 0

    for cnt=1:1:PatientVoObjList.Count(){
        
        set patientVo = PatientVoObjList.GetAt(cnt)
        $$$LOGINFO("[DataGenService.validateResult] Patient Id: "_patientVo.PatientId)
        
        // If there is episode 
        if (req.isEpisode){
            $$$LOGINFO("[DataGenService.validateResult] Validate episodes...")
            set episodeCount = patientVo.EpisodeObjList.Count()
            if (episodeCount = req.NumOfEpisodePerPatient ) {
                set epCountCheck = epCountCheck + 1
            }
            else{
                set ^DataGen.Log(jobId,"failed episode") = patientVo.PatientId
            }
        }
        #; $$$LOGINFO("[validateResult] Value of epCountCheck: "_epCountCheck_" after Patient Id: "_patientVo.PatientId)
        
        // If there is appointment
        if (req.isAppointment) {
            $$$LOGINFO("[DataGenService.validateResult] Validate appointments...")
            set apptCount = patientVo.ApptObjList.Count()
            if (apptCount = req.NumOfAppointmentPerPatient) {
                set apptCountCheck = apptCountCheck + 1
            }
            else{
                set ^DataGen.Log(jobId,"failed appointment") = patientVo.PatientId
            }
        }
        #; $$$LOGINFO("[validateResult] Value of apptCountCheck: "_apptCountCheck_" after Patient Id: "_patientVo.PatientId)

        // If there is order
        if (req.isOrder){
            
            // Reset this for each patient
            set orderPerEpisodeCheck = 0
            $$$LOGINFO("[DataGenService.validateResult] Validate orders...")
            // Loop through episode objects
            for i=1:1:patientVo.EpisodeObjList.Count(){
                set episodeVo = patientVo.EpisodeObjList.GetAt(i)
                $$$LOGINFO("[DataGenService.validateResult] Validate orders for Episode Id: "_episodeVo.ID)

                set orderCount = episodeVo.OrderObjList.Count()
                $$$LOGINFO("[DataGenService.validateResult] Count of orders for Episode Id: "_episodeVo.ID_" is "_orderCount)

                if (orderCount = req.NumOfOrderPerEpisode) {
                    set orderPerEpisodeCheck = orderPerEpisodeCheck + 1
                    #; $$$LOGINFO("[DataGenService.validateResult] Value of orderPerEpisodeCheck after Episode Id: "_episodeVo.ID_" is "_orderPerEpisodeCheck)
                }  
            }
            // If number of order by episode is correct for this patient, increment orderCountCheck by 1
            if orderPerEpisodeCheck = patientVo.EpisodeObjList.Count(){
                set orderCountCheck = orderCountCheck + 1
                #; set ^cn(i,"orderCountCheck") = orderCountCheck
                $$$LOGINFO("[validateResult] Value of orderCountCheck after patient Id: "_patientVo.PatientId_" is "_orderCountCheck)
            }
            else {
                set ^DataGen.Log(jobId,"failed order") = patientVo.PatientId
            }
        }

        // TODO If there is observation
        if (req.isObservation){
        }
    }

    // Compare between values of request vs actual for all patients
    set patientSuccess = (req.NumOfPatient = PatientVoObjList.Count())
    if (req.isEpisode){
        set episodeSuccess = (req.NumOfEpisodePerPatient = epCountCheck)
     }
    else{
         // Episode number is not specified
         set episodeSuccess = 2
     } 
    if (req.isAppointment){
         set apptSuccess = (req.NumOfAppointmentPerPatient = apptCountCheck)
    }
    else{
         // Appointment number is not specified
        set apptSuccess = 2
    } 
    if (req.isOrder){
        set orderSuccess = (req.NumOfPatient = orderCountCheck)
    }
    else {
        // Order number is not specified
        set orderSuccess = 2
    }
    
    if ((patientSuccess = 0) || (episodeSuccess =0) || (orderSuccess = 0) || (apptSuccess = 0)){
        set isSuccess = 0
    }
    else {
        set isSuccess = 1
    }
    
    return isSuccess
}

ClassMethod doProcess(noOfPatient As %Integer, req As CDUI.Web.Request.CreateJobRequest, jobId As %Integer, Output PatientVoObjList As %ListOfObjects) [ Private ]
{
    set patientService = ##class(PatientService).%New()
	do patientService.NewPatient(noOfPatient, .PatientVoObjList)

    if (req.isEpisode){
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating episode..."
        set episodeService = ##class(EpisodeService).%New()
        do episodeService.NewEpisode(req.NumOfEpisodePerPatient, PatientVoObjList)
    } elseif(req.isEpisodeRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating episode by random range..."
        set episodeService = ##class(EpisodeService).%New()
        do episodeService.NewEpisodeByRange(req.MinNumOfEpisodePerPatient, req.MaxNumOfEpisodePerPatient, PatientVoObjList)
    }

    if (req.isAppointment){
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating appointment..."
        set apptService = ##class(ApptService).%New()
        do apptService.NewAppt(req.NumOfAppointmentPerPatient, PatientVoObjList)
    } elseif(req.isAppointmentRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating appointment by random range..."
        set apptService = ##class(ApptService).%New()
        do apptService.NewApptByRange(req.MinNumOfAppointmentPerPatient, req.MaxNumOfAppointmentPerPatient, PatientVoObjList)
    }

    if (req.isOrder){
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating order..."
        set orderService = ##class(OrderService).%New()
        for i=1:1:PatientVoObjList.Count(){
            do orderService.NewOrder(req.NumOfOrderPerEpisode, req.OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList)
        }
    } elseif(req.isOrderRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating order by random range..."
        set orderService = ##class(OrderService).%New()
        for i=1:1:PatientVoObjList.Count(){
            do orderService.NewOrderByRange(req.MinNumOfOrderPerEpisode, req.MaxNumOfOrderPerEpisode, req.OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList)
        }
    }

    if (req.isObservation){
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating observation..."
        set obsService = ##class(ObsService).%New()
        for i=1:1:PatientVoObjList.Count(){
            do obsService.NewObs(req.NumOfObservationPerEpisode, PatientVoObjList.GetAt(i).EpisodeObjList)
        }
    } elseif(req.isObservationRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating observation by random range..."
        set obsService = ##class(ObsService).%New()
        for i=1:1:PatientVoObjList.Count(){
            do obsService.NewObsByRange(req.MinNumOfObservationPerEpisode, req.MaxNumOfObservationPerEpisode, PatientVoObjList.GetAt(i).EpisodeObjList)
        }
    }

    //TODO marcus to remove it

    set log = ""
	for cnt = 1:1:PatientVoObjList.Count(){
		set log = log_PatientVoObjList.GetAt(cnt).SerialisedGet()
	}
    //TODO marcus to see if i need to remove it
    set ^DataGen.Log(jobId,"result") = log
}

}
