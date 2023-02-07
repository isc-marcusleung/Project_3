Class CDUI.Web.Service.JobService Extends Ens.Util.IOLogger [ ProcedureBlock ]
{

Parameter DefaultTimeout = 5;

// This class is used to manipulte the gloabl variable ^DataGen.Job

/*
^DataGen.Job("info","size")
^DataGen.Job("info","nextId")
^DataGen.Job("info","maxProcess")
^DataGen.Job("item",<id>,"status")
^DataGen.Job("item",<id>,"pid")
^DataGen.Job("item",<id>,"createDateTime")
^DataGen.Job("item",<id>,"completeDateTime")
^DataGen.Job("item",<id>,"lastUpdateDateTime")
*/
Parameter StatusCreate = "Create";

Parameter StatusInProgress = "In Progress";

Parameter StatusTerminated = "Terminated";

Parameter StatusCompleted = "Completed";

Parameter StatusError = "Error";

Parameter IdGeneratorLock = "DataGen.Job.IdGeneratorLock";

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
            set ^DataGen.Job("info","maxProcess") = 10
        } else {
            $$$LOGINFO("[JobService.InitGlobalVariable] Global variable for job is already created.")
        }
        Lock -^DataGen.Job
        $$$LOGINFO("[JobService.InitGlobalVariable] Finished initializing global variable.")
   
    } catch exception {
        if locked {
            Lock -^DataGen.Job
        }
        Throw exception
    }
}

ClassMethod checkSetup() [ Private ]
{
    if ($Data(^DataGen.Job) = 0){
        do ..InitGlobalVariable()
    }
}

/// Get a unique id for job creation.
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
        if locked {
            Lock -IdGeneratorLock
        }
        Throw exception
    }
}

ClassMethod AddJob() As %Integer
{
    $$$LOGINFO("[JobService.AddJob] Start adding a new job.")
    do ..checkSetup()
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
        set ^DataGen.Job("item",id,"createDateTime") = $zdatetime($horolog)        
        set ^DataGen.Job("item",id,"completeDateTime") = "" //Update it in job process
        set ^DataGen.Job("item",id,"lastUpdateDateTime") = $zdatetime($horolog)   
        set ^DataGen.Job("info","size") = ^DataGen.Job("info","size") + 1
        Lock -^DataGen.Job("info","size")
        TCOMMIT
        $$$LOGINFO("[JobService.AddJob] Finished adding a new job. Job Id: "_id)
    } Catch exception {
        if locked {
            Lock -^DataGen.Job("info","size")
        }
        TROLLBACK 
        Throw exception
    }
    return id
}

