Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Include %syPrompt

Class CDUI.DataGen.Test Extends Ens.Util.IOLogger
{

///  Default page size for record retrieval.
Parameter DefaultPageSize = 500;

/// Default Max number of retry in the process
Parameter MaxNumOfRetry = 8;

ClassMethod GetARCItmMast(Active As %Boolean = "", PageSize As %Integer = "", ByRef Page As %Integer = "", ByRef ResultObjList) As %Status
{
	$$$LOGINFO("[GetARCItmMast] Start retrieving ARCItmMast...")
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

	$$$LOGINFO("[GetARCItmMast] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
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
	$$$LOGINFO("[GetLocation] Start retrieving Location...")
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

	$$$LOGINFO("[GetLocation] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
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

	$$$LOGINFO("[GetARCAuxilInsurType] Request body: "_request.SerialisedGet())

	//Send the request
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
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

ClassMethod NewLocation()
{
	set CTLOCCode = "Z"_##class(%PopulateUtils).String(5)
	set CTLOCDesc = $zconvert($translate(##class(%PopulateUtils).Syllable(10)," "),"S")
	set request = ##class(CDUI.DataGen.Request.NewLocation).%New()
	set request.CTLOCCode = CTLOCCode,request.CTLOCDesc = CTLOCDesc
	set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
	set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
	if $$$ISOK(sc)
	{
		set json = {}.%FromJSON(response.StringValue)
		write !,"Created CT_Loc RowID "_json.ID
	}
	quit sc
}

ClassMethod NewPatient(NumOfPatient As %Integer = 1, ByRef patientIdList)
{
	//Retrieve the ARCAuxilInsurType list for the creation of patient
	$$$LOGINFO("[NewPatient] Retrive the insurance list.")
	set sc = ..GetARCAuxilInsurType(1, ..#DefaultPageSize,,.insurTypeObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewPatient] Failed to get ARCAuxilInsurTypes.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}
	// generate patient records and insert them to TrakCare via API.
	$$$LOGINFO("[NewPatient] Create new patients.")
	set trialCnt = 1
	set numOfLoop = NumOfPatient
	while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0)){
		$$$LOGINFO("[NewPatient] Trial: "_trialCnt_", Number of patient to be created: "_numOfLoop)
		set numOfFailed = 0
		for cnt = 1:1:numOfLoop 
		{	
			try 
			{
				// Set up patient creation request
				set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
				// Set last name
				set request.PAPERName = ##class(PUtil).LastName()

				// set first name
				set request.PAPERName2 = ##class(PUtil).FirstName()
				set request.CTSEXDesc = ##class(PUtil).ListElement($listfromstring(##class(Constants).#genders,","))
				// min date = current date - maxAge, max date is current date
				set currentDateInt = $piece($horolog, ",", 1)
				set minDateInt = currentDateInt - (##class(Constants).#maxAge * 365)
				set request.PAPERDob = ##class(PUtil).CustomDate(minDateInt, currentDateInt) 

				// Randomly select the insurance record from insurTypeObjList 		
				if (insurTypeObjList.Count() > 0){
					set randInsurTypeIndex = ##class(PUtil).Random(insurTypeObjList.Count()) + 1
					set insurType = insurTypeObjList.GetAt(randInsurTypeIndex)
					set request.INSTDesc = insurType.AUXITInsTypeDR
					set request.AUXITDesc = insurType.AUXITDesc
				}
				//TODO Marcus add PAPMIMedicare

				$$$LOGINFO("[NewPatient] Request body: "_request.SerialisedGet())
				
				//Send the request
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{
					$$$LOGINFO("[NewPatient] Response body: "_response.StringValue)
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){
						//No error then store the patient Id
						set $list(patientIdList, * + 1) = json.ID
					} else {
						$$$LOGERROR("[NewPatient] Failed to create a patient. Error(JSON): "_json.ERROR)
						// if it matches, remove the invalid insurance record from the list
						set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^(INSTDesc|AUXITDesc).*")
						if isMatch {
							do insurTypeObjList.RemoveAt(randInsurTypeIndex)
						}
						set numOfFailed = numOfFailed + 1
					}
				} else {
					$$$LOGERROR("[NewPatient] Failed to create a patient. Error(SC): "_$System.Status.DisplayError(sc))
					set numOfFailed = numOfFailed + 1
				}
			} 
			catch ex 
			{	
				$$$LOGERROR("[NewPatient] Failed to create a patient. Error(Ex): "_ex.DisplayString())
				set numOfFailed = numOfFailed + 1
			} 
		}
		$$$LOGINFO("[NewPatient] Number of failure: "_numOfFailed)
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
	}
	
	set resultSize = $listlength(patientIdList)
	$$$LOGINFO("patientIdList: "_$LISTTOSTRING(patientIdList))
	$$$LOGINFO("[NewPatient] Success count: "_resultSize_", Failure count: "_(NumOfPatient - resultSize))
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

ClassMethod NewEpisode(NumOfEpisode As %Integer = 1, ByRef episodeVoObjList) As %Status
{
	set failedCount = 0
	set locationTypeId = "E" // TODO Marcus make it constant / enum
	set admType = "I,E"
	set minAdmDate = "1/1/1990"
	set episodeVoObjList = ##class(%ListOfObjects).%New()

	//Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[NewEpisode] Retrive the location list.")
	set sc = ..GetLocation(,1,locationTypeId,..#DefaultPageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewEpisode] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	//create patient, the number of episode is equal to the number of patient
	do ..NewPatient(NumOfEpisode, .patientIdList)
	
	set trialCnt = 1
	set numOfLoop = NumOfEpisode
	while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0))
	{
		$$$LOGINFO("[NewEpisode] Trial: "_trialCnt_", Number of episode to be created: "_numOfLoop)
		set numOfFailed = 0
		
		for cnt = 1:1:numOfLoop 
		{	
			try 
			{
				//Set up episode request
				set request = ##class(CDUI.DataGen.Request.NewEpisode).%New()
				set randPatientIdListIndex = $$$PRand($listlength(patientIdList))+1
				set request.PatientID = $list(patientIdList,randPatientIdListIndex)
				set request.PAADMType = $piece(admType, ",",$$$PRand(2)+1)
				set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1))
				set request.PAADMAdmTime = ##class(PUtil).Time(,,2)
				if (locationObjList.Count() > 0){
					set randLocationIndex = ##class(PUtil).Random(locationObjList.Count()) + 1
					set location = locationObjList.GetAt(randLocationIndex)
					set request.CTLOCDesc = location.CTLOCDesc
				}

				$$$LOGINFO("[NewEpisode] Request: "_request.SerialisedGet())

				//Send the request
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

				if $$$ISOK(sc)
				{	
					$$$LOGINFO("[NewEpisode] Response body: "_response.StringValue)
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){ 
						//No error then store the record to episodeVoObjList
						do episodeVoObjList.Insert(##class(CDUI.DataGen.vo.EpisodeVo).newInstance(request,json.ID)) 
						//For the printout purpose in the bottom
						set $list(episodeIdList, * + 1) = json.ID
						//remove the used patient id from the patientIdList if it is used for the creation of episode successfully
						set patientIdList = $List(patientIdList,1,randPatientIdListIndex-1)_$list(patientIdList,randPatientIdListIndex+1,$LISTLENGTH(patientIdList))
					} else 
					{
						$$$LOGERROR("[NewEpisode] Failed to create an episode. Error(Json): "_json.ERROR)
						// if it matches, remove the invalid insurance record from the list.
						set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^CTLOCDesc.*")
						if isMatch {
							do locationObjList.RemoveAt(randLocationIndex)
						}
						set numOfFailed = numOfFailed + 1
					}
				} else {
						$$$LOGERROR("[NewEpisode] Failed to create an episode. Error(SC): "_$System.Status.DisplayError(sc))
						set numOfFailed = numOfFailed + 1
				}
			} catch ex 
			{	
					$$$LOGERROR("[NewEpisode] Failed to create an episode. Error(Ex): "_ex.DisplayString())
					set numOfFailed = numOfFailed + 1
			} 
		}
		$$$LOGINFO("[NewEpisode] Number of failure: "_numOfFailed)
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
	}
		
	set resultSize = $listlength(episodeIdList)
	$$$LOGINFO("episodeIdList: "_$LISTTOSTRING(episodeIdList))
	$$$LOGINFO("[NewEpisode] Success count: "_resultSize_", Failure count: "_(NumOfEpisode - resultSize))
	return sc
}

ClassMethod NewOrder(NumOfOrder As %Integer = 1, ByRef orderIdList)
{
	set failedCount = 0
	
	//Retrieve the ARCItmMast list for the creation of a new order 
	$$$LOGINFO("[NewOrder] Retrive the ARCItmMast list.")
	set sc = ..GetARCItmMast(1,,..#DefaultPageSize, .arcItmMastObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewOrder] Failed to get ARCItmMast.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	//create episode, the number of order is equal to the number of episode
	do ..NewEpisode(NumOfOrder, .episodeVoObjList)
	
	set trialCnt = 1
	set numOfLoop = NumOfOrder
	while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0))
	{
		$$$LOGINFO("[NewOrder] Trial: "_trialCnt_", Number of order to be created: "_numOfLoop)
		set numOfFailed = 0
		
		for cnt = 1:1:numOfLoop 
		{	
			try 
			{				
				//Set up Order request
				set request = ##class(CDUI.DataGen.Request.NewOrder).%New()
				set randEpisodeVoListIndex = ($$$PRand(episodeVoObjList.Count()) + 1)
				set randArcItmMastObjListIndex = ($$$PRand(arcItmMastObjList.Count()) + 1)

				set episodeVo = episodeVoObjList.GetAt(randEpisodeVoListIndex)
				set arcItmMastVo = arcItmMastObjList.GetAt(randArcItmMastObjListIndex)

				set request.Item = arcItmMastVo.ID
				set request.EpisodeID = episodeVo.ID

				//ARCItmMast (ARCIMEffDate) must < Order (OEORISttDat,OEORISttTim)
				//Episode (PAADMAdmDate,PAADMAdmTime) must < Order (OEORISttDat, OEORISttTim)
				set arcimEffDate = arcItmMastVo.ARCIMEffDate
				set paadmAdmDate = $zdateh(episodeVo.PAADMAdmDate,4)
				set minDate = paadmAdmDate
				set isAdmDateAsMinDate = 1

				//Get the larger date as a min date for the generation of the date (OEORISttDat) in Order 
				if arcimEffDate > paadmAdmDate {
					set minDate = arcimEffDate
					set isAdmDateAsMinDate = 0
				}
				$$$LOGINFO("[NewOrder] arcimEffDate: "_$zdate(arcimEffDate, 4)_", PAADMAdmDate: "_episodeVo.PAADMAdmDate_", minDate for order: "_$zdate(minDate, 4))
		
				set request.OEORISttDat = ##class(PUtil).CustomDate(minDate, $piece($horolog, ",", 1))

				if isAdmDateAsMinDate {
					set request.OEORISttTim = ##class(PUtil).Time(episodeVo.PAADMAdmTime,,2)
				} else {
					set request.OEORISttTim = ##class(PUtil).Time(,,2)
				}

				$$$LOGINFO("[NewOrder] Request: "_request.SerialisedGet())

				//Send a request
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{	
					$$$LOGINFO("[NewOrder] Response body: "_response.StringValue)
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){ 
						//No error, then store the order id in orderIdList
						set $list(orderIdList, * + 1) = json.ID
						//remove the episodeVo and arcItmMastVo from lists after it is used
						do episodeVoObjList.RemoveAt(randEpisodeVoListIndex)
						do arcItmMastObjList.RemoveAt(randArcItmMastObjListIndex)
					} else 
					{
						$$$LOGERROR("[NewOrder] Failed to create an order. Error(Json): "_json.ERROR)
						set numOfFailed = numOfFailed + 1
					}
				} else {
						$$$LOGERROR("[NewOrder] Failed to create an order. Error(SC): "_$System.Status.DisplayError(sc))
						set numOfFailed = numOfFailed + 1
				}
			} catch ex 
			{	
					$$$LOGERROR("[NewOrder] Failed to create an order. Error(Ex): "_ex.DisplayString())
					set numOfFailed = numOfFailed + 1
			} 
		}
		$$$LOGINFO("[NewOrder] Number of failure: "_numOfFailed)
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
		return sc
	}
		
	set resultSize = $listlength(orderIdList)
	$$$LOGINFO("[NewOrder] orderIdList: "_$LISTTOSTRING(orderIdList))
	$$$LOGINFO("[NewOrder] Success count: "_resultSize_", Failure count: "_(NumOfOrder - resultSize))
}

// Proof of concept, call OE_Order/LAB

ClassMethod NewLabOrder(NumOfLabOrder As %Integer = 1, Output labOrdVoObjList) As %Status
{
	set failedCount = 0

	//Create a VO list of ARCItmMast, it contains all kinds of items, not only radiology test items
	$$$LOGINFO("[NewLabOrder] Retrieve the ARCItmMast List.")
	set sc = ..GetARCItmMast(1,,..#DefaultPageSize,.arcItmMastObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewLabOrder] Failed to get ARCItmMast.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	//Create a VO list of Episode
	do ..NewEpisode(NumOfLabOrder,.episodeVoObjList)

	set trialCnt = 1
	set numOfLoop = NumOfLabOrder
	while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0))
	{
		$$$LOGINFO("[NewLabOrder] Trial: "_trialCnt_", Number of order to be created: "_numOfLoop)
		set numOfFailed = 0
		
		for cnt = 1:1:numOfLoop 
		{	
			try
			{
				set request = ##class(CDUI.DataGen.Request.NewLabOrder).%New()
				set randArcItmMastObjListIndex = ($$$PRand(arcItmMastObjList.Count()) + 1)
				set randEpisodeVoListIndex = ($$$PRand((episodeVoObjList).Count()) + 1)

				set episodeVo = episodeVoObjList.GetAt(randEpisodeVoListIndex)
				set arcItmMastVo = arcItmMastObjList.GetAt(randArcItmMastObjListIndex)

				set request.Item = arcItmMastVo.ID
				set request.EpisodeID = episodeVo.ID

				set arcimEffDate = arcItmMastVo.ARCIMEffDate
				set paadmAdmDate = $zdateh(episodeVo.PAADMAdmDate,4)
				set minDate = paadmAdmDate
				set isAdmDateAsMinDate = 1

				//Get the larger date as a min date for the generation of the date (OEORISttDat) in Order 
				if arcimEffDate > paadmAdmDate {
					set minDate = arcimEffDate
					set isAdmDateAsMinDate = 0
				}
				$$$LOGINFO("[NewLabOrder] arcimEffDate: "_$zdate(arcimEffDate, 4)_", PAADMAdmDate: "_episodeVo.PAADMAdmDate_", minDate for order: "_$zdate(minDate, 4))
		
				set request.OEORISttDat = ##class(PUtil).CustomDate(minDate, $piece($horolog, ",", 1))

				if isAdmDateAsMinDate {
					set request.OEORISttTim = ##class(PUtil).Time(episodeVo.PAADMAdmTime,,2)
				} else {
					set request.OEORISttTim = ##class(PUtil).Time(,,2)
				}

				set request.OECPRDesc = "Normal"
				$$$LOGINFO("[NewLabOrder] Request: "_request.SerialisedGet())
				
				//Send a request
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{	
					$$$LOGINFO("[NewLabOrder] Response body: "_response.StringValue)
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){ 
						//No error, then store the order id in orderIdList
						set $list(orderIdList, * + 1) = json.ID
						//remove the episodeVo and arcItmMastVo from lists after it is used
						do episodeVoObjList.RemoveAt(randEpisodeVoListIndex)
						do arcItmMastObjList.RemoveAt(randArcItmMastObjListIndex)
					} else 
					{
						$$$LOGERROR("[NewLabOrder] Failed to create an order. Error(Json): "_json.ERROR)
						set numOfFailed = numOfFailed + 1
					}
				} else {
						$$$LOGERROR("[NewLabOrder] Failed to create an order. Error(SC): "_$System.Status.DisplayError(sc))
						set numOfFailed = numOfFailed + 1
				}
			} catch ex 
			{	
					$$$LOGERROR("[NewLabOrder] Failed to create an order. Error(Ex): "_ex.DisplayString())
					set numOfFailed = numOfFailed + 1
			} 
		}
		$$$LOGINFO("[NewLabOrder] Number of failure: "_numOfFailed)
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
		}

	set resultSize = $listlength(orderIdList)
	$$$LOGINFO("[NewLabOrder] orderIdList: "_$LISTTOSTRING(orderIdList))
	$$$LOGINFO("[NewLabOrder] Success count: "_resultSize_", Failure count: "_(NumOfLabOrder - resultSize))
	return sc
}

