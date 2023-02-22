Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Class CDUI.DataGen.ExportLog
{

// read file name from input and initialize the log file

// initialize api_log file, add headers 

ClassMethod InitializeAPILog()
{
    set logFileName = ##class(Constants).#apiLogFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")  
    Do logFile.WriteLine("sep = ;")
    Do logFile.WriteLine("date;time;process_ID;API_name;request_body;response_body;response_time;http_statuscode;http_statusline")
    do logFile.Close()
}

// Add a row of info in api_log file  

ClassMethod InitializeDebugLog()
{
    set logFileName = ##class(Constants).#debugLogFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")
    Do logFile.WriteLine("This is a new job session.") 
    do logFile.Close()
}

ClassMethod AddRowOfLog(logFileName As %String, info As %String)
{
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WR")
    while ('logFile.AtEnd){
        d logFile.Read()
    }
    Do logFile.WriteLine(info)
    Do logFile.Close()
}

}
