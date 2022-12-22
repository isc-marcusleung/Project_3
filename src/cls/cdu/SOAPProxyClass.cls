Class cdu.SOAPProxyClass
{

Parameter DEFAULTURL = "http://auxxdev2022.iscinternal.com/csp/healthshare/auxx-config-hmfsys/services/TC.hmf.System.Service.Inbound.SYSAPI.cls?wsdl=1";

ClassMethod GenerateProxyClasses(
	Url As %String = "",
	Package As %String = "CDUI.ws") As %Status
{
	set Url = $select(Url'="":Url,1:..#DEFAULTURL)
	set request = ##class(%Net.HttpRequest).%New()
	set request.Username = "irisowner",
		request.Password = "SYS"
	set wsdl = ##class(%SOAP.WSDL.Reader).%New()
	set wsdl.HttpRequest = request
		,wsdl.MakeService = 1
		,wsdl.MakeEnsembleClasses = 1
		,wsdl.OperationPackage = Package_".Operation"
		,wsdl.ServicePackage = Package_".Service"
		,wsdl.RequestPackage = Package_".Request"
		,wsdl.ResponsePackage = Package_".Response"
	set sc = wsdl.Process(Url,Package)
	break
	#; set wsdl.%SOAP.WS
	quit sc
}

ClassMethod TestLocList(Location As %String = "")
{
	set ws = ##class(CDUI.ws.TChmfServiceTrakInboundSYSAPISoap).%New()
	#; set ws.Username = "irisowner",ws.Password = "SYS"
	set ws.Location = "http://auxxmiscprj.iscinternal.com:52773/csp/healthshare/auxxmisc-test-hmfsys/services/TC.hmf.System.Service.Inbound.SYSAPI.cls"
	set params = ##class(CDUI.ws.TC.api.CTLoc.FindList.Params).%New()
	set params.Active = "Y"
	set res = ws.CTLocFindListExecuteQuery("",params,"auadm","pass",0,"","")
	break
	quit:$quit ""
}

ClassMethod OpenEditUser(
	ID As %Integer = 2,
	SSUSRName As %String = "")
{
	set ws = ##class(CDUI.ws.TChmfServiceTrakInboundSYSAPISoap).%New()
	#; set ws.Username = "irisowner",ws.Password = "SYS"
	set ws.Location = "http://auxxmiscprj.iscinternal.com:52773/csp/healthshare/auxxmisc-test-hmfsys/services/TC.hmf.System.Service.Inbound.SYSAPI.cls"
	set ssuser = ws.SSUserEditOpen("",ID,"auadm","pass",0,"","")
	write !,"SSUSRInitials 	: "_ssuser.SSUSRInitials
	write !,"SSUSRName		: "_ssuser.SSUSRName
	#; set ssuser.SSUSRName3 = NewSSUSRName3
	set ssuser.SSUSRName = SSUSRName
	set res = ws.SSUserEditSave("",ssuser,"auadm","pass",0,"","")
	quit:$quit ""
}

ClassMethod Send(
	Code As %String = "",
	Desc As %String = "") As %Status
{
	set request = ##class(CDUI.Request.Hospital).%New()
	set request.HospitalCode = Code,
		request.HospitalDesc = Desc
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	break
	quit sc
}

}