ClassMethod GetOrderByCat(Count As %Integer = "", Category As %String = "", ByRef ResultObjList, ByRef Results) As %Status
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
		set iterator = json.results.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set insurType = ##class(CDUI.DataGen.vo.OrderCatVo).newInstance((value))
			do ResultObjList.Insert(insurType)
			#; write !, value.ORCATDesc,?30,value.ID
			set Results($increment(Results)) = $listbuild(value.Id,value.ORCATDesc)

		}
	}

	quit sc
}

/// New method to create new order by inputting order category
ClassMethod createNewOrder(Count As %Integer = "", OrderCat As %String, NumOfOrder As %Integer = 1, ByRef orderIdList)
{
	set failedCount = 0
	
	//Retrieve the order list by category  
	$$$LOGINFO("[NewOrder] Retrieve the GetOrderByCat list.")
	set sc = ..GetOrderByCat(Count, OrderCat, .orderVoObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[NewOrder] Failed to get GetOrderByCat.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

	//Create episode, the number of order is equal to the number of episode
	do ..NewEpisode(NumOfOrder, .episodeVoObjList)
	
	set trialCnt = 1
	set numOfLoop = NumOfOrder
	while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0))
	{
		$$$LOGINFO("[NewOrder] Trial: "_trialCnt_", Number of order to be created: "_numOfLoop)
		set numOfFailed = 0
		
		for cnt = 1:1:numOfLoop 
		{	
			try 
			{				
				//Set up Order request
				set request = ##class(CDUI.DataGen.Request.NewOrder).%New()

				// Get a random episode object index 
				set randEpisodeVoListIndex = ($$$PRand(episodeVoObjList.Count()) + 1)

				// Get a random ordercategory object index 
				set randorderVoObjListListIndex = ($$$PRand(orderVoObjList.Count()) + 1)

				// Get the episode and ordercategory objects
				set episodeVo = episodeVoObjList.GetAt(randEpisodeVoListIndex)
				set orderCatVo = orderVoObjList.GetAt(randorderVoObjListListIndex)

				set request.Item = orderCatVo.ID
				set request.EpisodeID = episodeVo.ID

				//orderCatVo (ARCIMEffDate) must < Order (OEORISttDat,OEORISttTim)
				//Episode (PAADMAdmDate,PAADMAdmTime) must < Order (OEORISttDat, OEORISttTim)
				set arcimEffDate = orderCatVo.ARCIMEffDate
				set paadmAdmDate = $zdateh(episodeVo.PAADMAdmDate,4)
				set minDate = paadmAdmDate
				set isAdmDateAsMinDate = 1

				//Get the larger date as a min date for the generation of the date (OEORISttDat) in Order 
				if arcimEffDate > paadmAdmDate {
					set minDate = arcimEffDate
					set isAdmDateAsMinDate = 0
				}
				$$$LOGINFO("[NewOrder] arcimEffDate: "_$zdate(arcimEffDate, 4)_", PAADMAdmDate: "_episodeVo.PAADMAdmDate_", minDate for order: "_$zdate(minDate, 4))
		
				set request.OEORISttDat = ##class(PUtil).CustomDate(minDate, $piece($horolog, ",", 1))

				if isAdmDateAsMinDate {
					set request.OEORISttTim = ##class(PUtil).Time(episodeVo.PAADMAdmTime,,2)
				} else {
					set request.OEORISttTim = ##class(PUtil).Time(,,2)
				}

				$$$LOGINFO("[NewOrder] Request: "_request.SerialisedGet())

				//Send a request
				set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
				set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
				if $$$ISOK(sc)
				{	
					$$$LOGINFO("[NewOrder] Response body: "_response.StringValue)
					set json = {}.%FromJSON(response.StringValue)
					if (json.ERROR = ""){ 
						//No error, then store the order id in orderIdList
						set $list(orderIdList, * + 1) = json.ID
						//remove the episodeVo and orderVoObjList from lists after it is used
						do episodeVoObjList.RemoveAt(randEpisodeVoListIndex)
						do orderVoObjList.RemoveAt(randorderVoObjListListIndex)
					} else 
					{
						$$$LOGERROR("[NewOrder] Failed to create an order. Error(Json): "_json.ERROR)
						set numOfFailed = numOfFailed + 1
					}
				} else {
						$$$LOGERROR("[NewOrder] Failed to create an order. Error(SC): "_$System.Status.DisplayError(sc))
						set numOfFailed = numOfFailed + 1
				}
			} catch ex 
			{	
					$$$LOGERROR("[NewOrder] Failed to create an order. Error(Ex): "_ex.DisplayString())
					set numOfFailed = numOfFailed + 1
			} 
		}
		$$$LOGINFO("[NewOrder] Number of failure: "_numOfFailed)
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
	}
		
	set resultSize = $listlength(orderIdList)
	$$$LOGINFO("[NewOrder] orderIdList: "_$LISTTOSTRING(orderIdList))
	$$$LOGINFO("[NewOrder] Success count: "_resultSize_", Failure count: "_(NumOfOrder - resultSize))
}

