Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.Web.Service.DataGenService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

ClassMethod processRequest(request As CDUI.Web.Request.CreateJobRequest, jobId As %Integer)
{
    //TODO marcus to implement it
    //update process id and status to ^DataGen
    try{
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

        } else {
            //Do it by single  
            do ..doProcess(request.NumOfPatient, request, jobId)
        }
        do ##class(JobService).FinishJob(jobId)
    } catch ex {
        do ##class(JobService).ErrorJob(jobId)
        do LOG^%ETN
        $$$LOGERROR("[DataGenService.prcoessRequest] Failed to process a job. Job id: "_jobId_", pid: "_pid)
        $$$LOGERROR(ex)
        throw ex
    }
}

ClassMethod doProcess(noOfPatient As %Integer, req As CDUI.Web.Request.CreateJobRequest, jobId As %Integer) [ Private ]
{
    kill PatientVoObjList

    set patientService = ##class(PatientService).%New()
	do patientService.NewPatient(noOfPatient, .PatientVoObjList)

    if (req.isEpisode){
        set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()
        do episodeService.NewEpisode(req.NumOfEpisodePerPatient, PatientVoObjList)
    } elseif(req.isEpisodeRange) {
        set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()
        do episodeService.NewEpisodeByRange(req.MinNumOfEpisodePerPatient, req.MaxNumOfEpisodePerPatient, PatientVoObjList)
    }

    if (req.isAppointment){
        set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()
        do apptService.NewAppt(req.NumOfApptPerPatient, PatientVoObjList)
    } elseif(req.isAppointmentRange) {
        set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()
        do apptService.NewApptByRange(req.MinNumOfAppointmentPerPatient, req.MaxNumOfAppointmentPerPatient, PatientVoObjList)
    }

    if (req.isOrder){
        set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
        do orderService.NewOrder(req.NumOfOrderPerEpisode, req.OrderCat, PatientVoObjList)
    } elseif(req.isOrderRange) {
        set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
        do orderService.NewOrderByRange(req.MinNumOfOrderPerEpisode, req.MaxNumOfOrderPerEpisode, req.OrderCat, PatientVoObjList)
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
