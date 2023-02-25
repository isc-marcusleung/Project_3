Import (CDUI.Web.Service, CDUI.DataGen.Common)

Class CDUI.Web.Rest.handler Extends %CSP.REST [ ProcedureBlock ]
{

/// The status which is indicated in response JSON.
Parameter SUCCESS = "Success";

/// The status which is indicated in response JSON.
Parameter ERROR = "Error";

/// Get the latest Job info List for the display in the Web UI
ClassMethod GetJobs() As %Status
{
	set count = $Get(%request.Data("count", 1))
	set beforeId = $Get(%request.Data("beforeId", 1))
	set afterId = $Get(%request.Data("afterId", 1))
	set %response.ContentType = ..#CONTENTTYPEJSON

	set idPtr = ""
	set isForwardDisplay = 0
	set isForward = 0
	set sortBy = 1

	if (beforeId '= ""){
		set idPtr = beforeId
		set isForward = -1
	} elseif (afterId '="") {
		set idPtr = afterId
		set isForward = 1
	}

	Try {
		set getJobsForDisplayVo = ##class(JobService).GetJobsForDisplay(count,idPtr,isForwardDisplay,isForward,sortBy,%request.URL)
   		set getJobsForDisplayVo.status = ..#SUCCESS
	} catch ex {
		do LOG^%ETN
		set getJobsForDisplayVo.status = ..#ERROR
		set getJobsForDisplayVo.message = ex.Name_"("_ex.Code_")"_": "_ex.Data
	}

	write getJobsForDisplayVo.SerialisedGet()

	Quit $$$OK
}

/// Ceate a Job record and create a new process to handle the job
ClassMethod AddJob() As %Status
{
	set isReqBody = $order(%request.Data("")) '= ""
	set isValid = 0
	set %response.ContentType = ..#CONTENTTYPEJSON

	if (isReqBody) {
		set request = ##class(CDUI.Web.Request.CreateJobRequest).newInstance(%request)
		set isValid = ##class(CDUI.Web.Request.CreateJobRequest).isRequestValid(request)
	}

    if ('isValid || 'isReqBody) {
        set obj = {
			"status" : (..#ERROR),
			"message" : "Invalid Parameter"
		}
        write obj.%ToJSON()
	    Quit $$$OK
    }

	Try {
		set jobId = ##class(JobService).AddJob()
		set ^DataGen.Log(jobId,"request") = request.SerialisedGet()
		set paramValue = request.generateStringParamValues()
		set ^DataGen.Log(jobId, "reqStr") = paramValue
		job ##class(DataGenService).processRequest(paramValue, jobId)

		set obj = {
			"status" : (..#SUCCESS),
			"jobId" : (jobId)
		}
	} catch ex {
		do LOG^%ETN
		set obj = {
			"status" : (..#ERROR),
			"message" : (ex.Name_"("_ex.Code_")"_": "_ex.Data)
		}
	}

	write obj.%ToJSON()
	Quit $$$OK
}

/// Terminate a Job and delete a job record
/// [Input parameter]
/// id: Job id
ClassMethod DeleteJob(id As %Integer) As %Status
{
	Try {
		do ##class(JobService).DeleteJob(id)
		set obj = {
			"status" : (..#SUCCESS)
		}
	} catch ex {
		do LOG^%ETN
		set obj = {
			"status" : (..#ERROR),
			"message" : (ex.Name_"("_ex.Code_")"_": "_ex.Data)
		}
	}
	write obj.%ToJSON()

	Quit $$$OK
}

/// Stop a job process
/// [Input parameter]
/// id: Job id
ClassMethod TerminateJob(id As %Integer) As %Status
{
	Try {
		do ##class(JobService).TerminateJob(id)
		set obj = {
			"status" : (..#SUCCESS)
		}
	} catch ex {
		do LOG^%ETN
		set obj = {
			"status" : (..#ERROR),
			"message" : (ex.Name_"("_ex.Code_")"_": "_ex.Data)
		}
	}
	write obj.%ToJSON()

	Quit $$$OK
}

/// For control and configuration purpose inclduing clear cache, log, api log file and reset all setting
ClassMethod SetConfig() As %Status
{
	set isReqBody = %request.Content '= ""
	set isValid = 0
	set %response.ContentType = ..#CONTENTTYPEJSON
	set errMsg =  "Invalid Parameter"
	try {
		if (isReqBody) {
			set dynamicObj = ##class(%DynamicObject).%FromJSON(%request.Content)
			set action = dynamicObj.action

			if action = 1 {
				//purge cache
				do ##class(CDUI.DataGen.DataGenService.Cache.LocationService).clearCache()
				do ##class(CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService).clearCache()
				set isValid = 1
			} elseif action = 2 {
				//purge log
				kill ^DataGen.Log
				kill ^DataGen.APILog
				set isValid = 1
			} elseif action = 3 {
				//Delete All API Log File
				set dir = ##class(Constants).#baseDir_##class(Constants).#apiLogRelativeDir
				set DirExist = ##class(%File).DirectoryExists(dir)
				set isValid = 1
				if DirExist {
					set result = ##class(%File).RemoveDirectoryTree(dir)
					if result = 0 {
						set isValid = 0
						set errMsg = "Failed to delete Log files"
					}
				} 
			} elseif action = 4 {
				//reset all
				do ##class(CDUI.DataGen.DataGenService.Cache.LocationService).clearCache()
				do ##class(CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService).clearCache()
				kill ^DataGen.Log
				kill ^DataGen.APILog
				SET key=$ORDER(^DataGen.Job("item",""))
				WHILE (key'="") {
					SET tmpKey = $ORDER(^DataGen.Job("item",key))  
					do ##class(JobService).DeleteJob(key)
					set key = tmpKey
				}
				kill ^DataGen.Job
				set isValid = 1
				
				set dir = ##class(Constants).#baseDir_##class(Constants).#apiLogRelativeDir
				set DirExist = ##class(%File).DirectoryExists(dir)
				if DirExist {
					set result = ##class(%File).RemoveDirectoryTree(dir)
					if result = 0 {
						set isValid = 0
						set errMsg = "Failed to delete Log files"
					}
				} 
			} 
		}

		if ('isValid || 'isReqBody) {
			set obj = {
				"status" : (..#ERROR),
				"message" : (errMsg)
			}
    	} else {
			set obj = {
				"status" : (..#SUCCESS)
			}
		}

	} catch ex {
		do LOG^%ETN
		set obj = {
			"status" : (..#ERROR),
			"message" : (ex.Name_"("_ex.Code_")"_": "_ex.Data)
		}
	}

	write obj.%ToJSON()
	Quit $$$OK
}

Parameter HandleCorsRequest = 0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/job" Method="GET" Call="GetJobs"/>
<Route Url="/addJob" Method="POST" Call="AddJob"/>
<Route Url="/job/:id" Method="DELETE" Call="DeleteJob"/>
<Route Url="/job/terminate/:id" Method="POST" Call="TerminateJob"/>
<Route Url="/setConfig" Method="POST" Call="SetConfig"/>
</Routes>
}

}
