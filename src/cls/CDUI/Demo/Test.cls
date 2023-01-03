Import (CDUI.Demo.Utils, CDUI.Demo.Common)

Include %syPrompt

Class CDUI.Demo.Test Extends Ens.Util.IOLogger
{

// Default page size for record retrieval.

Parameter DefaultPageSize = 200;

Property ARCAuxilInsurTypeObjList As %ListOfObjects [ Private ];

ClassMethod GetLocation(StartsWith As %String = "", LocationTypeID As %String = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultList) As %Status
{
	set request = ##class(CDUI.Demo.Request.Location).%New()
	
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
	#; ,request.HospitalDesc = Desc
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	set ResultList = ##class(%ListOfObjects).%New()
	set currentDate = $piece($horolog,",",1)
	if $$$ISOK(sc)
	{	
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			if ((value.CTLOCDateActiveFrom <= currentDate) && ((value.CTLOCDateActiveTo = "") || (value.CTLOCDateActiveTo >= currentDate))){
				#; set Results($increment(Results)) = $listbuild(value.CTLOCCode,value.CTLOCDesc)
				set location = ##class("CDUI.Demo.vo.Location").newInstance(value)
				do ResultList.Insert(location)
			}
		}
	}
	quit sc
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

// Return patient ID list

ClassMethod NewPatient(NumOfPatient As %Integer = 1) As %List
{
	set failedCount = 0
	set patientIdList = $listbuild()

	//TODO init ARCAuxilInsurTypeObjList when it is null
	set sc = ..GetARCAuxilInsurType(..#DefaultPageSize,,.insurTypeObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("Failed to get ARCAuxilInsurTypes.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:NumOfPatient 
	{	
		try 
		{
			// Set up patient creation request
			set request = ##class(CDUI.Demo.Request.NewPatient).%New()
			set request.PAPERName = ##class(PUtil).FullName()
			set request.PAPERName2 = ##class(PUtil).FullName()
			set request.CTSEXDesc = ##class(PUtil).ListElement($listfromstring(##class(Constants).#genders,","))
			// min date = current date - maxAge, max date is current date
			set currentDateInt = $piece($horolog, ",", 1)
			set minDateInt = currentDateInt - (##class(Constants).#maxAge * 365)
			set request.PAPERDob = ##class(PUtil).CustomDate(minDateInt, currentDateInt) 
			
			//TODO save the isurTypeObjList to global for resue
			if (insurTypeObjList.Count() > 0){
				set insurType = insurTypeObjList.GetAt(##class(PUtil).Random(insurTypeObjList.Count()) + 1)
				set request.INSTDesc = insurType.AUXITInsTypeDR
			}

			//TODO add PAPMIMedicare

			write !!
			zwrite insurType

			write !!
			zwrite request

			// trigger business service
			set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
			set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
			if $$$ISOK(sc)
			{
				set json = {}.%FromJSON(response.StringValue)
				if (json.ERROR '= ""){
					Throw ##class(%Exception.General).%New("Error: " _json.ERROR) //TODO to see which exception should be used.
				}
				set $list(patientIdList, * + 1) = json.ID
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
	$$$LOGINFO("[NewPatient] Success count: "_(NumOfPatient-failedCount)_", Failure count: "_failedCount)
	return patientIdList
}

ClassMethod GetARCAuxilInsurType(PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultList) As %Status
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
	set ResultList = ##class(%ListOfObjects).%New()
	set currentDate = $piece($horolog,",",1)

	if $$$ISOK(sc)
	{
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			if ((value.AUXITDateFrom <= currentDate) && ((value.AUXITDateTo = "") || (value.AUXITDateTo >= currentDate))){
				set insurType = ##class("CDUI.Demo.vo.ARCAuxilInsurType").newInstance(value)
				#; set Results($increment(Results)) = $listbuild(value)
				do ResultList.Insert(insurType)
			}
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

ClassMethod NewEpisode(NumOfEpisode As %Integer = 1) As %List
{
	set failedCount = 0
	set locationTypeId = "E" // TODO make it constant / enum
	set admType = "I,E"
	set minAdmDate = "1/1/1990"
	set episodeIdList = $listbuild()
	//TODO init ARCAuxilInsurTypeObjList when it is null
	set sc = ..GetLocation(,locationTypeId,..#DefaultPageSize,,.locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:NumOfEpisode 
	{	
		try 
		{
			//create patient
			set patientIdList = ..NewPatient()
			if ($listlength(patientIdList) '= 2){
				Throw ##class(%Exception.General).%New("Failed to get patient Id.") //TODO to see which exception should be used.
			}

			//Set up episode request
			set request = ##class(CDUI.Demo.Request.NewEpisode).%New()
			set request.PatientID = $list(patientIdList,2)
			set request.PAADMType = $piece(admType, ",",$$$PRand(2)+1)
			set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1))
			set request.PAADMAdmTime = ##class(PUtil).Time(2)


			if (locationObjList.Count() > 0){
				set location = locationObjList.GetAt(##class(PUtil).Random(locationObjList.Count()) + 1)
				set request.CTLOCDesc = location.CTLOCDesc
			}

			write !!
			zw location

			write !!
			zwrite request

			set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
			set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
			if $$$ISOK(sc)
			{	
				set json = {}.%FromJSON(response.StringValue)
				if (json.ERROR '= ""){
					Throw ##class(%Exception.General).%New("Error: " _json.ERROR) //TODO to see which exception should be used.
				}
				set $list(episodeIdList, * + 1) = json.ID
				zwrite response
				write !,"Created ID "_json.ID
			} else {
				 Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
			}
		} 
		catch ex 
		{	
			$$$LOGERROR("Failed to create an Episode. "_ex.DisplayString())
			set failedCount = failedCount + 1
		} 
	}
	$$$LOGINFO("[NewEpisode] Success count: "_(NumOfEpisode-failedCount)_", Failure count: "_failedCount)
	return episodeIdList
}

// ClassMethod ListLocations()

// {

// 	set promptResult = ##class(%Prompt).GetString("Search for location starting with : ",.value)

// 	set sc = ..List(value,,24,.page,.results)

// 	set i = ""

// 	for

// 	{

// 		set i = $order(results(i),1,location)

// 		quit:i=""

// 		set code = $listget(location),codelen = $length(code)

// 		write !,$listget(location,1)_$justify("",(15-codelen))_" : "_$listget(location,2)

// 	}

// }

}
