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
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				set insurType = ##class("CDUI.DataGen.vo.ARCAuxilInsurTypeVo").newInstance(value)
				do ResultObjList.Insert(insurType)
			}
		} else {
			$$$LOGERROR("[TrakCareService.GetARCAuxilInsurType] Failed to get ARCAuxilInsurType. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
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
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				set insurType = ##class("CDUI.DataGen.vo.ARCItmMasVo").newInstance(value)
				do ResultObjList.Insert(insurType)
			}
		} else {
			$$$LOGERROR("[TrakCareService.GetARCItmMast] Failed to get ARCItmMast. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
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
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				set location = ##class("CDUI.DataGen.vo.LocationVo").newInstance(value)
				do ResultObjList.Insert(location)
			}
		} else {
			$$$LOGERROR("[TrakCareService.GetLocation] Failed to get Location. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)		}
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
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				set locServices = ##class("CDUI.DataGen.vo.LocationServicesVo").newInstance(value, request.loc)
				do ResultObjList.Insert(locServices)
				#; write !, value.Order,?30,value.RowID
			}
		} else {
			$$$LOGERROR("[TrakCareService.LocationServices] Failed to get LocationServices. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}
	quit sc
}

ClassMethod GetSlots(LocId As %Integer = "", ServId As %Integer = "", PageSize As %Integer = 200, Rows As %Integer = "", ByRef ResultObjList) As %Status
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
	if Rows '= "" {
		set request.Rows = Rows
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
		if (json.ERROR = ""){
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
		} else {
			$$$LOGERROR("[TrakCareService.LocationServices] Failed to get LocationServices. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}
	quit sc
}

ClassMethod GetOrderByCat(Count As %Integer = "", Category As %String = "", ByRef ResultObjList) As %Status
{
	set request = ##class(CDUI.DataGen.Request.GetOrderByCategory).%New()

	//Set up the request
	if Count'=""
	{
		set request.count = Count
	}
	if Category'=""
	{
		set request.category = Category
	}

	$$$LOGINFO("[GetOrderByCat] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	//Store the retrieved order categories, order items records to an object list
	set ResultObjList = ##class(%ListOfObjects).%New()
	if $$$ISOK(sc)
	{
		//$$$LOGINFO("[Get...] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				set insurType = ##class(CDUI.DataGen.vo.OrderCatVo).newInstance((value))
				do ResultObjList.Insert(insurType)
				#; write !, value.ORCATDesc,?30,value.ID
			}
		} else {
			$$$LOGERROR("[TrakCareService.GetOrderByCat] Failed to get OrderByCat. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}

	quit sc
}

ClassMethod GetCareProvider(ByRef Results) As %Status
{
	set request = ##class(CDUI.DataGen.Request.GetCareProvider).%New()

	// $$$LOGINFO("[GetCareProvider] Request body: "_request.SerialisedGet())

	// Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	// Store the DoctorID in a ListOfDataTypes
	set Results = ##class(%ListOfDataTypes).%New()

	if $$$ISOK(sc)
	{
		#; $$$LOGINFO("[GetCareProvider] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		if (json.ERROR = ""){
			set iterator = json.results.%GetIterator()
			while iterator.%GetNext(.key,.value)
			{	
				do Results.Insert(value.DoctorID)
				#; write !, value.DoctorID
			}
		} else {
			$$$LOGERROR("[TrakCareService.GetCareProvider] Failed to get CareProvider. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}

	quit sc
}

ClassMethod GetPatientById(id As %Integer = "", ByRef patRecordList) As %Status
{
	set request = ##class(CDUI.DataGen.Request.GetPatientById).%New()

	if id'=""
	{
		set request.id = id
	}
	// Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	if $$$ISOK(sc)
	{		
		#; $$$LOGINFO("[GetPatientById] Response body: "_response.StringValue)
		set json = {}.%FromJSON(response.StringValue)
		if (json.ERROR = ""){
			#; write !, "First name: "_json.PAPERName

			// Change Last Name to Capitalisation instead of Uppercase
			set lastName = json.PAPERName
			set lastName = $EXTRACT(json.PAPERName)_$ZCONVERT($EXTRACT(json.PAPERName,2,*),"L")

			set patRecordList = $listbuild(
				$listbuild("PAPERName",lastName),
				$listbuild("PAPERName2",json.PAPERName2),
				$listbuild("CTSEXDesc",json.CTSEXDesc),
				$listbuild("PAPERDob",json.PAPERDob)
			)
		} else {
			$$$LOGERROR("[TrakCareService.GetPatientById] Failed to get PatientById. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}
	quit sc
}

ClassMethod GetEpisodeById(id As %Integer = "", ByRef epRecordList) As %Status
{
	set request = ##class(CDUI.DataGen.Request.GetEpisodeById).%New()

	if id'=""
	{
		set request.id = id
	}
	// Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

	if $$$ISOK(sc)
	{		
		set json = {}.%FromJSON(response.StringValue)
		if (json.ERROR = ""){
			set epRecordList = $listbuild(
				$listbuild("ID",json.ID),
				$listbuild("PatientID",json.PatientID),
				$listbuild("PAADMType",json.PAADMType),
				$listbuild("PAADMAdmDate",json.PAADMAdmDate),
				$listbuild("PAADMAdmTime",json.PAADMAdmTime),
				$listbuild("CTLOCDesc",json.CTLOCDesc)
			)
		} else {
			$$$LOGERROR("[TrakCareService.GetEpisodeById] Failed to get EpisodeById. Error(JSON): "_json.ERROR)
			Throw ##class(%Exception.General).%New("Exception",,"CDUI.DataGen.DataGenService.TrakCareService",json.ERROR)
		}
	}
	quit sc
}

}
