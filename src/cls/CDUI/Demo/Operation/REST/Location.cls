Class CDUI.Demo.Operation.REST.Location Extends EnsLib.REST.Operation
{

XData MessageMap
{
<MapItems>
  <MapItem MessageType="CDUI.Demo.Request.Location">
    <Method>getLocationList</Method>
  </MapItem>
  <MapItem MessageType="CDUI.Demo.Request.NewLocation">
    <Method>createNewLocation</Method>
  </MapItem>
</MapItems>
}

Parameter ADAPTER As STRING = "CDUI.Demo.HTTP.OutboundAdaptor";

/// 2 modes: Queue, InProc
Parameter INVOCATION = "Queue";

Method getLocationList(Request As CDUI.Demo.Request.Location, Output Response As Ens.StringResponse) As %Status
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
		if '$isobject(..Adapter.%CredentialsObj) 
		{
			do ..Adapter.CredentialsSet(..Adapter.Credentials)
		}
		set ..Adapter.HttpHeaders("TUSERNAME") = ..Adapter.%CredentialsObj.Username
		set ..Adapter.HttpHeaders("TPASSWORD") = ..Adapter.%CredentialsObj.PasswordGet()
		set ..Adapter.HttpHeaders("TENCRYPTED") = 0

		set URL = ..Adapter.URL_UrlParams
		$$$LOGINFO(URL)
		set sc = ..Adapter.GetURL(URL,.HttpResponse)
		if $$$ISERR(sc) return sc
		if $isobject(HttpResponse)
		{
			set body = {}.%FromJSON(HttpResponse.Data)
			$$$LOGINFO("JSON Body : "_body.%ToJSON())
			do HttpResponse.Data.Rewind()
			while 'HttpResponse.Data.AtEnd
			{
				set value = value_HttpResponse.Data.Read(32768)
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

Method createNewLocation(Request As CDUI.Demo.Request.NewLocation, Output Response As Ens.StringResponse) As %Status
{
	#dim sc as %Status = $$$OK
	#dim UrlParams, json, value as %String = ""
	#dim ex As %Exception.AbstractException
	try 
	{
		set sc = Request.%JSONExportToString(.body)
		if '$isobject(..Adapter.%CredentialsObj) 
		{
			do ..Adapter.CredentialsSet(..Adapter.Credentials)
		}
		set ..Adapter.HttpHeaders("TUSERNAME") = ..Adapter.%CredentialsObj.Username
		set ..Adapter.HttpHeaders("TPASSWORD") = ..Adapter.%CredentialsObj.PasswordGet()
		set ..Adapter.HttpHeaders("TENCRYPTED") = 0

		set URL = ..Adapter.URL
		$$$LOGINFO(URL)
		set sc = ..Adapter.PutURL(URL,.HttpResponse,,.body)
		if $$$ISERR(sc) return sc
		if $isobject(HttpResponse)
		{
			set body = {}.%FromJSON(HttpResponse.Data)
			$$$LOGINFO("JSON Body : "_body.%ToJSON())
			do HttpResponse.Data.Rewind()
			while 'HttpResponse.Data.AtEnd
			{
				set value = value_HttpResponse.Data.Read(32768)
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
