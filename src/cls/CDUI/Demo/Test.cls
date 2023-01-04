Import (CDUI.Demo.Utils, CDUI.Demo.Common)

Include %syPrompt

Class CDUI.Demo.Test Extends Ens.Util.IOLogger
{

// Default page size for record retrieval.

Parameter DefaultPageSize = 500;

Parameter MaxNumOfRetry = 8;

ClassMethod GetLocation(StartsWith As %String = "", Active As %Boolean = "", LocationTypeID As %String = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
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
	if Active {
		set request.Active = "Y"
	}

	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	set ResultObjList = ##class(%ListOfObjects).%New()
	set currentDate = $piece($horolog,",",1)
	if $$$ISOK(sc)
	{	
		set json = {}.%FromJSON(response.StringValue)
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set location = ##class("CDUI.Demo.vo.Location").newInstance(value)
			do ResultObjList.Insert(location)
			#; if ((value.CTLOCDateActiveFrom <= currentDate) && ((value.CTLOCDateActiveTo = "") || (value.CTLOCDateActiveTo >= currentDate))){
			#; 	set location = ##class("CDUI.Demo.vo.Location").newInstance(value)
			#; 	do ResultList.Insert(location)
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

ClassMethod NewPatient(NumOfPatient As %Integer = 1, ByRef patientIdList)
{
	$$$LOGINFO("[NewPatient] Retrive the insurance list.")
	set sc = ..GetARCAuxilInsurType(1, ..#DefaultPageSize,,.insurTypeObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewPatient] Failed to get ARCAuxilInsurTypes.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	$$$LOGINFO("[NewPatient] Create new patients.")
	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:NumOfPatient 
	{	
		set trialCnt = 1
		set isDone = 0
		while ((..#MaxNumOfRetry >= trialCnt) && ('isDone)){
			try 
			{
				$$$LOGINFO("[NewPatient] Trial: "_trialCnt)
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
					set randInsurTypeIndex = ##class(PUtil).Random(insurTypeObjList.Count()) + 1
					set insurType = insurTypeObjList.GetAt(randInsurTypeIndex)
					set request.INSTDesc = insurType.AUXITInsTypeDR
					set request.AUXITDesc = insurType.AUXITDesc
				}

				//TODO add PAPMIMedicare
				#; write !!
				#; zwrite insurType

				#; write !!
				#; zwrite request
				$$$LOGINFO("[NewPatient] request: "_request.SerialisedGet())
				// trigger business service
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){
						set $list(patientIdList, * + 1) = json.ID
						//$$$LOGINFO("[NewPatient] Created ID "_json.ID)
						set isDone = 1
					} else {
						$$$LOGERROR("[NewPatient] Failed to create a patient. "_json.ERROR)
						// if it matches, remove the invalid insurance record from the list
						set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^(INSTDesc|AUXITDesc).*")
						if isMatch {
							do insurTypeObjList.RemoveAt(randInsurTypeIndex)
						}
					}
				} else {
					$$$LOGERROR("[NewPatient] Failed to create a patient. "_$System.Status.DisplayError(sc))
				}
			} 
			catch ex 
			{	
				$$$LOGERROR("[NewPatient] Failed to create a patient. "_ex.DisplayString())
			} 
			set trialCnt = trialCnt + 1
		}
	}
	set resultSize = $listlength(patientIdList)
	$$$LOGINFO("patientIdList: "_$LISTTOSTRING(patientIdList))
	$$$LOGINFO("[NewPatient] Success count: "_resultSize_", Failure count: "_(NumOfPatient - resultSize))
}

ClassMethod GetARCAuxilInsurType(Active As %Boolean = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
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
	if Active {
		set request.Active = "Y"
	}

	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	set ResultObjList = ##class(%ListOfObjects).%New()
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
				do ResultObjList.Insert(insurType)
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

ClassMethod NewEpisode(NumOfEpisode As %Integer = 1, ByRef episodeIdList)
{
	set failedCount = 0
	set locationTypeId = "E" // TODO make it constant / enum
	set admType = "I,E"
	set minAdmDate = "1/1/1990"

	$$$LOGINFO("[NewEpisode] Retrive the location list.")
	set sc = ..GetLocation(,1,locationTypeId,..#DefaultPageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewEpisode] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	//create patient, the number of episode is equal to the number of patient
	do ..NewPatient(NumOfEpisode, .patientIdList)
	// generate patient records and insert them to TrakCare via API.
	for cnt = 1:1:NumOfEpisode 
	{	
		set trialCnt = 1
		set isDone = 0
		while ((..#MaxNumOfRetry >= trialCnt) && ('isDone)){
			try 
			{
				$$$LOGINFO("[NewEpisode] Trial: "_trialCnt)
				//Set up episode request
				set request = ##class(CDUI.Demo.Request.NewEpisode).%New()
				set request.PatientID = $list(patientIdList,cnt)
				set request.PAADMType = $piece(admType, ",",$$$PRand(2)+1)
				set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1))
				set request.PAADMAdmTime = ##class(PUtil).Time(2)
				if (locationObjList.Count() > 0){
					set randLocationIndex = ##class(PUtil).Random(locationObjList.Count()) + 1
					set location = locationObjList.GetAt(randLocationIndex)
					set request.CTLOCDesc = location.CTLOCDesc
				}

				#; write !!
				#; zw location

				#; write !!
				#; zwrite request
				$$$LOGINFO("[NewEpisode] Request: "_request.SerialisedGet())
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.Demo.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{	
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){ //No error message
						set $list(episodeIdList, * + 1) = json.ID
						#; zwrite response
						//$$$LOGINFO("[NewEpisode] Created ID "_json.ID)
						set isDone = 1
					} else 
					{
						$$$LOGERROR("[NewEpisode] Failed to create an episode. "_json.ERROR)
						// if it matches, remove the invalid insurance record from the list
						set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^CTLOCDesc.*")
						if isMatch {
							do locationObjList.RemoveAt(randLocationIndex)
						}
					}
				} else {
						$$$LOGERROR("[NewEpisode] Failed to create an episode. "_$System.Status.DisplayError(sc))
				}
			} catch ex 
			{	
					$$$LOGERROR("[NewEpisode] Failed to create an episode. "_ex.DisplayString())
			} 
			set trialCnt = trialCnt + 1
		}
	}
	set resultSize = $listlength(episodeIdList)
	$$$LOGINFO("episodeIdList: "_$LISTTOSTRING(episodeIdList))
	$$$LOGINFO("[NewEpisode] Success count: "_resultSize_", Failure count: "_(NumOfEpisode - resultSize))
	quit
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

// ClassMethod ListARCAuxilInsurTypes(PageSize As %Integer = 100, ByRef Page As %Integer = "")

// {

// 	set sc = ..GetARCAuxilInsurType(, PageSize,Page,.results)

// 	set i = ""

// 	set size = results.Count()

// 		for cnt=1:1:size{

// 			zw results.GetAt(cnt)

// 		}

// }

// 

}
