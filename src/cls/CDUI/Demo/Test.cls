Include %syPrompt

Class CDUI.Demo.Test Extends Ens.Util.IOLogger
{

ClassMethod List(StartsWith As %String = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef Results) As %Status
{
	set request = ##class(CDUI.Demo.Request.Location).%New()
	set request.Description = StartsWith
	if Page'=""
	{
		set request.page = Page
	}
	if PageSize'=""
	{
		set request.count = PageSize
	}
	#; ,request.HospitalDesc = Desc
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	if $$$ISOK(sc)
	{
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set Results($increment(Results)) = $listbuild(value.CTLOCCode,value.CTLOCDesc)
		}
	}
	quit sc
}

ClassMethod ListLocations()
{
	set promptResult = ##class(%Prompt).GetString("Search for location starting with : ",.value)
	set sc = ..List(value,24,.page,.results)
	set i = ""
	for
	{
		set i = $order(results(i),1,location)
		quit:i=""
		set code = $listget(location),codelen = $length(code)
		write !,$listget(location,1)_$justify("",(15-codelen))_" : "_$listget(location,2)
	}
}

ClassMethod NewLocation()
{
	set CTLOCCode = "Z"_##class(%PopulateUtils).String(5)
	set CTLOCDesc = $zconvert($translate(##class(%PopulateUtils).Syllable(10)," "),"S")
	set request = ##class(CDUI.Demo.Request.NewLocation).%New()
	set request.CTLOCCode = CTLOCCode,request.CTLOCDesc = CTLOCDesc
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	if $$$ISOK(sc)
	{
		set json = {}.%FromJSON(response.StringValue)
		write !,"Created CT_Loc RowID "_json.ID
	}
	quit sc
}

ClassMethod NewPatient()
{
	set promptResult = ##class(%Prompt).GetString("Input the number of patient to be generated : ",.numOfPatient)

	set failedCount = 0
	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:numOfPatient {	
	
		// Set up patient creation request
		set request = ##class(CDUI.Demo.Request.NewPatient).%New()
		set request.PAPERName = ##class(CDUI.Demo.Utils.PUtils).FullName()
		set request.PAPERName2 = ##class(CDUI.Demo.Utils.PUtils).FullName()
		set request.CTSEXDesc =  ##class(CDUI.Demo.Utils.PUtils).Gender()
		set request.PAPERDob = ##class(CDUI.Demo.Utils.PUtils).CustomDate()

		write !!
		zwrite request

		try 
		{
			set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
			set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
			if $$$ISOK(sc)
			{
				set json = {}.%FromJSON(response.StringValue)
				zwrite response
				write !,"Created ID "_json.ID
			} else {
				$$$ThrowOnError(sc)
			}
		} 
		catch ex 
		{
			do LOG^%ETN
			set failedCount = failedCount + 1
		} 
	}
	$$$LOGINFO("Success count: "_(numOfPatient-failedCount)_", Failure count: "_failedCount)
}

}
