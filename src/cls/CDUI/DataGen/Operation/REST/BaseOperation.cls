Class CDUI.DataGen.Operation.REST.BaseOperation Extends EnsLib.REST.Operation
{

Parameter ADAPTER As STRING = "CDUI.DataGen.HTTP.OutboundAdaptor";

Parameter INVOCATION As STRING = "Queue";

Parameter DataReadBuffer As INTEGER = 32768;

Method setupCredential()
{
	if '$isobject(..Adapter.%CredentialsObj) 
	{
		do ..Adapter.CredentialsSet(..Adapter.Credentials)
	}
	
	set ..Adapter.HttpHeaders("TUSERNAME") = ..Adapter.%CredentialsObj.Username
	set ..Adapter.HttpHeaders("TPASSWORD") = ..Adapter.%CredentialsObj.PasswordGet()
	set ..Adapter.HttpHeaders("TENCRYPTED") = 0
}

Method httpGet(Request As Ens.Request, Output Response As CDUI.DataGen.DataGenService.Custom.StringResponse) As %Status
{
    #dim sc as %Status = $$$OK
	#dim UrlParams, json, value as %String = ""
	#dim ex As %Exception.AbstractException
	try 
	{
		set sc = Request.%JSONExportToString(.json)
		set parameters = {}.%FromJSON(json)
		set iterator = parameters.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{
			set UrlParams = UrlParams_$select(UrlParams'="":"&",1:"?")_key_"="_value
		}

		do ..setupCredential()

		set URL = ..Adapter.URL_UrlParams
		$$$LOGINFO(URL)

		//Calculate response time of the API call
		set t1 = $zdatetime($ZTIMESTAMP,3,1,3)
		set sc = ..Adapter.GetURL(URL,.HttpResponse)
		set t2 = $zdatetime($ZTIMESTAMP,3,1,3)
		&sql(SELECT {fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,:t1,:t2)} into :ResponseTime )

		if $$$ISERR(sc) return sc
		if $isobject(HttpResponse)
		{
			set body = {}.%FromJSON(HttpResponse.Data)
			$$$LOGINFO("JSON Body : "_body.%ToJSON())
			do HttpResponse.Data.Rewind()
			while 'HttpResponse.Data.AtEnd
			{
				set value = value_HttpResponse.Data.Read(..#DataReadBuffer)
			}

			set Response = ##class(CDUI.DataGen.DataGenService.Custom.StringResponse).%New()
			set Response.StringValue = value
			set Response.ResponseTime = ResponseTime
		}
	} 
	catch ex 
	{
		do LOG^%ETN
		set sc = $$$ADDSC(sc,ex.AsStatus())
	} 
	quit sc
}

Method httpPut(Request As Ens.Request, Output Response As CDUI.DataGen.DataGenService.Custom.StringResponse) As %Status
{
    #dim sc as %Status = $$$OK
	#dim UrlParams, json, value as %String = ""
	#dim ex As %Exception.AbstractException
	try 
	{
		//obtain jobId from request 
		set jobId = Request.jobId

		//log API info
		set APILog = ##class(CDUI.DataGen.vo.APILogVo).%New()
		do ##class(CDUI.DataGen.Utils.CommonUtil).GetCurrentDT(.dateD,.timeD)
		set APILog.currentDate = dateD
		set APILog.currentTime = timeD
		set APILog.requestBody = Request.SerialisedGet()

		set sc = Request.%JSONExportToString(.body)
		do ..setupCredential()
		set URL = ..Adapter.URL
		$$$LOGINFO(URL)

		//log API info
		set APILog.APIname = URL

		//Calculate and log response time of the API call
		set t1 = $zdatetime($ZTIMESTAMP,3,1,3)
		set sc = ..Adapter.PutURL(URL,.HttpResponse,,.body)
		set t2 = $zdatetime($ZTIMESTAMP,3,1,3)
		&sql(SELECT {fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,:t1,:t2)} into :ResponseTime )
		set APILog.responseTime = ResponseTime

		
		if $$$ISERR(sc) return sc
		if $isobject(HttpResponse)
		{
			set body = {}.%FromJSON(HttpResponse.Data)
			$$$LOGINFO("JSON Body : "_body.%ToJSON())
			do HttpResponse.Data.Rewind()
			while 'HttpResponse.Data.AtEnd
			{
				set value = value_HttpResponse.Data.Read(..#DataReadBuffer)
			}

			//Log API info
			set APILog.responseBody = value
			set APILog.HTTPResponseStatusCode = HttpResponse.StatusCode
			set APILog.HTTPResponseStatusLine = HttpResponse.StatusLine
			do APILog.concatenateProp(.info)

			// Update the properties in the response object
			set Response = ##class(CDUI.DataGen.DataGenService.Custom.StringResponse).%New()
			set Response.StringValue = value
			set Response.ResponseTime = ResponseTime
		}
		set counter = $i(^DataGen.APILog("info",jobId))
		set ^DataGen.APILog("info",jobId,counter) = info
	} 
	catch ex 
	{
		do LOG^%ETN
		set sc = $$$ADDSC(sc,ex.AsStatus())
	} 
	quit sc
}

Method httpGetById(Request As Ens.Request, Output Response As Ens.StringResponse) As %Status
{
    #dim sc as %Status = $$$OK
	#dim UrlParams, json, value as %String = ""
	#dim ex As %Exception.AbstractException
	try 
	{
		set sc = Request.%JSONExportToString(.json)
		
		set parameters = {}.%FromJSON(json)
		
		set iterator = parameters.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{			
			set UrlParams = UrlParams_$select(UrlParams'="":"&",1:"/")_value
		}

		do ..setupCredential()

		set URL = ..Adapter.URL_UrlParams
		$$$LOGINFO(URL)
		set sc = ..Adapter.GetURL(URL,.HttpResponse)
		if $$$ISERR(sc) return sc
		if $isobject(HttpResponse)
		{
			set body = {}.%FromJSON(HttpResponse.Data)
			do HttpResponse.Data.Rewind()
			while 'HttpResponse.Data.AtEnd
			{
				set value = value_HttpResponse.Data.Read(..#DataReadBuffer)
			}
			set Response = ##class(Ens.StringResponse).%New()
			set Response.StringValue = value
		}
	} 
	catch ex 
	{
		do LOG^%ETN
		set sc = $$$ADDSC(sc,ex.AsStatus())
	} 
	quit sc
}

}
