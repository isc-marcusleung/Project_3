Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.Web.Service.DataGenService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

/// To handle the request from users
/// [Input parameter]
/// requestParamValues: it is a request from users. It is converted to a string so it can be passed into the function via "Job" command.
/// jobId: Job Id
ClassMethod processRequest(requestParamValues As %String, jobId As %Integer)
{
    //update process id and status to ^DataGen
    try{
        //convert the requestParamValues back to CreateJobRequest
        set request = ##class(CDUI.Web.Request.CreateJobRequest).newInstanceFromStringParamValues(requestParamValues)
        set pid = $SYSTEM.SYS.ProcessID()
        set status = ##class(JobService).#StatusInProgress
        //update the job status from create to in progess
        do ##class(JobService).UpdateJob(jobId, pid, status,,)

        //Handle the request
        set isProcessByBatch = ^DataGen.Job("info","isProcessByBatch")
        set noOfPatientPerBatch = ^DataGen.Job("info","noOfPatientPerBatch") 
    
        set isValidNoOfPatientPerBatch = noOfPatientPerBatch > 0
        set noOfPatient = request.NumOfPatient

        if (isProcessByBatch && 'isValidNoOfPatientPerBatch){
            $$$LOGERROR("[DataGenService.prcoessRequest] Setting is incorrect. isProcessByBatch: "_isProcessByBatch_", noOfPatientPerBatch: "_noOfPatientPerBatch )
        }
        if (isProcessByBatch && isValidNoOfPatientPerBatch && (noOfPatient > noOfPatientPerBatch)){
            //Do it by batches so after each batch, clear the patientVoObjList to free up resources
            set noOfBatch = ##class(%SYSTEM.SQL.Functions).CEILING(noOfPatient / noOfPatientPerBatch) 
            //TODO marcus to implement it
        } else {
            //Do it by single  
            do ..doProcess(request.NumOfPatient, request, jobId, .patientVoObjList, .FailedCaseArr)
        }
        set isSuccess = ..validateResult(.FailedCaseArr)

        //write api log from global
        set fileName = ##class(CDUI.DataGen.ExportLog).WriteAPILog(jobId)
        //remove api log from global after the job is done
        kill ^DataGen.APILog("info",jobId)

        set apiLogRelativeUrl = ##class(CDUI.DataGen.Common.Constants).#apiLogRelativeDir_fileName
        if isSuccess = 1 {
            do ##class(JobService).FinishJob(jobId, apiLogRelativeUrl)
        }
        else{
            do ##class(JobService).FinishJobWithError(jobId, apiLogRelativeUrl)
        }

        
    } catch ex {
        do LOG^%ETN
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = ex.DisplayString()
        //write api log from global
        set fileName = ##class(CDUI.DataGen.ExportLog).WriteAPILog(jobId)
        kill ^DataGen.APILog("info",jobId)

        do ##class(JobService).ErrorJob(jobId, ##class(CDUI.DataGen.Common.Constants).#apiLogRelativeDir_fileName)
        
        $$$LOGERROR("[DataGenService.prcoessRequest] Failed to process a job. Job id: "_jobId_", pid: "_pid)
        $$$LOGERROR(ex)
        throw ex
    }
}

/// To validate the result of the record creation to see if any failed case occurs.
/// [Input parameter]
/// FailedCaseArr: the return value from record creation function. It contains the failed cases.
/// [Return Value]
/// 0: indicates there is at least one failed case.
/// 1: indicates there is no failed case.
ClassMethod validateResult(ByRef FailedCaseArr) As %Boolean [ Private ]
{
   // If there is any recrod in the array, it indicates there is at least one failed case.
    return $Data(FailedCaseArr) = 0
}