// V1.0 Yufan only create Rad result, exception handling, obtain a list input from NewOrder

ClassMethod NewResult(ResultType As %String = "Rad", NumOfResult As %Integer = 1, Output resultIdList) As %Status
{
    //TODO Yufan input ResultType should only have fixed options
	//TODO Yufan try catch
    set failedCount = 0
	
	//If the user wants to generate Rad results
	if ResultType = "Rad"{
		//Create an order id list for the creation of new results
		set sc = ..NewOrder(NumOfResult, .orderIdList)
		if $$$ISERR(sc)
		{
			$$$LOGERROR("[NewResult] Failed to create an order id list.")
			Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
		}
		
		$$$LOGINFO("[NewResult] Start generating Radiology results.")			
		set trialCnt = 1
		set numOfLoop = NumOfResult
		while ((..#MaxNumOfRetry >= trialCnt) && (numOfLoop > 0))
		{
			$$$LOGINFO("[NewResult] Trail: "_trialCnt_", Number of Rad result created: "_numOfLoop)
			set numOfFailed = 0

			for cnt = 1:1:numOfLoop
			{
				try
				{
					set request = ##class(CDUI.DataGen.Request.NewRadResult).%New()
					set randOrderIDListIndex = $$$PRand($LISTLENGTH(orderIdList))+1
					set request.OEOrdItemID = $list(orderIdList,randOrderIDListIndex)

					$$$LOGINFO("[NewResult] Request: "_request.SerialisedGet())
					set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
					set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
					
					if $$$ISOK(sc)
					{
						$$$LOGINFO("[NewResult] Response body: "_response.StringValue)
						set json = {}.%FromJSON(response.StringValue)
						set $list(resultIdList, *+1) = json.ID
					}
					else
					{
						$$$LOGERROR("[NewResult] Fariled to create a result. Error(Json): "_json.ERROR)
						set numOfFailed = numOfFailed + 1 
					}
				} 
				
				catch ex
				{
					$$$LOGERROR("[NewResult] Failed to create a new Rad result. Error(Ex): "_ex.DisplayString())
					set numOfFailed = numOfFailed + 1
				}

			}
		set numOfLoop = numOfFailed
		set trialCnt = trialCnt + 1
		}
		
		set resultSize = $LISTLENGTH(resultIdList)
		$$$LOGINFO("result ID list: "_ $LISTTOSTRING(resultIdList))
		$$$LOGINFO("[NewResult] Success count: "_resultSize)
	}
	return sc
}

ClassMethod mCreatePatient(NumOfPatient As %Integer = 1, ByRef PatientVoObjList)
{
	kill PatientVoObjList

	#; New instance of this class
	set patientService = ##class(CDUI.DataGen.DataGenService.PatientService).%New()

	#; Call method NewPatient
	do patientService.NewPatient(NumOfPatient, .PatientVoObjList)
	w !
	zw PatientVoObjList

	for cnt = 1:1:PatientVoObjList.Count(){
		w PatientVoObjList.GetAt(cnt).SerialisedGet()
	}
}

ClassMethod mCreateEpisode(NumOfEpisodePerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
	set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()
	do episodeService.NewEpisode(NumOfEpisodePerPatient, PatientVoObjList)
	w !
	zw PatientVoObjList

	for cnt = 1:1:PatientVoObjList.Count(){
		w PatientVoObjList.GetAt(cnt).SerialisedGet()
	}
}

ClassMethod CreateOrder() As %ListOfObjects
{
	/// For auxxmisc testing later
	/// 
	#; set aa = {}
	#; do aa.%Set("PatientId","11754")
	#; do aa.%Set("EpisodeObjList",[{"ID":"14764","PatientID":"11754","PAADMType":"I","PAADMAdmDate":"26/01/2023", "PAADMAdmTime":"09:02","CTLOCDesc":"Community Mental Health C1"},{"ID":"14793","PatientID":"11754","PAADMType":"O","PAADMAdmDate":"20/07/2021","PAADMAdmTime":"16:25","CTLOCDesc":"Cardiology H1"}])
	
	#; set bb = {}
	#; do bb.%Set("PatientId","11556")
	#; do bb.%Set("EpisodeObjList",[{"ID":"14759","PatientID":"11556","PAADMType":"I","PAADMAdmDate":"01/12/2022", "PAADMAdmTime":"10:00","CTLOCDesc":"Cardiology H1"},{"ID":"14794","PatientID":"11556","PAADMType":"O","PAADMAdmDate":"29/03/2021", "PAADMAdmTime":"14:30","CTLOCDesc":"Cardiology NZ"}])
	
	/// For 9096 testing 
	set aa = {}
	do aa.%Set("PatientId","13878")
	do aa.%Set("EpisodeObjList",[{"ID":"15515","PatientID":"13878","PAADMType":"I","PAADMAdmDate":"18/06/1992","PAADMAdmTime":"21:13","CTLOCDesc":"Geriatrics H2"},{"ID":"15516","PatientID":"13878","PAADMType":"I","PAADMAdmDate":"21/11/2003","PAADMAdmTime":"20:33","CTLOCDesc":"Orthopaedics H3"}])
	#; set bb = {}
	#; do bb.%Set("PatientId","13879")
	#; do bb.%Set("EpisodeObjList",[{"ID":"15517","PatientID":"13879","PAADMType":"I","PAADMAdmDate":"14/05/1992","PAADMAdmTime":"15:43","CTLOCDesc":"General Medicine H2"},{"ID":"15518","PatientID":"13879","PAADMType":"O","PAADMAdmDate":"28/08/1971","PAADMAdmTime":"13:51","CTLOCDesc":"Radiology H1"}])
	
	#; {"PatientId":"13880","EpisodeObjList":[{"ID":"15519","PatientID":"13880","PAADMType":"I","PAADMAdmDate":"29/01/1995","PAADMAdmTime":"16:13","CTLOCDesc":"Specimen Collection Community C1"},{"ID":"15520","PatientID":"13880","PAADMType":"O","PAADMAdmDate":"23/06/2012","PAADMAdmTime":"21:16","CTLOCDesc":"Paediatrics H1"}]}

	set PatientVoObjList = ##class(%ListOfObjects).%New()
	do PatientVoObjList.Insert(aa)
	#; do PatientVoObjList.Insert(bb)


	#; w !, aa.%Get("PatientId")
	#; w !, aa.%Get("EpisodeObjList")
	#; w !, aa.%Get("EpisodeObjList").%Size()
	#; w !, PatientVoObjList.GetAt(1)."PatientId"
	#; w !, PatientVoObjList.GetAt(2)."PatientId"

	#; set numEp = aa.%Get("EpisodeObjList").%Size()

	set numOfLoop = PatientVoObjList.Count()

	for cnt = 1:1:numOfLoop{
		set epArray = PatientVoObjList.GetAt(cnt)."EpisodeObjList"
		set iterator = epArray.%GetIterator()
		while iterator.%GetNext(.key,.value)
		{	
			set location = ##class("CDUI.DataGen.vo.LocationVo").newInstance(value)
			set Episodes($increment(Episodes)) = $listbuild(value.ID,value.PAADMType)
			#; write !, value.ID,?30,value.PAADMType, !
		}
	}

	#; w "Size of episode", !, PatientVoObjList.GetAt(1).%Get("EpisodeObjList").%Size()
	return PatientVoObjList
}

ClassMethod TestingOrder(NumOfOrderPerEpisode As %Integer = 1, OrderCat As %String, ByRef PatientVoObjList As %ListOfObjects)
{
	set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
	set OrderCat = OrderCat

	set PatientVoObjList = ..CreateOrder()

	/// TO DO - CN to add category as parameter
	do orderService.NewOrder(NumOfOrderPerEpisode, OrderCat, PatientVoObjList)
	w !
	zw PatientVoObjList

	// TO DO - CN Something wrong here ??? 
	#; for cnt = 1:1:PatientVoObjList.Count(){
	#; 	w PatientVoObjList.GetAt(cnt).SerialisedGet()
	#; }
}

ClassMethod Sunday()
{
	 set mylist=##class(%ListOfDataTypes).%New()
	do mylist.Insert("red")
	do mylist.Insert("green")
	do mylist.Insert("blue")
	w !, mylist.Count()
	w !, mylist.GetAt(1)
	w !, mylist.GetAt(2)
}

ClassMethod PatientObject()
{
	set patientVoObjList =  ##class(%ListOfObjects).%New()
	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	do patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11754))

	set request = ##class(CDUI.DataGen.Request.NewPatient).%New()
	do patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,11732))
	#; zw patientVoObjList
	#; w !, patientVoObjList.GetAt(1)
	#; w !, patientVoObjList.GetAt(1).PatientId
	return patientVoObjList
}

}
