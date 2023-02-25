/// This class is used to manipulte the gloabl variable ^DataGen.Job
Class CDUI.Web.Service.JobService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

/**
^DataGen.Job("info","size")
^DataGen.Job("info","nextId")
^DataGen.Job("info","maxProcess")
^DataGen.Job("info","isProcessByBatch")
^DataGen.Job("info","noOfPatientPerBatch") 
^DataGen.Job("info","noOfCurrentProcess")
^DataGen.Job("item",<id>,"status")
^DataGen.Job("item",<id>,"pid")
^DataGen.Job("item",<id>,"apiLogRelativeUrl")
^DataGen.Job("item",<id>,"createDateTime")
^DataGen.Job("item",<id>,"completeDateTime")
^DataGen.Job("item",<id>,"lastUpdateDateTime")
*/

// default lock time out

Parameter DefaultTimeout = 5;

// Job Status 

/// job is created but a new process has not yet started to handle the request
Parameter StatusCreate = "Create";

/// a new process has started to handle the request
Parameter StatusInProgress = "In Progress";

/// When a user manually terminate the process
Parameter StatusTerminated = "Terminated";

/// When the process can complete but some exception occur during the process
Parameter StatusCompletedWithError = "Completed With Error";

/// When the process can complete succesfully
Parameter StatusCompleted = "Completed";

/// When the process cannot be run properly
Parameter StatusError = "Error";

// Lock for Job ID generation

Parameter IdGeneratorLock = "DataGen.Job.IdGeneratorLock";

/// Initialize ^DataGen.Job. It must be initialized at the beginning
ClassMethod InitGlobalVariable() [ Private ]
{
    $$$LOGINFO("[JobService.InitGlobalVariable] start initializing global variable.")
    Set locked = 0
    Try {
        Lock +^DataGen.Job:..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.InitGlobalVariable] Failed to initialize global variable.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        if ($Data(^DataGen.Job) = 0){
            set ^DataGen.Job("info","size") = 0
            set ^DataGen.Job("info","nextId") = 1
            set ^DataGen.Job("info","maxProcess") = 8 
            set ^DataGen.Job("info","isProcessByBatch") = 0 //0 indicates false, 1 indicates true
            set ^DataGen.Job("info","noOfPatientPerBatch") = 10 
            set ^DataGen.Job("info","noOfCurrentProcess") = 0
        } else {
            $$$LOGINFO("[JobService.InitGlobalVariable] Global variable for job is already created.")
        }
        Lock -^DataGen.Job
        $$$LOGINFO("[JobService.InitGlobalVariable] Finished initializing global variable.")
   
    } catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Job
        }
        Throw exception
    }
}

/// To control the number of concurrent process. Only if it can take a ticket, it can use "do" to create a new process to handle the request.
/// [Return value]
/// 0: failed to get a ticket
/// 1: succeed to get a ticket
ClassMethod GetTicketForJob() As %Integer
{
    $$$LOGINFO("[JobService.GetTicketForJob] Start getting a ticket.")
    do ..checkSetup()
    TSTART
    set locked = 0
    Try {
        LOCK +(^DataGen.Job("info","maxProcess"),^DataGen.Job("info","noOfCurrentProcess")):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.GetTicketForJob] Failed to get a ticket.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        set maxProcess = ^DataGen.Job("info","maxProcess")
        set noOfCurrentProcess = ^DataGen.Job("info","noOfCurrentProcess")
        set result = 0
      
        if ((noOfCurrentProcess + 1 ) <= maxProcess){
           set ^DataGen.Job("info","noOfCurrentProcess") = noOfCurrentProcess + 1
           set result = 1
        }
        $$$LOGINFO("[JobService.GetTicketForJob] Finished getting a ticket. noOfCurrentProcess: "_^DataGen.Job("info","noOfCurrentProcess"))
        Lock -(^DataGen.Job("info","maxProcess"),^DataGen.Job("info","noOfCurrentProcess"))
        TCOMMIT
        return result
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -(^DataGen.Job("info","maxProcess"),^DataGen.Job("info","noOfCurrentProcess"))
        }
        TROLLBACK
        Throw exception
    }
}