ClassMethod UpdateJob(id As %Integer, pid As %Integer, status As %String, completeDateTime As %String)
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

        if $Data(status) || $Data(pid) || $Data(completeDateTime) {
            set ^DataGen.Job("item",id,"lastUpdateDateTime") = $zdatetime($horolog)  
        }
        Lock -^DataGen.Job("item", id)
        TCOMMIT
        $$$LOGINFO("[JobService.UpdateJob] Finished updating a job. Job Id: "_id)
       
    } Catch exception {
        if locked {
            Lock -^DataGen.Job("item", id)
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod DeleteJob(id As %Integer)
{
    $$$LOGINFO("[JobService.AddJob] Start deleting a job. Job Id: "_id)
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
        if locked {
            Lock -(^DataGen.Job("info","size"),^DataGen.Job("item",id))
        }
        TROLLBACK 
        Throw exception
    }
}

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

ClassMethod TerminateJobItem(id As %Integer) [ Private ]
{
    set status = ^DataGen.Job("item",id, "status")
    $$$LOGINFO("[JobService.TerminateJobItem] Before Job termination, Job Id: "_id_", Job status: "_status)
    if ( status '= ..#StatusTerminated) && (status '= ..#StatusCompleted) && (status '= ..#StatusError){  
        do $SYSTEM.Process.Terminate(^DataGen.Job("item",id, "pid"))
        set ^DataGen.Job("item",id, "status")  =  ..#StatusTerminated
    }
    $$$LOGINFO("[JobService.TerminateJobItem] After Job termination, Job Id: "_id_", Job status: "_status)
}

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
            Throw ##class(%Exception.General).%New("RecordNotFound",5809,"CDUI.Web.Service.JobService","The record is not found.")
        }

        //If the job is not terminated, terminate it before remove it.
        do ..TerminateJobItem(id)

        Lock -^DataGen.Job("item",id)
        TCOMMIT
        $$$LOGINFO("[JobService.TerminateJob] Finished deleting a job. Job Id: "_id)
        return 1
    } Catch exception {
        if locked {
            Lock -(^DataGen.Job("info","size"),^DataGen.Job("item",id))
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod GetJobsForDisplay(count As %Integer = 10, idPtr As %Integer = "", isAscending As %Integer = 1, endpointUrl As %String) As CDUI.Web.Vo.GetJobsForDisplayVo
{
    $$$LOGINFO("[JobService.GetJobsForDisplay] Start getting the jobs, count: "_count_", idPtr: "_idPtr_", isAscending: "_isAscending)

    if (isAscending > 0) {
        set isAscending = 1
    } else {
        set isAscending = -1
    }

    SET key=$ORDER(^DataGen.Job("item",idPtr), isAscending)
 
    set getJobsForDisplayVo = ##class(CDUI.Web.Vo.GetJobsForDisplayVo).%New()
    set getJobsForDisplayVo.results = ##class(%ListOfObjects).%New()
    set results = getJobsForDisplayVo.results

    set getJobsForDisplayVo.count = count
    set noOfJob = ^DataGen.Job("info","size")
    set counter = 1

    WHILE (key'="") {
        set jobVo = ##class(CDUI.Web.Vo.JobVo).%New()
        set jobVo.id = key
        set jobVo.status = ^DataGen.Job("item", key, "status")  
        set jobVo.createDateTime = ^DataGen.Job("item", key, "createDateTime")  
        set jobVo.completeDateTime = ^DataGen.Job("item", key, "completeDateTime")  
        set jobVo.lastUpdateDateTime = ^DataGen.Job("item", key, "lastUpdateDateTime")  
        do results.Insert(jobVo)

        if (counter >= count) {
            quit
        }
        set counter = counter + 1
        SET key = $ORDER(^DataGen.Job("item",key), isAscending)  
    }

    set startId = idPtr
    set endId = idPtr

    if results.Count() > 0 {
        set startId = results.GetAt(1).id
        set endId = results.GetAt(results.Count()).id  
    }

    $$$LOGINFO("[JobService.GetJobsForDisplay] startId: "_startId_", endId: "_endId)
    
    set isPrev = 0
    set isNext = 0

    if (isAscending = 1){
        set prevKey =$ORDER(^DataGen.Job("item",startId), -1)
        set nextKey=$ORDER(^DataGen.Job("item",endId), 1)
    } else {
        set prevKey =$ORDER(^DataGen.Job("item",startId), 1)
        set nextKey=$ORDER(^DataGen.Job("item",endId), -1)
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
    set link.preivousPage = ""
    set getJobsForDisplayVo.links = link

    if (isAscending = -1){
        set tmp = startId
        set startId = endId
        set endId = tmp
    }

    set url1 = endpointUrl_"?count="_count_"&beforeId="_startId
    set url2 = endpointUrl_"?count="_count_"&afterId="_endId

    if isPrev {
        if (isAscending = 1){
            set link.preivousPage = url1
        } else {
            set link.preivousPage = url2
        }
    }

    if isNext {
        if (isAscending = 1){
            set link.nextPage = url2
        } else {
            set link.nextPage = url1
        }
    }

    $$$LOGINFO("[JobService.GetJobsForDisplay] prev: "_link.preivousPage)
    $$$LOGINFO("[JobService.GetJobsForDisplay] next: "_link.nextPage)
    $$$LOGINFO("[JobService.GetJobsForDisplay] Finished getting the jobs, count: "_count_", idPtr: "_idPtr)

    return getJobsForDisplayVo
}

}