/// To call the coresponding record creation function according to the request
/// [Input parameter]
/// noOfPatient: The number of patient to be created.
/// req: the request from users
/// jobId: job Id
/// PatientVoObjList: it is the output of this function.
ClassMethod doProcess(noOfPatient As %Integer, req As CDUI.Web.Request.CreateJobRequest, jobId As %Integer, Output PatientVoObjList As %ListOfObjects, Output FailedCaseArr) [ Private ]
{
    kill FailedCaseArr
    
    set patientService = ##class(PatientService).%New()

    set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start patient creation"
    set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
    // Patient record creation
	do patientService.NewPatient(noOfPatient, jobId, .PatientVoObjList)
    set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
    do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
    set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished patient creation, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"


    //record the number of failed case
    set noOfFailedPatient = noOfPatient - PatientVoObjList.Count()
    if noOfFailedPatient > 0 {
        set FailedCaseArr("TotalNumOfFailedPaitent") = noOfFailedPatient
    }

    // episode record creation
    if (req.isEpisode){
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start episode creation"
        set episodeService = ##class(EpisodeService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do episodeService.NewEpisode(req.NumOfEpisodePerPatient, PatientVoObjList, jobId, .failedByIdArr)
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished episode creation, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    } elseif(req.isEpisodeRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start episode creation by random range"
        set episodeService = ##class(EpisodeService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do episodeService.NewEpisodeByRange(req.MinNumOfEpisodePerPatient, req.MaxNumOfEpisodePerPatient, PatientVoObjList, jobId, .failedByIdArr)
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished episode creation by random range, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    }
    //record the number of failed case 
    do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedEpisode",)

    kill failedByIdArr

    // appointment record creation
    if (req.isAppointment){
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start appointment creation"
        set apptService = ##class(ApptService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do apptService.NewAppt(req.NumOfAppointmentPerPatient, PatientVoObjList, jobId, .failedByIdArr)
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished appointment creation, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    } elseif(req.isAppointmentRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start appointment creation by random range"
        set apptService = ##class(ApptService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do apptService.NewApptByRange(req.MinNumOfAppointmentPerPatient, req.MaxNumOfAppointmentPerPatient, PatientVoObjList, jobId, .failedByIdArr)
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished appointment creation by random range, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    }

    //record the number of failed case 
    do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedAppt",)
    
    kill failedByIdArr
    // order record creation
    if (req.isOrder){
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start order creation"
        set orderService = ##class(OrderService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        for i=1:1:PatientVoObjList.Count(){
            do orderService.NewOrder(req.NumOfOrderPerEpisode, req.OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList, jobId, .failedByIdArr)
           
            //record the number of failed case 
            do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedOrder", PatientVoObjList.GetAt(i).PatientId)
        }
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished order creation, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    } elseif(req.isOrderRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start order creation by random range"
        set orderService = ##class(OrderService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        for i=1:1:PatientVoObjList.Count(){
            do orderService.NewOrderByRange(req.MinNumOfOrderPerEpisode, req.MaxNumOfOrderPerEpisode, req.OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList, jobId, .failedByIdArr)

            //record the number of failed case 
            do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedOrder", PatientVoObjList.GetAt(i).PatientId)
        }
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished order creation by random range, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    }

    kill failedByIdArr
    // observation record creation
    if (req.isObservation){
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start observation creation"
        set obsService = ##class(ObsService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        for i=1:1:PatientVoObjList.Count(){
            do obsService.NewObs(req.NumOfObservationPerEpisode, PatientVoObjList.GetAt(i).EpisodeObjList, jobId, .failedByIdArr)

            //record the number of failed case 
            do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedObs", PatientVoObjList.GetAt(i).PatientId)
        }
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished observation creation, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    } elseif(req.isObservationRange) {
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Start observation creation by random range"
        set obsService = ##class(ObsService).%New()
        set startTime = $zdatetime($ZTIMESTAMP,3,1,3)
        for i=1:1:PatientVoObjList.Count(){
            do obsService.NewObsByRange(req.MinNumOfObservationPerEpisode, req.MaxNumOfObservationPerEpisode, PatientVoObjList.GetAt(i).EpisodeObjList, jobId, .failedByIdArr)

            //record the number of failed case 
            do ..recordFailedCase(.failedByIdArr, .FailedCaseArr, "NumOfFailedObs", PatientVoObjList.GetAt(i).PatientId)
        }
        set endTime = $zdatetime($ZTIMESTAMP,3,1,3)
        do ##class(CommonUtil).GetTimeDiff(startTime,endTime, .sec, .min,.hr,.day)
        set ^DataGen.Log(jobId,$i(^DataGen.Log(jobId))) = "Finished observation creation by random range, duration: "_day_" day "_hr_" hr "_min_" min "_sec_" sec"
    }

    // save the result to ^DataGen.Log
    set log = ""
	for cnt = 1:1:PatientVoObjList.Count(){
		set log = PatientVoObjList.GetAt(cnt).SerialisedGet()
        set ^DataGen.Log(jobId,"result", $i(^DataGen.Log(jobId,"result"))) = log
	}
    // save the failed case to ^DataGen.Log
    do ..writeFailedCaseToLog(jobId, .FailedCaseArr)
}

