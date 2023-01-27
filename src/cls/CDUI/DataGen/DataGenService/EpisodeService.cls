Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.EpisodeService Extends (%RegisteredObject, BaseService)
{

Method NewEpisode(NumOfEpisodePerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects)
{
	set locationTypeId = "E" // TODO Marcus make it constant / enum
	set minAdmDate = "1/1/1970"
    set totalSuccess = 0
    set totalFailure = 0
    kill failedByPatientIdArr

	//Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[EpisodeService.NewEpisode] Retrive the location list.")
    set sc = ##class(TrakCareService).GetLocation(,1,locationTypeId,..#DefaultPageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[EpisodeService.NewEpisode] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    $$$LOGINFO("[EpisodeService.NewEpisode] Number of patient: "_PatientVoObjList.Count())
    $$$LOGINFO("[EpisodeService.NewEpisode] Number of episode per patient: "_NumOfEpisodePerPatient)

    set numOfLoop = PatientVoObjList.Count()

    for cnt=1:1:numOfLoop{
        set patientVo = PatientVoObjList.GetAt(cnt)

        $$$LOGINFO("[EpisodeService.NewEpisode] Initialize episode request, patient Id: "_patientVo.PatientId)
   
        // generate episode records and insert them to TrakCare via API.
        $$$LOGINFO("[EpisodeService.NewEpisode] Create new episodes.")
        do ..InitEpisodeRequestPerPatientByRandom(minAdmDate, locationObjList, NumOfEpisodePerPatient, patientVo, .episodeInput)
        set episodeOutput = ##class(CDUI.DataGen.DataGenService.Custom.EpisodeOutput).%New()

        do ..RunWithRetry(episodeInput, episodeOutput)

        //set the inserted episodeVo back to patient for further use if necessary
        set patientVo.EpisodeObjList = episodeOutput.EpisodeVoObjList

        set episodeIdList = episodeOutput.EpisodeIdList
        set numOfSuccess = episodeIdList.Count()
        set numOfFailure = NumOfEpisodePerPatient - numOfSuccess

        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByPatientIdArr(patientVo.PatientId) = numOfFailure
        }
        
        $$$LOGINFO("[EpisodeService.NewEpisode] pateint Id: "_patientVo.PatientId_", episodeIdList: "_episodeIdList)
        $$$LOGINFO("[EpisodeService.NewEpisode] Success count: "_numOfSuccess_", Failure count: "_numOfFailure)
    }
    set cnt = 0
    set key = $Order(failedByPatientIdArr(""))
    while (key '= "") {
        $$$LOGINFO("Patient Id: "_key_", Number of Failure: "_failedByPatientIdArr(key))
        set key = $Order(failedByPatientIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[EpisodeService.NewEpisode] Total number of Patient with failed episode creation: "_cnt)
	$$$LOGINFO("[EpisodeService.NewEpisode] Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method Run(episodeInput As CDUI.DataGen.DataGenService.Base.Input, episodeOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    kill idxTmpArr
	set requestObjList = episodeInput.RequestObjList
    set locationObjList = episodeInput.LocationObjList
    set locationIndexList = episodeInput.LocationIndexList
    set episodeIdList = ##class(%ListOfDataTypes).%New()

    set episodeVoObjList = episodeOutput.EpisodeVoObjList

    set numOfLoop = requestObjList.Count()
    set numOfFailed = 0

    if '$ISOBJECT(episodeVoObjList) {
		set episodeVoObjList =  ##class(%ListOfObjects).%New()
	}

    set failedEpisodeRequestObjList =  ##class(%ListOfObjects).%New()

    $$$LOGINFO("[EpisodeService.Run] Number of requests: "_numOfLoop)

    for cnt=1:1:numOfLoop {
        set request = requestObjList.GetAt(cnt)
        $$$LOGINFO("[EpisodeService.Run] Request: "_request.SerialisedGet())
        set isSuccess = 0
        try {
            //Send the request
            set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
            set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

            if $$$ISOK(sc)
            {	
                $$$LOGINFO("[EpisodeService.Run] Response body: "_response.StringValue)
                set json = {}.%FromJSON(response.StringValue)
                if (json.ERROR = ""){ 
                    //No error then store the record to episodeVoObjList
                    do episodeVoObjList.Insert(##class(CDUI.DataGen.vo.EpisodeVo).newInstance(request,json.ID))
                    do episodeIdList.Insert(json.ID)
                    set isSuccess = 1
                } else {
                    $$$LOGERROR("[EpisodeService.Run] Failed to create an episode. Error(Json): "_json.ERROR)
                    // if it matches, remove the invalid insurance record from the list.
                    set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^CTLOCDesc.*")
                    if isMatch {
                        set idxTmpArr(locationIndexList.GetAt(cnt)) = ""
                    }
                }
            } else {
                    $$$LOGERROR("[EpisodeService.NewEpisode] Failed to create an episode. Error(SC): "_$System.Status.DisplayError(sc))
            }
        } catch ex {	
                    $$$LOGERROR("[EpisodeService.NewEpisode] Failed to create an episode. Error(Ex): "_ex.DisplayString())
        }

        if isSuccess '= 1 {
            do failedEpisodeRequestObjList.Insert(request)
            set numOfFailed = numOfFailed + 1
        }
    }
    if $Order(idxTmpArr("")) {
        do ..RemoveItemsInverseFromList(locationObjList, .idxTmpArr)
    }

    //Special heandling to re-select the location to deal with invalid location data retrieved from db.
    for cnt=1:1:failedEpisodeRequestObjList.Count(){
        do ..AssignLocation(locationObjList, failedEpisodeRequestObjList.GetAt(cnt), .locationIndexList)  
    }
 
    //combine the list or assign a new one
    if (episodeOutput.EpisodeIdList '= "") {	
		for cnt=1:1:episodeIdList.Count(){
			do episodeOutput.EpisodeIdList.Insert(episodeIdList.GetAt(cnt))
		}
	} else { 
		set episodeOutput.EpisodeIdList = episodeIdList
	}

    //Reset the input for retry
    set episodeInput.RequestObjList = failedEpisodeRequestObjList
    set episodeInput.LocationObjList = locationObjList
    set episodeInput.LocationIndexList = locationIndexList

    set episodeOutput.NumOfFailed = numOfFailed
	set episodeOutput.EpisodeVoObjList = episodeVoObjList

	quit numOfFailed
}

Method RemoveItemsInverseFromList(sourceList As %ListOfObjects, ByRef removalIndexArray)
{

    set key = $Order(removalIndexArray(""), -1) //inverse order, delete the items in inverse order
    while (key '= "") {
        do sourceList.RemoveAt(key)
        set key = $Order(removalIndexArray(key), -1)
    }
}

Method InitEpisodeRequestPerPatientByRandom(minAdmDate As %String, locationObjList As %ListOfObjects, numOfEpisodePerPatient As %Integer, patientVo As CDUI.DataGen.vo.PatientVo, Output episodeInput As CDUI.DataGen.DataGenService.Custom.EpisodeInput)
{
    kill episodeInput
    kill dateGenArr

    set episodeInput = ##class(CDUI.DataGen.DataGenService.Custom.EpisodeInput).%New()
    set admTypeList = $LISTFROMSTRING(##class(Constants).#admTypeCode,",",0)
    set visitStatusList = $LISTFROMSTRING(##class(Constants).#visitStatusCode,",",0)
    set inPatientWithCurrentAdmDate = ""
    set episodeTmpList = ##class(%ListOfObjects).%New()
   /*
    	1. 1 or 0 current in-patient episode (Patient type = I and VisitStatus = A)
        2. If there is current in-patient , then no more inpatient after that
        3. If visit status = Discharge > set PAADMDischgDate and PAADMDischgTime
    */

    //Generate the dates for episode first. By using array, it can be sorted automatcially.
    set cnt = 0
    while cnt < numOfEpisodePerPatient {
        set date = ##class(PUtil).CustomDate($zdateh(minAdmDate,4), $piece($horolog, ",", 1))
        if $data(dateGenArr(date)) = 0 {
            set dateGenArr(date) = ""
            set cnt = cnt + 1
        }
    }

    //Generate different type of episode with different status
    set isInpatientWithCurrent = 0
    for cnt=1:1:numOfEpisodePerPatient {
        set request = ##class(CDUI.DataGen.Request.NewEpisode).%New()
        set request.PAADMType = $List(admTypeList, $$$PRand($listlength(admTypeList))+1)
        set request.PAADMVisitStatus = $List(visitStatusList, $$$PRand($listlength(visitStatusList))+1)

        while(isInpatientWithCurrent = 1 && request.PAADMType = "I" &&  request.PAADMVisitStatus = "A") {
            set request.PAADMVisitStatus = $List(visitStatusList, $$$PRand($listlength(visitStatusList))+1)
        }

        if (isInpatientWithCurrent = 0 && request.PAADMType = "I" &&  request.PAADMVisitStatus = "A") {
            set isInpatientWithCurrent = 1
        }

        do episodeTmpList.Insert(request)
    }

	//1. 1 or 0 current in-patient episode (Patient type = I and VisitStatus = A)
    //2. If there is current in-patient , then no more inpatient after that
    //By swapping the position of current in-patient with the position of last in-patient to achieve this requirement
    if isInpatientWithCurrent 
    {
        set idxOfCurrentInPatient = 0
        set idxOflastInPatient = -1
        for cnt=1:1:episodeTmpList.Count()
        {
            set request = episodeTmpList.GetAt(cnt)
            if (request.PAADMType = "I" &&  request.PAADMVisitStatus = "A") {
                set idxOfCurrentInPatient = cnt
            } elseif (request.PAADMType = "I"){
                set idxOflastInPatient = cnt
            }
        }
        //swap the episode position
        if (idxOflastInPatient > idxOfCurrentInPatient) {
            set tmp = episodeTmpList.GetAt(idxOflastInPatient)
            do episodeTmpList.RemoveAt(idxOflastInPatient)
            do episodeTmpList.InsertAt(episodeTmpList.GetAt(idxOfCurrentInPatient), idxOflastInPatient)
            do episodeTmpList.InsertAt(tmp, idxOfCurrentInPatient)
        }
    }
    
    //Assign the values to corresponding attributes in episodes
    set dateGenArrKey = $ORDER(dateGenArr(""))
    for cnt=1:1:numOfEpisodePerPatient
    {
        set request = episodeTmpList.GetAt(cnt)
        set request.PatientID = patientVo.PatientId
        set request.PAADMAdmDate = dateGenArrKey
        set request.PAADMAdmTime = ##class(PUtil).Time(,,2)
        set dateGenArrKey = $ORDER(dateGenArr(dateGenArrKey))

        //TODO Marcus check if discharge should only be applied to in-patient
        if (request.PAADMVisitStatus = "D")
        {
            //PAADMDischgDate should be after PAADMAdmDate
            set currentDate = $piece($horolog, ",", 1)

            //if the admDate is current date, then the discharge time must be larger than the admTime

            if (currentDate = request.PAADMAdmDate){
                set request.PAADMDischgDate = currentDate
                set request.PAADMDischgTime = ##class(PUtil).Time(request.PAADMAdmTime,,2)
            } else {
                set request.PAADMDischgDate = ##class(PUtil).CustomDate($zdateh(request.PAADMAdmDate,4) + 1, currentDate)
                set request.PAADMDischgTime = ##class(PUtil).Time(,,2)
            }
        }

        do ..AssignLocation(locationObjList, request, .locationIndexList)
    }
    set episodeInput.RequestObjList = episodeTmpList
    set episodeInput.LocationObjList = locationObjList
    set episodeInput.LocationIndexList = locationIndexList
}

Method GetPatientIdList(patientVoObjList As %ListOfObjects, Output patientIdList As %List)
{
    kill patientIdList

    for cnt=1:1:patientVoObjList.Count(){
        set $list(patientIdList, * + 1) = patientVoObjList.GetAt(cnt).PatientId
    }
}

Method AssignLocation(locationObjList As %ListOfObjects, request As CDUI.DataGen.Request.NewEpisode, Output locationIndexList)
{
       if (locationObjList.Count() > 0){
                set randLocationIndex = ##class(PUtil).Random(locationObjList.Count()) + 1
                set location = locationObjList.GetAt(randLocationIndex)
                set request.CTLOCDesc = location.CTLOCDesc
                set $list(locationIndexList, * + 1) = randLocationIndex
        }
}

}
