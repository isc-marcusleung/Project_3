Import (CDUI.Demo.Utils, CDUI.Demo.Common)

Include %syPrompt

Class CDUI.Demo.Test Extends Ens.Util.IOLogger
{

Property arcAuxilInsurTypeList As %List;

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

ClassMethod NewPatient(numOfPatient As %Integer = 1)
{
	set failedCount = 0
	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:numOfPatient {	
		// Set up patient creation request
		set request = ##class(CDUI.Demo.Request.NewPatient).%New()
		set request.PAPERName = ##class(PUtils).FullName()
		set request.PAPERName2 = ##class(PUtils).FullName()
		set request.CTSEXDesc = ##class(PUtils).ListElement($listfromstring(##class(Constants).#genders,","))
		// min date = current date - maxAge, max date is current date
		set currentDateInt = $piece($horolog, ",", 1)
		set minDateInt = currentDateInt - (##class(Constants).#maxAge * 365)
		set request.PAPERDob = ##class(PUtils).CustomDate(minDateInt, currentDateInt) 
		
		//TODO INSTDesc

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
				 Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
			}
		} 
		catch ex 
		{	
			$$$LOGERROR("Failed to create a patient. "_ex.DisplayString())
			set failedCount = failedCount + 1
		} 
	}
	$$$LOGINFO("Success count: "_(numOfPatient-failedCount)_", Failure count: "_failedCount)
}

ClassMethod GetARCAuxilInsurType(PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef resultList) As %Status
{
	set request = ##class(CDUI.Demo.Request.ARCAuxilInsurType).%New()

	if Page'=""
	{
		set request.page = Page
	}
	if PageSize'=""
	{
		set request.count = PageSize
	}
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	set resultList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		set idx = 1
		while iterator.%GetNext(.key,.value)
		{	
			set insurType = ##class("CDUI.Demo.vo.ARCAuxilInsurType").newInstance(value)
			#; set Results($increment(Results)) = $listbuild(value)
			do resultList.Insert(insurType)
			
		}
	
	}
	quit sc
}

ClassMethod ListARCAuxilInsurTypes(PageSize As %Integer = 100, ByRef Page As %Integer = "")
{
	set sc = ..GetARCAuxilInsurType(PageSize,Page,.results)
	set i = ""
	set size = results.Count()
		for cnt=1:1:size{
			zw results.GetAt(cnt)
		}
}

}
