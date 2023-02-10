Import CDUI.Web.Service

Class CDUI.Web.Rest.handler Extends %CSP.REST [ ProcedureBlock ]
{

Parameter SUCCESS = "Success";

Parameter ERROR = "Error";

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

ClassMethod AddJob() As %Status
{
	set isReqBody = $order(%request.Data("")) '= ""
	set isValid = 0
	set %response.ContentType = ..#CONTENTTYPEJSON

	if (isReqBody) {
		set contentDO = ##class(%DynamicObject).%FromJSON(%request.Content)
		set request = ##class(CDUI.Web.Request.CreateJobRequest).newInstance(contentDO)
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
	//TODO marcus to see if i need to catch the exception
	Try {
		set jobId = ##class(JobService).AddJob()
		job ##class(DataGenService).prcoessRequest(request, jobId)
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

// TODO marucs to turn it off

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/job" Method="GET" Call="GetJobs"/>
<Route Url="/addJob" Method="POST" Call="AddJob"/>
<Route Url="/job/:id" Method="DELETE" Call="DeleteJob"/>
<Route Url="/job/terminate/:id" Method="POST" Call="TerminateJob"/>
</Routes>
}

}