/// construct the failed cases in FailedCaseArr so it can be used in structural form.
/// [Input Parameter]
/// failedByIdArr: the failed cases array which is returned from record creation function.
/// FailedCaseArr: it is the output after the process in this function
/// type: construct the FailedCaseArr accroding to the type
/// patientId: construct the FailedCaseArr accroding to the patient id
ClassMethod recordFailedCase(ByRef failedByIdArr, Output FailedCaseArr, type As %String, patientId As %String) [ Private ]
{
    /** 
    "p" indicates failed patient record
    FailedCaseByPatientArr("TotalNumOfFailedPaitent")
    FailedCaseByPatientArr("p", patientId,"NumOfFailedEpisode")
    FailedCaseByPatient("p", patientId,"NumOfFailedAppt")
    FailedCaseByPatient("p", patientId,episodeId,"NumOfFailedOrder")
    FailedCaseByPatient("p", patientId,episodeId,"NumOfFailedObs")
    */
    //record the number of failed case 
    if ($DATA(failedByIdArr) > 0) {
        set key = $Order(failedByIdArr(""))
        while (key '= "") {
            if (type = "NumOfFailedEpisode") {
                set FailedCaseArr("p",key,"NumOfFailedEpisode") = failedByIdArr(key)
            } elseif (type = "NumOfFailedAppt"){
                set FailedCaseArr("p",key,"NumOfFailedAppt") = failedByIdArr(key)
            } elseif(type = "NumOfFailedOrder"){
               set FailedCaseArr("p", patientId, key, "NumOfFailedOrder") = failedByIdArr(key)
             } elseif(type = "NumOfFailedObs"){
                set FailedCaseArr("p", patientId, key, "NumOfFailedObs") = failedByIdArr(key)
             }
            set key = $Order(failedByIdArr(key))
        }
    }
}

/// write the failed cases to ^DataGen.Log
/// [Input parmeter]
/// jobId: Job Id
/// FailedCaseArr: the return value from record creation function. It contains the failed cases.
ClassMethod writeFailedCaseToLog(jobId As %Integer, ByRef FailedCaseArr) [ Private ]
{
        if ($DATA(FailedCaseArr) > 0) {
            if ($DATA(FailedCaseArr("TotalNumOfFailedPaitent")) > 0){
                set ^DataGen.Log(jobId,"faultLog",$i(^DataGen.Log(jobId,"faultLog"))) = "TotalNumOfFailedPaitent: "_FailedCaseArr("TotalNumOfFailedPaitent")
            }
            if (($DATA(FailedCaseArr("p")) > 0) && ($ORDER(FailedCaseArr("p","")) '= "")){
                set patientId = $Order(FailedCaseArr("p",""))
                while (patientId '= "") {
                    if ($DATA(FailedCaseArr("p",patientId,"NumOfFailedEpisode")) > 0){
                        set ^DataGen.Log(jobId,"faultLog",$i(^DataGen.Log(jobId,"faultLog"))) = "Patient Id: "_patientId_", NumOfFailedEpisode: "_FailedCaseArr("p",patientId,"NumOfFailedEpisode")
                    }
                    if ($DATA(FailedCaseArr("p",patientId,"NumOfFailedAppt")) > 0){
                        set ^DataGen.Log(jobId,"faultLog",$i(^DataGen.Log(jobId,"faultLog"))) = "Patient Id: "_patientId_", NumOfFailedAppt: "_FailedCaseArr("p",patientId,"NumOfFailedAppt")
                    }
                    if ($Order(FailedCaseArr("p",patientId,"")) '= "") { 
                           set episodeId = $Order(FailedCaseArr("p",""))
                           while (episodeId '= "") {
                                if ($DATA(FailedCaseArr("p",patientId, episodeId, "NumOfFailedOrder")) > 0){
                                    set ^DataGen.Log(jobId,"faultLog",$i(^DataGen.Log(jobId,"faultLog"))) = "Patient Id: "_patientId_", episode Id: "_episodeId_", NumOfFailedOrder: "_FailedCaseArr("p",patientId,episodeId, "NumOfFailedOrder")
                                }
                                if ($DATA(FailedCaseArr("p",patientId, episodeId, "NumOfFailedObs")) > 0){
                                    set ^DataGen.Log(jobId,"faultLog",$i(^DataGen.Log(jobId,"faultLog"))) = "Patient Id: "_patientId_", episode Id: "_episodeId_", NumOfFailedObs: "_FailedCaseArr("p",patientId,episodeId, "NumOfFailedObs")
                                }
                                  set episodeId = $Order(FailedCaseArr("p",patientId,episodeId))
                           }
                    }
                    set patientId = $Order(FailedCaseArr("p",patientId))
                }
            }
        }
}

}
