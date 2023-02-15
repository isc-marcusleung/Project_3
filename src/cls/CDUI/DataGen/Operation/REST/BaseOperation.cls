Class CDUI.DataGen.Operation.REST.BaseOperation Extends EnsLib.REST.Operation
{

Parameter ADAPTER As STRING = "CDUI.DataGen.HTTP.OutboundAdaptor";

Parameter INVOCATION As STRING = "Queue";

Parameter DataReadBuffer As INTEGER = 32768;

Method setupCredential()
{
	set ..Adapter.Credentials = ""
    #; set ..Adapter.HttpHeaders("TUSERNAME") = ..Adapter.%CredentialsObj.Username
    #; set ..Adapter.HttpHeaders("TPASSWORD") = ..Adapter.%CredentialsObj.PasswordGet()
	set ..Adapter.HttpHeaders("TUSERNAME") = "auadm"
    set ..Adapter.HttpHeaders("TPASSWORD") = "pass"
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
		//Log request body
		do ##class(CDUI.DataGen.ExportLog).LogRequest(Request.SerialisedGet())

		set sc = Request.%JSONExportToString(.body)
		do ..setupCredential()
		set URL = ..Adapter.URL
		$$$LOGINFO(URL)

		//Calculate response time of the API call
		set t1 = $zdatetime($ZTIMESTAMP,3,1,3)
		set sc = ..Adapter.PutURL(URL,.HttpResponse,,.body)
		set t2 = $zdatetime($ZTIMESTAMP,3,1,3)
		&sql(SELECT {fn TIMESTAMPDIFF(SQL_TSI_FRAC_SECOND,:t1,:t2)} into :ResponseTime )

		//Log response time 
		do ##class(CDUI.DataGen.ExportLog).LogRespondTime(ResponseTime)

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

			//Log response body 
			do ##class(CDUI.DataGen.ExportLog).LogResponse(value)
			
			//Log HTTPResponse status code and status line 
			do ##class(CDUI.DataGen.ExportLog).LogStatus(HttpResponse.StatusCode,HttpResponse.StatusLine)

			// Update the properties in the response object
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

}
