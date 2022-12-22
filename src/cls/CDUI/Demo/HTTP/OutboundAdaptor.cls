Class CDUI.Demo.HTTP.OutboundAdaptor Extends EnsLib.HTTP.OutboundAdapter
{

Property HttpHeaders As %String [ MultiDimensional ];

Method GetURL(pURL As %String, Output pHttpResponse As %Net.HttpResponse, pFormVarNames As %String, pData...) As %Status
{
	set HttpRequest = ##class(%Net.HttpRequest).%New()
	for HEADER="TUSERNAME","TPASSWORD","TENCRYPTED"
	{
		kill HEADERVAL
		if $data(i%HttpHeaders(HEADER),HEADERVAL)
		{
			do HttpRequest.SetHeader(HEADER,HEADERVAL)	
		}
	}
	quit ..SendFormDataArray(.pHttpResponse,"GET",HttpRequest,.pFormVarNames,.pData,pURL)
}

Method PutURL(pURL As %String, Output pHttpResponse As %Net.HttpResponse, pFormVarNames As %String, pData...) As %Status
{
	set HttpRequest = ##class(%Net.HttpRequest).%New()
	for HEADER="TUSERNAME","TPASSWORD","TENCRYPTED"
	{
		kill HEADERVAL
		if $data(i%HttpHeaders(HEADER),HEADERVAL)
		{
			do HttpRequest.SetHeader(HEADER,HEADERVAL)	
		}
	}
	quit ..SendFormDataArray(.pHttpResponse,"PUT",HttpRequest,.pFormVarNames,.pData,pURL)
}

}
