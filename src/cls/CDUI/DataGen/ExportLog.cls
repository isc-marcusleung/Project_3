Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Class CDUI.DataGen.ExportLog Extends Ens.Util.IOLogger
{

// read from the global to log api info

ClassMethod WriteAPILog(jobId As %Integer) As %String
{
    set baseDir = ##class(Constants).#baseDir_##class(Constants).#apiLogRelativeDir
    set DirExist = ##class(%File).DirectoryExists(baseDir)
    if 'DirExist {
        do ##class(%File).CreateDirectory(baseDir, .return)
    } 

    set logFileName = jobId_"_"_$REPLACE($REPLACE($ZDATETIME($HOROLOG,8,1)," ","_"),":","" )_".csv"
    set logFile=##class(%File).%New(baseDir_logFileName)
    Do logFile.Open("WSN")  
    Do logFile.WriteLine("sep = ;")
    Do logFile.WriteLine("date;time;API_name;request_body;response_body;response_time;http_statuscode;http_statusline")

    set cnt = $Get(^DataGen.APILog("info",jobId),0)
    $$$LOGINFO("cnt: "_cnt)
    for i = 1:1:cnt{
        set info = ^DataGen.APILog("info",jobId,i)
        do ..FixInfo(info,.fixedInfo)
        Do logFile.WriteLine(fixedInfo)
    }
    do logFile.Close()
    return logFileName
}

// Fix the response string before inserting it to the csv file 

ClassMethod FixInfo(info As %String, Output fixedInfo As %String)
{
    set searchStr = """"
    set replaceStr = """"""
    set fixedInfo =  $REPLACE(info, searchStr, replaceStr)
    set searchStr2 = "{"
    set replaceStr2 = """{"
    set fixedInfo = $REPLACE(fixedInfo, searchStr2, replaceStr2)
    set searchStr3 = "}"
    set replaceStr3 = "}"""
    set fixedInfo = $REPLACE(fixedInfo, searchStr3, replaceStr3)
}

ClassMethod InitializeDebugLog()
{
    set logFileName = ##class(Constants).#debugLogFileName
    set logFile=##class(%File).%New(logFileName)
    Do logFile.Open("WSN")
    Do logFile.WriteLine("Initialize debug log.") 
    do logFile.Close()
}

}
