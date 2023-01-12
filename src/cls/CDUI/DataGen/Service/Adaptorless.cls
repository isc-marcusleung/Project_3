Class CDUI.DataGen.Service.Adaptorless Extends Ens.BusinessService
{

/// Override this method to process incoming data. Do not call SendRequestSync/Async() from outside this method (e.g. in a SOAP Service or a CSP page).
Method OnProcessInput(pInput As CDUI.DataGen.Request.Location, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
	set sc = ..SendRequestSync("CDUI.DataGen.Process.MsgRouter.REST",.pInput,.pOutput)
	quit sc
}

}
