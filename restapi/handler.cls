Class restapi.handler
{

/*
Class Custom.CDUI.REST.handler Extends %CSP.REST [ ProcedureBlock ]
{

Parameter CONTENTTYPE = "application/json";

/// REST service class ie. implementation of your business logic
Parameter DISTRIBUTESOURCE = 1;

Parameter IgnoreWrites = 1;

Parameter HandleCorsRequest = 1;

Parameter NAMESPACE = "http://www.intersystems.com/trak/ws";

Parameter USECLASSNAMESPACES = 1;

Parameter XMLTYPE = "TC_hmf_RESTAPI_API";

/*
	set obj = ##class(TC.api.PAPerson.Edit.List).%New()

	set params = ##class(TC.api.PAPerson.Edit.List.Params).%New()

	set params.TUSERNAME = "demo"

	set params.TPASSWORD= "demo"

	set params.PAPERName = "Test"

	set rtn = obj.Execute(,params)

	while rtn = 1 {

  		set rtn=obj.Next()

	}

ClassMethod ShowList(ID As %String) As %Status
{
	// API workflows for Execute a TrakCare Query

	// (Logon*)->%New API Class->Open API Parameter Class
	// ->Set Parameters->Execute Query->Next (loop through records)
	
	// kill api class
	// kill params class 
	kill api,params
	set tArr = {}
    // Custom.CDUI.REST.
	
	set apicls="TC.api."_ID

	// Open API parameter class
	set apiparcls=apicls_".Params"

	// New API class ie. make a new instance of the API class (get available methods & properties)
	set api=$classmethod(apicls,"%New")

	// Set parameters
	set params=$classmethod(apiparcls,"%New")
	do ..SetAPIToken(params)
	set otherparams=""
	do ..GetParamsQryString(params,.otherparams)
	set sc=api.Execute(,params)
	if (sc) {
		set tArr.results = []
		set tArr.links = {}
		do ..GetArrayByList(api,tArr,.otherparams)
	} else {
		do ..GetReturnMessage(api,tArr,sc)
	}
	kill api
	write tArr.%ToJSON()
	quit $$$OK
}

ClassMethod SetAPIToken(pAPI As TC.api.Abstract)
{
	set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
	set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
	set token=$get(%request.CgiEnvs("HTTP_TOKEN"))
	set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
	set pAPI.TUSERNAME = user
	set pAPI.TPASSWORD = pwd
	set pAPI.TENCRYPTPASSWORD=encryptpwd
}

ClassMethod GetReturnMessage(pAPI As TC.api.Abstract, ByRef pArray As %AbstractArray, pSc As %String, pID As %String)
{
	if $$$ISERR(pSc) {
		set $property(pArray, "ERROR") = pSc
	} elseif pID'="" {
		set $property(pArray, "OK") = "Record updated"
	} else {
		if ($isobject($get(pAPI))) {
			set $property(pArray, "ID") = pAPI.ID
		} else {
			set $property(pArray, "ERROR") = "Record not saved"
		}
	}
}

/// Show list
ClassMethod GetParamsQryString(pParams As TC.api.Abstract, Output pOtherParams As %String) As %String
{
	set pOtherParams=""
	set tQueryString = %request.GetCgiEnv("QUERY_STRING")
	for k=1:1:$length(tQueryString,"&") {
		set param=$piece(tQueryString,"&",k)
		set key=$piece(param,"=")
		set value=$piece(param,"=",2)
		if ##class(%Dictionary.CompiledProperty).%ExistsId(pParams.%ClassName(1)_"||"_key) {
			set $property(pParams, key) = value
		}
		else {
			if key'="" set pOtherParams(key)=value
		}
	}
}

ClassMethod GetArrayByList(pAPI As TC.api.Abstract, ByRef pArray As %AbstractArray, pOtherParams As %String)
{
	set (count,skipcount)=0
	set (pagelimit)=100
	set page=1
	set pageflag=0
	set showempty=$get(%request.CgiEnvs("HTTP__SHOWEMPTY"))
	if $data(pOtherParams("_count")) {
		set pagelimit=pOtherParams("_count")
		if $data(pOtherParams("page")) {
			set page=pOtherParams("page")
			set pageflag=1
		}
	}
	if +page>0 {
		set skipcount=((page-1)*pagelimit)
		set pagelimit=pagelimit*page
	}
	while (pAPI.Next())&&(count<pagelimit) {
		set count=count+1
		if (page>1)&&(skipcount)&&(count<=skipcount) continue
		set row = {}
		for col=1:1:pAPI.GetColumnCount(){
			set columname=pAPI.GetColumnName(col)
			set columndata=pAPI.GetData(col)
			if (columndata="")&&('showempty) continue
			set $property(row, columname) = columndata
		}
		do pArray.results.%Push(row)
	}
	if (page'="")&&(pageflag) {
		set scheme=$get(%request.CgiEnvs("REQUEST_SCHEME"))
		set host=$get(%request.CgiEnvs("HTTP_HOST"))
		set uri=$get(%request.CgiEnvs("REQUEST_URI"))
		set url=scheme_"://"_host_uri
		set pagec="page="
		if page>1 {
			set $property(pArray.links, "previous") = $replace(url,pagec_page,pagec_(page-1))
		}
		if pAPI.Next() {
			set $property(pArray.links, "next") = $replace(url,pagec_page,pagec_(page+1))
		}
	}
	if (page=1)&&($property(pArray.links, "next")="") {
		set $property(pArray, "count") = count
		set $property(pArray, "limit") = pagelimit
	}
}

/// Get Order
ClassMethod ShowListOrderCategory()
{
	do ..ShowList("PAPerson.List")  
	quit $$$OK
}

ClassMethod Hi() As %Status
{
    Try {
        #; set user =  ##class(%REST.Impl).%GetHeader("TUSERNAME")
		set user = $get(%request.CgiEnvs("HTTP_TUSERNAME"))
		
		if 'user{
		/* Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit 
			Set response=##class(Custom.CDUI.REST.impl).Testing()
			Do ##class(%REST.Impl).%WriteResponse(response)
		}
	}
    Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK
}

ClassMethod Testing() As %Status
{
    Try {
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
        Set response=##class(Custom.CDUI.REST.impl).Testing()
        Do ##class(%REST.Impl).%WriteResponse(response)}
    Catch (ex) {
        Do ##class(%REST.Impl).%SetStatusCode("400")
        return {"errormessage": "Client error"}
    }
    Quit $$$OK


		// Try catch block 
	#; Try {
	#; 	set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
	#; 	set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
	#; 	set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
		
	#; 	#; set token=##class(TC.api.Logon).Request(..TUSERNAME,..TPASSWORD,..TENCRYPTPASSWORD,..TSESSIONID)
	#; 	#; i $g(token)="" q "E^No Token Supplied"
	#; 	#; i $g(token)["E^" q token
		
	#; 	set token=##class(TC.api.Logon).Request(user,pwd,encryptpwd,)

	#; 	if token'="" {
	#; 		Set response=##class(Custom.CDUI.REST.impl).GetOrders(,)
    #;     	#; Do ##class(%REST.Impl).%WriteResponse(response)
	#; 	} else{
	#; 		Do ##class(%REST.Impl).%SetStatusCode("400")
	#; 		return {"errormessage": "Client error"}
	#; 	}
	#; 	}
    #; Catch (ex) {
    #;     Do ##class(%REST.Impl).%SetStatusCode("400")
    #;     return {"errormessage": "Client error"}
    #; }
	#; Quit $$$OK
	#;
}

ClassMethod Test1() As %Status
{
	set ret = ##class(%DynamicObject).%New()
	set token=##class(TC.api.Logon).Request("auadm","pass","false",)
	#; w token
	#; 
	#; So can't print out the token here???
	#; 
	#; 

	do ret.%Set("token", $get(token))
	if ret.%Get("token") '="" {
		
	}

	Write "Session ID is: ", %session.SessionId
}

ClassMethod Test() As %Status
{
		set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
		set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
		set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
		
		// Set session
		set %session=##class(%CSP.Session).%New($J)
		set sessionid = %session.SessionId

		set token=##class(TC.api.Logon).Request(user,pwd,encryptpwd,)
		#; set token=##class(TC.api.Logon).Request("auadm","pass","false", sessionid)

		set ret=##class(%DynamicObject).%New()

		do ret.%Set("user", user)
		do ret.%Set("pwd", pwd)
		do ret.%Set("encryptpwd", encryptpwd)
		do ret.%Set("token", $get(token))
		do ret.%Set("session", %session.SessionId)
		
		write ret.%ToJSON()
		quit $$$OK
}

ClassMethod GetOrders() As %Status
{
	set tArr = {}
	set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
	set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
	set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
	set %session=##class(%CSP.Session).%New($J)
	s ^xyt=1
	#; set token=##class(TC.api.Logon).Request("auadm","pass",0,)
	set token=##class(TC.api.Logon).Request(user,pwd,encryptpwd,)
	s ^xyt=token
	// Need to change this to check the token!
	if $get(token)="" {Quit $$$OK}
	
	else {
		Try {
			Do ##class(%REST.Impl).%SetContentType("application/json")
			If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
			If $data(%request.Data("_count",2)) {
				Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"_count")) Quit
			}
			s ^xyt=1
			If $data(%request.Data("_count",1)) {
				Set pcount=%request.Data("_count",1)
				If ($number(pcount,"I")="") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTInvalid,"_count",pcount)) Quit
			}
			s ^xyt=2
			If $data(%request.Data("category",2)) {
				Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"category")) Quit
			}
			s ^xyt=3
			If $data(%request.Data("category",1)) {
				Set pcategory=%request.Data("category",1)
			}
			s ^xyt=4
			Set response=##class(Custom.CDUI.REST.impl).GetOrders(.pcount,.pcategory)
			s ^xyt=5
			;w response.%ToJSON()
			Do ##class(Custom.CDUI.REST.impl).%WriteResponse(response)
			s ^xyt=6
		} Catch (ex) {
			do ex.Log()
			Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("Custom.CDUI.REST.impl","ExposeServerExceptions"))
		}
	}
	Quit $$$OK
}

ClassMethod Patient()
{
	set tArr = {}
	set user=$get(%request.CgiEnvs("HTTP_TUSERNAME"))
	set pwd=$get(%request.CgiEnvs("HTTP_TPASSWORD"))
	set encryptpwd=$get(%request.CgiEnvs("HTTP_TENCRYPTPASSWORD"))
	set %session=##class(%CSP.Session).%New($J)
	
	#; set token=##class(TC.api.Logon).Request("auadm","pass",0,)
	#; 
	set token=##class(TC.api.Logon).Request("auadm","pass",0,%session.SessionId,)
	
	
	if $get(token)'="" {Quit $$$OK}
	else{
	
	Try {
		Do ##class(%REST.Impl).%SetContentType("application/json")
		If '##class(%REST.Impl).%CheckAccepts("application/json") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts)) Quit
		If $data(%request.Data("_count",2)) {
			Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"_count")) Quit
		}
		#; s ^xyt=1
		If $data(%request.Data("_count",1)) {
			Set pcount=%request.Data("_count",1)
			If ($number(pcount,"I")="") Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTInvalid,"_count",pcount)) Quit
		}
		#; s ^xyt=2
		If $data(%request.Data("category",2)) {
			Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"category")) Quit
		}
		#; s ^xyt=3
		If $data(%request.Data("category",1)) {
			Set pcategory=%request.Data("category",1)
		}
		#; s ^xyt=4
		Set response=##class(Custom.CDUI.REST.impl).GetOrders(.pcount,.pcategory)
		#; s ^xyt=response.%ToJSON()
		#; Do ##class(Custom.CDUI.REST.impl).%WriteResponse(response)
		w response.%ToJSON()
		#; s ^xyt=6
	} Catch (ex) {
		do ex.Log()
		#; Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("Custom.CDUI.REST.impl","ExposeServerExceptions"))
		set tArr."error" = "hello"
		w tArr.%ToJSON()
	}
	}
	Quit $$$OK
}

/// Dispatch individual API calls to separate endpoint classes/methods
XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
        <!-- <Route Url='/cdu/GetOrders' Method='GET' Call='ShowListOrderCategory' /> -->
		<Route Url='/cdu/GetOrders' Method='GET' Call='GetOrders' />
		<Route Url='/test3' Method='GET' Call='Test3' />
		<Route Url='/testing' Method='GET' Call='Testing' />
        <Route Url="/hello" Method="GET" Call="Hello" />
        <Route Url="/hi" Method="GET" Call="Hi" />
		<Route Url="/test" Method="GET" Call="Test" />
		<Route Url="/patient" Method="GET" Call="Patient" />
		<Route Url="/test1" Method="GET" Call="Test1" />
		<Route Url="/test2" Method="GET" Call="Test2" />
	</Routes>
}
}
*/
}
