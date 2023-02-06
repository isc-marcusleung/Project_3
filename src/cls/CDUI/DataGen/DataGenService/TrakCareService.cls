Class CDUI.DataGen.DataGenService.TrakCareService Extends Ens.Util.IOLogger
{

Parameter DispatchName = "CDUI.DataGen.Service.Adaptorless";

ClassMethod GetARCAuxilInsurType(Active As %Boolean = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
{
	set request = ##class(CDUI.DataGen.Request.ARCAuxilInsurType).%New()
	//Set up the request
	if Page'=""
	{
		set request.page = Page
	}
	if PageSize'=""
	{
		set request.count = PageSize
	}
	if Active = 1 {
		set request.Active = "Y"
	} elseif Active = 0 {
		set request.Active = "N"
	}

	$$$LOGINFO("[TrakCareService.GetARCAuxilInsurType] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved ARCAuxilInsurType records to a object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{
		//$$$LOGINFO("[GetARCAuxilInsurType] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set insurType = ##class("CDUI.DataGen.vo.ARCAuxilInsurTypeVo").newInstance(value)
			do ResultObjList.Insert(insurType)
		}
	}
	quit sc
}

ClassMethod GetARCItmMast(Active As %Boolean = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
{
	$$$LOGINFO("[TrakCareService.GetARCItmMast] Start retrieving ARCItmMast...")
	set request = ##class(CDUI.DataGen.Request.ARCItmMast).%New()
	//Set up request
	if Page'=""
	{
		set request.page = Page
	}
	if PageSize'=""
	{
		set request.count = PageSize
	}
	if Active = 1 {
		set request.Active = "Y"
	} elseif Active = 0 {
		set request.Active = "N"
	}

	$$$LOGINFO("[TrakCareService.GetARCItmMast] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved ARCItmMast records to a object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{
		//$$$LOGINFO("[GetARCItmMast] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set insurType = ##class("CDUI.DataGen.vo.ARCItmMasVo").newInstance(value)
			do ResultObjList.Insert(insurType)
		}
	}
	quit sc
}

ClassMethod GetLocation(StartsWith As %String = "", Active As %Boolean = "", LocationTypeID As %String = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
{
	$$$LOGINFO("[TrakCareService.GetLocation] Start retrieving Location...")
	set request = ##class(CDUI.DataGen.Request.Location).%New()
	//Set up a request
	if StartsWith '= "" {
		set request.Description = StartsWith
	}
	if LocationTypeID '= "" {
		set request.LocationTypeID = LocationTypeID
	}
	if Page'=""
	{
		set request.page = Page
	}
	if PageSize'=""
	{
		set request.count = PageSize
	}
	if Active = 1 {
		set request.Active = "Y"
	} elseif Active = 0 {
		set request.Active = "N"
	}

	$$$LOGINFO("[TrakCareService.GetLocation] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved Location records to a object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{	
		//$$$LOGINFO("[GetLocation] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set location = ##class("CDUI.DataGen.vo.LocationVo").newInstance(value)
			do ResultObjList.Insert(location)
		}
	}
	quit sc
}

ClassMethod GetLocationServices(loc As %Integer = "", ByRef ResultObjList) As %Status
{
	$$$LOGINFO("[TrakCareService.LocationServices] Start retrieving Location Services...")
	set request = ##class(CDUI.DataGen.Request.LocationServices).%New()
	//Set up a request

	if loc'=""
	{
		set request.loc = loc
	}

	$$$LOGINFO("[TrakCareService.LocationServices] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved Location services records to an object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{	
		// $$$LOGINFO("[GetLocationServices] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set locServices = ##class("CDUI.DataGen.vo.LocationServicesVo").newInstance(value)
			do ResultObjList.Insert(locServices)
			#; write !, value.Order,?30,value.RowID
		}
	}
	quit sc
}

ClassMethod GetSlots(LocId As %Integer = "", ServId As %Integer = "", PageSize As %Integer = 50, ByRef ResultObjList) As %Status
{
	$$$LOGINFO("[TrakCareService.Slots] Start retrieving Slots...")
	set request = ##class(CDUI.DataGen.Request.Slots).%New()
	//Set up a request

	if PageSize'=""
	{
		set request.count = PageSize
	}
	if LocId '= "" {
		set request.LocId = LocId
	}
	if ServId '= "" {
		set request.ServId = ServId
	}

	$$$LOGINFO("[TrakCareService.Slots] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved Location services records to an object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{	
		// $$$LOGINFO("[GetSlots] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			// If the slot has a USRN number, that slot is available and hasn't been used
			if (value.USRN '= "")
			{
				set slot = ##class("CDUI.DataGen.vo.SlotVo").newInstance(value)
				do ResultObjList.Insert(slot)
				#; write !, value.Date,?30,value.USRN
			}
			
		}
	}
	quit sc
}

}
