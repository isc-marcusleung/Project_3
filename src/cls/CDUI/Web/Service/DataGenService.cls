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
        do ##class(JobService).FinishJob(jobId)
    } catch ex {
        do LOG^%ETN
        do ##class(JobService).ErrorJob(jobId)
        $$$LOGERROR("[DataGenService.prcoessRequest] Failed to process a job. Job id: "_jobId_", pid: "_pid)
        $$$LOGERROR(ex)
        throw ex
    }
}

ClassMethod validateResult()
{
    //TODO marucs to validate the result, if it is not all successful, then set the status to StatusCompletedWithError
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
        set ^DataGen.Log(jobId,$i(^DataGen.Log)) = "Creating apponitment..."
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
 //TODO marcus
    } elseif(req.isObservationRange) {
  //TODO marcus
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
