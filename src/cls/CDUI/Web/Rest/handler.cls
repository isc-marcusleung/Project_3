Import CDUI.Web.Service

Class CDUI.Web.Rest.handler Extends %CSP.REST [ ProcedureBlock ]
{

ClassMethod GetJobs() As %Status
{
	set count = $Get(%request.Data("count", 1))
	set beforeId = $Get(%request.Data("beforeId", 1))
	set afterId = $Get(%request.Data("afterId", 1))
	set %response.ContentType = ..#CONTENTTYPEJSON

	if $Data(beforeId) {
		set idPtr = beforeId
	} else {
		set idPtr = afterId
	}

	set getJobsForDisplayVo = ##class(JobService).GetJobsForDisplay(count,idPtr,-1,%request.URL)
    
	write getJobsForDisplayVo.SerialisedGet()

	Quit $$$OK
}

ClassMethod AddJob() As %Status
{
	set isReqBody = %request.Content '= ""
	set isValid = 0
	set %response.ContentType = ..#CONTENTTYPEJSON

	if (isReqBody) {
		set contentDO = ##class(%DynamicObject).%FromJSON(%request.Content)
		set request = ##class(CDUI.Web.Request.CreateJobRequest).newInstance(contentDO)
		set isValid = ##class(CDUI.Web.Request.CreateJobRequest).isRequestValid(request)
	}

    if ('isValid || 'isReqBody) {
        set obj = {
			"Error" : "Invalid Parameter"
		}
        write obj.%ToJSON()
	    Quit $$$OK
    }
	//TODO marcus to see if i need to catch the exception
	set jobId = ##class(JobService).AddJob()
	job ##class(DataGenService).prcoessRequest(request, jobId)

	set obj = {
		"jobId" : (jobId)
	}
	write obj.%ToJSON()
	Quit $$$OK
}

ClassMethod DeleteJob(id As %Integer) As %Status
{
	do ##class(JobService).DeleteJob(id)
	Quit $$$OK
}

ClassMethod TerminateJob(id As %Integer) As %Status
{
	do ##class(JobService).TerminateJob(id)
	Quit $$$OK
}

Parameter HandleCorsRequest = 0;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/job" Method="GET" Call="GetJobs"/>
<Route Url="/job" Method="PUT" Call="AddJob"/>
<Route Url="/job/:id" Method="DELETE" Call="DeleteJob"/>
<Route Url="/job/terminate/:id" Method="POST" Call="TerminateJob"/>
</Routes>
}

}
