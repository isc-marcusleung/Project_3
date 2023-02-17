Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Class CDUI.DataGen.ExportLog
{

// read file name from constant class and initialize the log file

// then move to the end of the txt file 

ClassMethod OpenAndMoveToEnd(Output logFile)
{
    set logFileName = ##class(Constants).#logFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WR")
    while ('logFile.AtEnd){
        d logFile.Read()
    }
}

// log job status when starting to create pat/epi/obs/order/appo

// the job_log.txt file will be erased first 

ClassMethod LogJob(jobId As %String = "123", jobType As %String = "Patient Creation")
{
    set logFileName = ##class(Constants).#logFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")  //will overwrite the existing file
    Do logFile.WriteLine("JobId: "_jobId)
    Do logFile.WriteLine("JobType: "_jobType)
    do logFile.Close()
}

// log request body for each single creation event 

ClassMethod LogRequest(RequestBody As %String = "Request body sample")
{
    do ..OpenAndMoveToEnd(.logFile)
    Do logFile.WriteLine("Request body: "_RequestBody)
    #; Do logFile.WriteLine(RequestBody)
    Do logFile.Close()
}

// log response body for each single creation event 

ClassMethod LogResponse(ResponseBody As %String = "Response body sample")
{
    do ..OpenAndMoveToEnd(.logFile)
    Do logFile.WriteLine("Response body: "_ResponseBody)
    #; Do logFile.WriteLine(RequestBody)
    Do logFile.Close()
}

// log status code and status line from HttpResponse

ClassMethod LogStatus(statusCode As %String, statusLine As %String)
{
    do ..OpenAndMoveToEnd(.logFile)
    Do logFile.WriteLine("HTTPResponse status: "_statusCode)
    Do logFile.WriteLine("HTTPResponse status line: "_statusLine)
    Do logFile.WriteLine("")
    Do logFile.Close()
}

// log response time for each single creation event 

ClassMethod LogRespondTime(RespondTime As %String = "Respond time sample")
{
    do ..OpenAndMoveToEnd(.logFile)
    Do logFile.WriteLine("Respond time in ms: "_RespondTime)
    Do logFile.Close()
}

ClassMethod LogAPI(URL As %String)
{
    do ..OpenAndMoveToEnd(.logFile)
    Do logFile.Write("API is: "_URL)
    Do logFile.Close()
}

}