/// Remove the ticket after the process is ended so it can free up the capacity for other processes.
ClassMethod RemoveTicketForJob()
{
     $$$LOGINFO("[JobService.RemoveTicketForJob] Start removing a ticket.")
    do ..checkSetup()
    TSTART
    set locked = 0
    Try {
        LOCK +^DataGen.Job("info","noOfCurrentProcess"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.RemoveTicketForJob] Failed to remove a ticket.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        set noOfCurrentProcess = ^DataGen.Job("info","noOfCurrentProcess") - 1
        set ^DataGen.Job("info","noOfCurrentProcess") = noOfCurrentProcess
        Lock -^DataGen.Job("info","noOfCurrentProcess")
        TCOMMIT
        $$$LOGINFO("[JobService.GetTicketForJob] Finished removing a ticket. noOfCurrentProcess: "_noOfCurrentProcess)

    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Job("info","noOfCurrentProcess")
        }
        TROLLBACK
        Throw exception
    }
}

/// For checking if the global variable is set up.
ClassMethod checkSetup() [ Private ]
{
    if ($Data(^DataGen.Job) = 0){
        do ..InitGlobalVariable()
    }
}

/// Get a unique job id for job creation.
ClassMethod GetNextId() As %Integer [ Private ]
{
    $$$LOGINFO("[JobService.GetNextId] Get next Job Id.")
    Set locked = 0
    do ..checkSetup() 

    Try {
        LOCK +IdGeneratorLock:..#DefaultTimeout

        if '$TEST {
            $$$LOGERROR("[JobService.GetNextId] Failed to get next Id")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        set id = ^DataGen.Job("info","nextId") 
        set ^DataGen.Job("info","nextId") = ^DataGen.Job("info","nextId") + 1
        LOCK -IdGeneratorLock
        $$$LOGINFO("[JobService.GetNextId] Next job id: "_id)
        return id
     
      } catch exception {
        do LOG^%ETN
        if locked {
            Lock -IdGeneratorLock
        }
        Throw exception
    }
}

/// Create a job record
/// [Return value]
/// Job Id
ClassMethod AddJob() As %Integer
{
    $$$LOGINFO("[JobService.AddJob] Start adding a new job.")
    do ..checkSetup()

	set status = ##class(JobService).GetTicketForJob()
    if 'status {
        set msg = "The number of process reaches the maximum ("_^DataGen.Job("info","maxProcess")_"). Please terminate some jobs before retry."
        Throw ##class(%Exception.General).%New("ReachLimitException","","CDUI.Web.Service.JobService", msg)
    } 

    TSTART
    set locked = 0
    Try {
        LOCK +^DataGen.Job("info","size"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.AddJob] Failed to add a Job.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        set id = ..GetNextId()
        set ^DataGen.Job("item",id,"status") = ..#StatusCreate //Update it in job process
        set ^DataGen.Job("item",id,"pid") = 0 //Update it in job process
        set ^DataGen.Job("item",id,"apiLogRelativeUrl") = "" //Update it in after the log is created
        set ^DataGen.Job("item",id,"createDateTime") = $ZDATETIME($HOROLOG,3,7)  //e.g. "2023-02-07T06:12:15Z"
        set ^DataGen.Job("item",id,"completeDateTime") = "" //Update it in job process
        set ^DataGen.Job("item",id,"lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)   
        set ^DataGen.Job("info","size") = ^DataGen.Job("info","size") + 1
        Lock -^DataGen.Job("info","size")
        TCOMMIT
        $$$LOGINFO("[JobService.AddJob] Finished adding a new job. Job Id: "_id)
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Job("info","size")
        }
        TROLLBACK 
        Throw exception
    }
    return id
}

