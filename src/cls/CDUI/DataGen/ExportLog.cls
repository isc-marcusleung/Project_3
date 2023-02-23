Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Class CDUI.DataGen.ExportLog Extends Ens.Util.IOLogger
{

// read from the global to log api info

ClassMethod WriteAPILog(jobId As %Integer)
{
    set baseDir = ##class(Constants).#apiLogDir
    set DirExist = ##class(%File).DirectoryExists(baseDir)
    if 'DirExist {
        do ##class(%File).CreateDirectory(baseDir, .return)
    } 

    #; do ##class(CDUI.DataGen.Utils.CommonUtil).GetCurrentDT(.dateD,.timeD)
    #; set logFileName = baseDir_"jobID_"_jobId_"_"_dateD_"_"_timeD_".csv"

    set logFileName = baseDir_"jobID_"_jobId_".csv"
    $$$LOGINFO("baseDir: "_baseDir)
    $$$LOGINFO("logFileName: "_logFileName)
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")  
    Do logFile.WriteLine("sep = ;")
    Do logFile.WriteLine("date;time;API_name;request_body;response_body;response_time;http_statuscode;http_statusline")

    set cnt = ^DataGen.APILog("info",jobId)
    $$$LOGINFO("cnt: "_cnt)
    for i = 1:1:cnt{
        set info = ^DataGen.APILog("info",jobId,i)
        $$$LOGINFO("info: "_info)
        Do logFile.WriteLine(info)
    }
    do logFile.Close()
}

// Add a row of info in api_log file  

ClassMethod InitializeDebugLog()
{
    set logFileName = ##class(Constants).#debugLogFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")
    Do logFile.WriteLine("Initialize debug log.") 
    do logFile.Close()
}

}
