Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.Web.Service.DataGenService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

ClassMethod processRequest(request As CDUI.Web.Request.CreateJobRequest, jobId As %Integer)
{
    //TODO marcus to implement it
    //update process id and status to ^DataGen
    try{
       
        s ^marcus($i(^marcus),1) = "111"

        set pid = $SYSTEM.SYS.ProcessID()
        set status = ##class(JobService).#StatusInProgress
        do ##class(JobService).UpdateJob(jobId, pid, status,)
        s ^marcus($i(^marcus),2) = jobId
     
        s ^marcus($i(^marcus),3) = request.SerialisedGet()
        //Handle the request
        set isProcessByBatch = ^DataGen.Job("info","isProcessByBatch")
        set noOfPatientPerBatch = ^DataGen.Job("info","noOfPatientPerBatch") 
    
    //  set isProcessByBatch = isProcessByBatch = 1
        set isProcessByBatch = 0 //TODO marcus
        set isValidNoOfPatientPerBatch = noOfPatientPerBatch > 0
        set noOfPatient = request.NumOfPatient


        if (isProcessByBatch && 'isValidNoOfPatientPerBatch){
            $$$LOGERROR("[DataGenService.prcoessRequest] Setting is incorrect. isProcessByBatch: "_isProcessByBatch_", noOfPatientPerBatch: "_noOfPatientPerBatch )
            s ^marcus($i(^marcus),4) = ""
        }


        if (isProcessByBatch && isValidNoOfPatientPerBatch && (noOfPatient > noOfPatientPerBatch)){
            //Do it by batches
            set noOfBatch = noOfPatientPerBatch
            s ^marcus($i(^marcus),5) = ""

        } else {
            //Do it by single  
            s ^marcus($i(^marcus),6) = ""
            do ..doProcess(request.NumOfPatient, request, jobId)
        }
        do ##class(JobService).FinishJob(jobId)
    } catch ex {
        s ^marcus($i(^marcus),7) = ""
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
        set diff = req.MaxNumOfEpisodePerPatient - req.MinNumOfEpisodePerPatient
        set ranNum = ##class(PUtil).Random(diff) + req.MinNumOfEpisodePerPatient
        //TODO marcus
    }

    if (req.isAppointment){
        set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()
        do apptService.NewAppt(req.NumOfApptPerPatient, PatientVoObjList)
    } elseif(req.isAppointmentRange) {
        set diff = req.MaxNumOfAppointmentPerPatient - req.MinNumOfAppointmentPerPatient
        set ranNum = ##class(PUtil).Random(diff) + req.MinNumOfAppointmentPerPatient
          //TODO marcus
    }

    if (req.isOrder){
        set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
        do orderService.NewOrder(req.NumOfOrderPerEpisode, req.OrderCat, PatientVoObjList)
    } elseif(req.isOrderRange) {
        set diff = req.MaxNumOfOrderPerEpisode - req.MinNumOfOrderPerEpisode
        set ranNum = ##class(PUtil).Random(diff) + req.MinNumOfOrderPerEpisode
          //TODO marcus
    }

    if (req.isObservation){
 //TODO marcus
    } elseif(req.isObservationRange) {
  //TODO marcus
    }
}

}