/// The function is used to update some values in the job record.
/// [Input Parameter]
/// id: Job Id
/// pid: Process Id
/// status: Job status
/// completeDateTime: the complete date time of a job (Completed or Completed with Error)
/// apiLogRelativeUrl: the relative path of Url for downloadingg the api log file
ClassMethod UpdateJob(id As %Integer, pid As %Integer, status As %String, completeDateTime As %String, apiLogRelativeUrl As %String)
{
    $$$LOGINFO("[JobService.UpdateJob] Start updating a job. Job id: "_id)
    do ..checkSetup()
    TSTART
    set locked = 0
    Try {
        LOCK +^DataGen.Job("item", id):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.UpdateJob] Failed to update a Job.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        if $Data(status) set ^DataGen.Job("item",id,"status") = status
        if $Data(pid) set ^DataGen.Job("item",id,"pid") = pid
        if $Data(completeDateTime) set ^DataGen.Job("item",id,"completeDateTime") = completeDateTime
        if $Data(apiLogRelativeUrl) set ^DataGen.Job("item",id,"apiLogRelativeUrl") = apiLogRelativeUrl


        if $Data(status) || $Data(pid) || $Data(completeDateTime) || $Data(apiLogRelativeUrl) {
            set ^DataGen.Job("item",id,"lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)  
        }
        Lock -^DataGen.Job("item", id)
        TCOMMIT
        $$$LOGINFO("[JobService.UpdateJob] Finished updating a job. Job Id: "_id)
       
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Job("item", id)
        }
        TROLLBACK 
        Throw exception
    }
}

/// Kill the process of rhe job if it is in status "Create" or "In Progress"
/// [Input parameter]
/// id: Job Id
ClassMethod TerminateJob(id As %Integer)
{
    $$$LOGINFO("[JobService.TerminateJob] Start terminating a job. Job Id: "_id)
    do ..checkSetup()
    TSTART
    set locked = 0
    Try {
        LOCK +^DataGen.Job("item",id):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.TerminateJob] Failed to terminate a Job.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }
        
        set locked = 1
        if ($Data(^DataGen.Job("item",id))  = 0) { 
            $$$LOGINFO("[JobService.TerminateJob] Job is not found. Job Id: "_id)
            Throw ##class(%Exception.General).%New("RecordNotFoundException",5809,"CDUI.Web.Service.JobService","The record is not found.")
        }

        set status = ^DataGen.Job("item",id, "status")
        if ((status '= ..#StatusCreate) && (status '= ..#StatusInProgress)){    
            Throw ##class(%Exception.General).%New("ActionNotValidException",6215,"CDUI.Web.Service.JobService","Only Create or In Progress can be terminated. (Job id: "_id_")")
        }

        do ..TerminateJobItem(id)

        if ((status = ..#StatusCreate)  || (status = ..#StatusInProgress)){
            do ..RemoveTicketForJob() 
        }
        Lock -^DataGen.Job("item",id)
        TCOMMIT
        $$$LOGINFO("[JobService.TerminateJob] Finished terminating a job. Job Id: "_id)
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Job("item",id)
        }
        TROLLBACK 
        Throw exception
    }
}

/// Terminate the job if it is in status "Create" or "In Progress". Also, it deletes the job record from ^DataGen.Job 
/// [Input parameter]
/// id: Job Id
ClassMethod DeleteJob(id As %Integer)
{
    $$$LOGINFO("[JobService.DeleteJob] Start deleting a job. Job Id: "_id)
    do ..checkSetup()
    TSTART
    set locked = 0
    Try {
        LOCK +(^DataGen.Job("info","size"),^DataGen.Job("item",id)):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[JobService.DeleteJob] Failed to delete a Job.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.Web.Service.JobService","Failed to get an exclusive lock.")
        }

        set locked = 1
        if ($Data(^DataGen.Job("item",id))  = 0) { 
            $$$LOGINFO("[JobService.DeleteJob] Job is not found. Job Id: "_id)
            Lock -(^DataGen.Job("info","size"),^DataGen.Job("item",id))
            Throw ##class(%Exception.General).%New("RecordNotFound",5809,"CDUI.Web.Service.JobService","The record is not found.")
        }
        
        set status = ^DataGen.Job("item",id, "status")
        if ((status = ..#StatusCreate) || (status = ..#StatusInProgress)){    
            do ..RemoveTicketForJob()
        }

        //If the job is not terminated, terminate it before remove it.
        do ..TerminateJobItem(id)

        //Remove the job from global variable
        do ..RemoveJobItem(id)
        //update the size
        set ^DataGen.Job("info","size") = ^DataGen.Job("info","size") - 1
        
        Lock -(^DataGen.Job("info","size"),^DataGen.Job("item",id))
        TCOMMIT
        $$$LOGINFO("[JobService.DeleteJob] Finished deleting a job. Job Id: "_id)
        
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -(^DataGen.Job("info","size"),^DataGen.Job("item",id))
        }
        TROLLBACK 
        Throw exception
    }
}

