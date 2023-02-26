/// REST service class ie. implementation of your business logic
Class Custom.CDUI.REST.handler Extends %CSP.REST [ ProcedureBlock ]
{

Parameter CONTENTTYPE = "application/json";

Parameter DISTRIBUTESOURCE = 1;

Parameter IgnoreWrites = 1;

Parameter HandleCorsRequest = 1;

Parameter NAMESPACE = "http://www.intersystems.com/trak/ws";

Parameter USECLASSNAMESPACES = 1;

Parameter XMLTYPE = "TC_hmf_RESTAPI_API";

ClassMethod GetAPIToken() As %String
{
	set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
	set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
	set token=$get(%request.CgiEnvs("HTTP_TOKEN"))
	set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
	i token=""
	{
		set token=##class(TC.api.Logon).Request(user,pwd,encryptpwd,.sessionid)
	}
	s sessid=$g(^CacheTemp("TCAPI",token))
	i $g(sessid)'=""
	{
		set %session=##Class(%CSP.Session).%OpenId(sessid)
		k ^CacheTemp("TCAPI",token)
	}
	i $g(%session)=""
	{
		q "E^Invalid Token - Session does not exist"
	}
	i $g(%session.Data("LOGON.API"))'=1
	{
		q "E^Invalid Token - Session not valid for API access"
	}
	q token
}

ClassMethod GetOrders() As %Status
{
	set tArr = {}
	s token=..GetAPIToken()
	i $p(token,"^",1)="E"
	{
		s res={}
		s res.Error=token
		Do ##class(Custom.CDUI.REST.impl).%WriteResponse(res)	
		q $$$OK
	}		
			
	Try {
		Do ##class(%REST.Impl).%SetContentType("application/json")
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		
		If $data(%request.Data("_count",2)) {
			Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"_count")) Quit
		}
		
		If $data(%request.Data("_count",1)) {
			Set pcount=%request.Data("_count",1)
			If ($number(pcount,"I")="") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTInvalid,"_count",pcount)) Quit
		}
		
		If $data(%request.Data("category",2)) {
			Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"category")) Quit
		}
		
		If $data(%request.Data("category",1)) {
			Set pcategory=%request.Data("category",1)
		}
		
		Set response=##class(Custom.CDUI.REST.impl).GetOrders(.pcount,.pcategory)
		Do ##class(Custom.CDUI.REST.impl).%WriteResponse(response)
		
	} Catch (ex) {
		do ex.Log()
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("Custom.CDUI.REST.impl","ExposeServerExceptions"))
	}
	
	Quit $$$OK
}

ClassMethod GetCareProviders() As %Status
{
	set tArr = {}
	s token=..GetAPIToken()
	i $p(token,"^",1)="E"
	{
		s res={}
		s res.Error=token
		Do ##class(Custom.CDUI.REST.impl).%WriteResponse(res)	
		q $$$OK
	}		
			
	Try {
		Do ##class(%REST.Impl).%SetContentType("application/json")
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		
		Set response=##class(Custom.CDUI.REST.impl).GetCareProviders()
		
		;w response.%ToJSON()
		Do ##class(Custom.CDUI.REST.impl).%WriteResponse(response)
		
	} Catch (ex) {
		do ex.Log()
		Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("Custom.CDUI.REST.impl","ExposeServerExceptions"))
	}
	
	Quit $$$OK
}

/// Dispatch individual API calls to separate endpoint classes/methods
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
		<Route Url='/cdu/GetOrders' Method='GET' Call='GetOrders' />
		<Route Url='/cdu/GetCareProviders' Method='GET' Call='GetCareProviders' />
	</Routes>
}

}