/// Use this function to update the job after it is completed succesfully
/// [Input parameter]
/// id: Job Id
/// apiLogRelativeUrl: the relative path of Url for downloadingg the api log file
ClassMethod FinishJob(id As %Integer, apiLogRelativeUrl As %String)
{
    $$$LOGINFO("[JobService.FinishJob] Update to Completed. Job Id: "_id)
    do ..UpdateJob(id, , ..#StatusCompleted, $ZDATETIME($HOROLOG,3,7),apiLogRelativeUrl)
    do ..RemoveTicketForJob()
}

/// Use this function to update the job after it is completed with error
/// [Input parameter]
/// id: Job Id
/// apiLogRelativeUrl: the relative path of Url for downloadingg the api log file
ClassMethod FinishJobWithError(id As %Integer, apiLogRelativeUrl As %String)
{
    $$$LOGINFO("[JobService.FinishJobWithError] Update to Completed With Error. Job Id: "_id)
    do ..UpdateJob(id, , ..#StatusCompletedWithError, $ZDATETIME($HOROLOG,3,7),apiLogRelativeUrl)
    do ..RemoveTicketForJob()
}

/// Use this function to update the job after it is error
/// [Input parameter]
/// id: Job Id
/// apiLogRelativeUrl: the relative path of Url for downloadingg the api log file
ClassMethod ErrorJob(id As %Integer, apiLogRelativeUrl As %String)
{
    $$$LOGINFO("[JobService.ErrorJob] Update to Error. Job Id: "_id)
    //do ..TerminateJob(id)
    do ..UpdateJob(id, , ..#StatusError,,apiLogRelativeUrl)
    do ..RemoveTicketForJob()
}

/// Remove the job record from ^DataGen.Job 
/// [Input parameter]
/// id: Job Id
ClassMethod RemoveJobItem(id As %Integer) [ Private ]
{
    $$$LOGINFO("[JobService.RemoveJobItem] Remove a Job Item, Job Id: "_id)
    SET key=$ORDER(^DataGen.Job("item",id,""),1)
    WHILE (key'="") {
        kill ^DataGen.Job("item",id, key)  
        SET key = $ORDER(^DataGen.Job("item",id,key),1)  
    }
    kill ^DataGen.Job("item",id)
}

/// Teminerate the job
/// [Input parameter]
/// id: Job Id
ClassMethod TerminateJobItem(id As %Integer) [ Private ]
{
    set status = ^DataGen.Job("item",id, "status")
    $$$LOGINFO("[JobService.TerminateJobItem] Before Job termination, Job Id: "_id_", Job status: "_status)
   
    if ((status = ..#StatusCreate) || (status = ..#StatusInProgress)){    
        if (status = ..#StatusInProgress){  
            do $SYSTEM.Process.Terminate(^DataGen.Job("item",id, "pid"))
        }
        set ^DataGen.Job("item",id, "status") =  ..#StatusTerminated
        set ^DataGen.Job("item",id, "lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)  
    }
        
    $$$LOGINFO("[JobService.TerminateJobItem] After Job termination, Job Id: "_id_", Job status: "_^DataGen.Job("item",id, "status"))
}

/// Get the job info list with pagination
/// [Input parameter]
/// count: the number of record to be retrieved
/// idPtr: a pointer which points to the job id
/// isForwardDisplay : 0 indicates descending display, 1 indicates ascending display
/// isForward : 0 indicates descending move , 1 indicates ascending move
/// sortBy: 0 indicate acsending 1 indicates descending
/// endpointUrl: used to compose previous page url and next page url
/// [Return value]
/// GetJobsForDisplayVo: contains the job info for display
ClassMethod GetJobsForDisplay(count As %Integer = 10, idPtr As %Integer = "", isForwardDisplay As %Integer = 1, isForward As %Integer = 1, sortBy As %Integer = 1, endpointUrl As %String) As CDUI.Web.Vo.GetJobsForDisplayVo
{
    $$$LOGINFO("[JobService.GetJobsForDisplay] Start getting the jobs, count: "_count_", idPtr: "_idPtr_", isForward: "_isForward)
    do ..checkSetup()
    if (isForward <= 0) {
        set isForward = -1
    } else {
        set isForward = 1
    }

    SET key=$ORDER(^DataGen.Job("item",idPtr), isForward)

    set getJobsForDisplayVo = ##class(CDUI.Web.Vo.GetJobsForDisplayVo).%New()
    set getJobsForDisplayVo.results = ##class(%ListOfObjects).%New()
    set results = getJobsForDisplayVo.results

    set noOfJob = ^DataGen.Job("info","size")
    set counter = 1

    WHILE (key'="") {
        set jobVo = ##class(CDUI.Web.Vo.JobVo).%New()
        set jobVo.id = key
        set jobVo.pid = $Get(^DataGen.Job("item", key, "pid"),"")
        set jobVo.status = $Get(^DataGen.Job("item", key, "status"),"")  
        set jobVo.createDateTime = $Get(^DataGen.Job("item", key, "createDateTime") ,"")  
        set jobVo.completeDateTime = $Get(^DataGen.Job("item", key, "completeDateTime")  ,"") 
        set jobVo.lastUpdateDateTime =$Get(^DataGen.Job("item", key, "lastUpdateDateTime")  ,"") 
        set jobVo.apiLogRelativeUrl =$Get(^DataGen.Job("item", key, "apiLogRelativeUrl")  ,"") 
        do results.Insert(jobVo)

        if (counter >= count) {
            quit
        }
        set counter = counter + 1
        SET key = $ORDER(^DataGen.Job("item",key), isForward)  
    }
    set getJobsForDisplayVo.count = results.Count()

    set startId = idPtr
    set endId = idPtr

    if (results.Count() > 0) {
        if (isForward = 1){
            set startId = results.GetAt(1).id
            set endId = results.GetAt(results.Count()).id  
        } else {
            set startId =  results.GetAt(results.Count()).id 
            set endId = results.GetAt(1).id
        }
    }

    $$$LOGINFO("[JobService.GetJobsForDisplay] startId: "_startId_", endId: "_endId)
    
    set isPrev = 0
    set isNext = 0

    set prevKey = $ORDER(^DataGen.Job("item",startId), -1)
    set nextKey = $ORDER(^DataGen.Job("item",endId), 1)

    if (isForwardDisplay = 0){
        set tmp = prevKey
        set prevKey = nextKey
        set nextKey = tmp
    }

    if (prevKey '= "") {
        set isPrev = 1
    }
    if (nextKey '= "") {
        set isNext = 1
    }
    $$$LOGINFO("[JobService.GetJobsForDisplay] isPrev: "_isPrev_", isNext: "_isNext)
    $$$LOGINFO("[JobService.GetJobsForDisplay] prevKey: "_prevKey_", nextKey: "_nextKey)

    set link = ##class(%DynamicObject).%New()
    set link.nextPage = ""
    set link.previousPage = ""
    set getJobsForDisplayVo.links = link

    if isPrev {
        if (isForwardDisplay = 1){
            set link.previousPage = endpointUrl_"?count="_count_"&beforeId="_startId
        } else {
            set link.previousPage =  endpointUrl_"?count="_count_"&afterId="_endId
        }
    }

    if isNext {
        if (isForwardDisplay = 1){
            set link.nextPage = endpointUrl_"?count="_count_"&afterId="_endId
        } else {
            set link.nextPage = endpointUrl_"?count="_count_"&beforeId="_startId
        }
    }

    if ((isForward = 1 && sortBy = 1) || (isForward = -1 && sortBy = 0)){
        do ..reverseListOrder(.results)
    }

    $$$LOGINFO("[JobService.GetJobsForDisplay] prev: "_link.previousPage)
    $$$LOGINFO("[JobService.GetJobsForDisplay] next: "_link.nextPage)
    $$$LOGINFO("[JobService.GetJobsForDisplay] Finished getting the jobs, count: "_count_", idPtr: "_idPtr)

    return getJobsForDisplayVo
}

/// To reverse the list order
ClassMethod reverseListOrder(ByRef list As %ListOfObjects) [ Private ]
{
    set tmp = ##class(%ListOfObjects).%New()
    set size = list.Count()
    for cnt=1:1:size {
        do tmp.Insert(list.GetAt((size - cnt + 1)))
    }
    do list.Clear()
    for cnt=1:1:size {
        do list.Insert(tmp.GetAt(cnt))
    }
}

}
