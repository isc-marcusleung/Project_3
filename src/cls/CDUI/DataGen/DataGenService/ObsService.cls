Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ObsService Extends BaseService
{

Parameter locationTypeId = "E";

// For a single patient, each episode has different numbers of episodes

Method NewObsByRange(MinNumOfObs As %Integer = 1, MaxNumOfObs As %Integer = 1, EpisodeVoObjList As %ListOfObjects, jobId As %Integer, Output failedByEpisodeIdArr)
{
    kill failedByEpisodeIdArr
    do ..GetLocation(.locationObjList)
    set diff = MaxNumOfObs - MinNumOfObs
    set totalSuccess = 0
    set totalFailure = 0
    set numOfLoop = EpisodeVoObjList.Count()
    for i = 1:1:numOfLoop{
        set ranNum = ##class(PUtil).Random(diff) + MinNumOfObs
        if (ranNum > 0){
            set episodeVo = EpisodeVoObjList.GetAt(i)
            do ..NewObsPerEpisode(ranNum, episodeVo, .locationObjList, .numOfSuccess, jobId)
            set numOfFailure = ranNum - numOfSuccess
            set totalSuccess = totalSuccess + numOfSuccess
            set totalFailure = totalFailure + numOfFailure

            if (numOfFailure>0){
                set failedByEpisodeIdArr(EpisodeVoObjList.GetAt(i).ID) = numOfFailure
            }
        }
        do ..PrintResult(.failedByEpisodeIdArr, totalSuccess, totalFailure)
    }
}

// For a single episode, generate a number of observations 

Method NewObsPerEpisode(NumOfObsPerEpisode As %Integer = 1, EpisodeVo As CDUI.DataGen.vo.EpisodeVo, ByRef locationObjList As %ListOfObjects, ByRef numOfSuccess As %Integer, jobId As %Integer)
{
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Initialize obs request, episode Id: "_EpisodeVo.ID)

    //generate obsverations records 
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Initalize observation requests.")
    do ..InitObsRequest(locationObjList, NumOfObsPerEpisode, EpisodeVo, jobId, .obsInput)
    set obsOutput = ##class(CDUI.DataGen.DataGenService.Custom.ObsOutput).%New()

    do ..RunWithRetry(obsInput,obsOutput,)
    //Insert the obsveration vo created back to respective episode vo
    set EpisodeVo.ObsObjList = obsOutput.ObsVoObjList
    set obsIdList = obsOutput.ObsIdList
    set numOfSuccess = obsIdList.Count()
    set numOfFailure = NumOfObsPerEpisode - numOfSuccess
    if numOfSuccess '= 0 {
        $$$LOGINFO("[ObsService.NewObsPerEpisode] episode Id: "_EpisodeVo.ID_", obsIdList: "_##class(CommonUtil).convertListOfDataTypeToString(obsIdList,))
    }
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Success count: "_numOfSuccess_", Failure count: "_numOfFailure)
}

// Create same number of observations for all episodes

Method NewObs(NumOfObsPerEpisode As %Integer = 1, EpisodeVoObjList As %ListOfObjects, jobId As %Integer, Output failedByEpisodeIdArr)
{
    kill failedByEpisodeIdArr
    set totalSuccess = 0
    set totalFailure = 0
    $$$LOGINFO("[ObsService.NewObs] Number of episode: "_EpisodeVoObjList.Count())
    $$$LOGINFO("[ObsService.NewObs] Number of obserations per episode: "_NumOfObsPerEpisode)
    
    //Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[ObsService.NewObs] Retrive the location list.")

    do ..GetLocation(.locationObjList)

    set numOfLoop = EpisodeVoObjList.Count()
    for cnt = 1:1:numOfLoop{
        set episodeVo = EpisodeVoObjList.GetAt(cnt)
        kill numOfSuccess
        kill numOfFailure

        //One to many mapping, for each episode, create multiple observation creation requests and store them in obsInput
        do ..NewObsPerEpisode(NumOfObsPerEpisode, episodeVo, .locationObjList, .numOfSuccess, jobId)
        set numOfFailure = NumOfObsPerEpisode - numOfSuccess
        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByEpisodeIdArr(episodeVo.ID) = numOfFailure
        }
    }
    do ..PrintResult(.failedByEpisodeIdArr, totalSuccess, totalFailure)
}

// initialize obs request for one episode, number of request depends on NumOfObsPerEpisode

// pack a list of request objects for one episode in the ObsInput object 

Method InitObsRequest(locationObjList As %ListOfObjects, NumOfObsPerEpisode As %Integer, episodeVo As CDUI.DataGen.vo.EpisodeVo, jobId As %Integer, Output obsInput As CDUI.DataGen.DataGenService.Custom.ObsInput) [ Private ]
{
    kill obsInput
    set obsInput = ##class(CDUI.DataGen.DataGenService.Custom.ObsInput).%New()

    set locationDesc = episodeVo.CTLOCDesc

    for cnt = 1:1:NumOfObsPerEpisode{
        do ..UpdateMradm(.episodeVo)
        do ..CheckLocObjList(locationObjList, locationDesc, .locationCode)
        //update date and time so that each request has different date and time
        do ..GetExecDT(cnt,.ExecDateD,.ExecTimeD)
        
        //Randomly select a set of observations 
        do ..GetObsItemSet(.obsItemSet)

        //packing one request object 
        set request = ##class(CDUI.DataGen.Request.NewObservation).%New()
        set request.jobId = jobId
        set request.PatientID = episodeVo.PatientID
        set request.mradm = episodeVo.mradm
        set request.EpisodeID = episodeVo.ID
        set request.ObsDate = ExecDateD
        set request.ObsTime = ExecTimeD
        set request.OEOREDateExecuted = ExecDateD
        set request.OEORETimeExecuted = ExecTimeD
        set request.OBSENTRYPatLocDesc = locationCode
        set request.TOVERRIDE = 1

        do ..PackObsItemSetToRequest(obsItemSet,.request)

        //save the request object to the list 
        do obsInput.RequestObjList.Insert(request)

    }
}

// Randomly get a set of observation items 

ClassMethod GetObsItemSet(Output obsItemSet)
{
    set numOfRecord = 0
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.TriageNew)
    set randomNum = $RANDOM(numOfRecord)+1
    set obsItemSet = ##class(CDUI.DataGen.MIMIC.TriageNew).%OpenId(randomNum)
}

// Pack obs item set to request 

ClassMethod PackObsItemSetToRequest(obsItemSet, ByRef request As CDUI.DataGen.Request.NewObservation)
{
    do ..UpdateTableItems(obsItemSet,"VS1", .request)
    do ..UpdateTableItems(obsItemSet,"VS2", .request)
    do ..UpdateTableItems(obsItemSet,"VS3", .request)
    do ..UpdateTableItems(obsItemSet,"VS4", .request)
    do ..UpdateTableItems(obsItemSet,"VS5", .request)
    do ..UpdateTableItems(obsItemSet,"VS6", .request)
    do ..UpdateTableItems(obsItemSet,"HEIGHT", .request)
    do ..UpdateTableItems(obsItemSet,"WEIGHT", .request)
}

// Get current date and time and convert them to display form

ClassMethod GetCurrentDT(Output dateD, Output timeD)
{
    SET dateH=$PIECE($HOROLOG,",",1)
    SET timeH=$PIECE($HOROLOG,",",2)
    set dateD = $zdate(dateH,4)
    set timeD = $ztime(timeH,2)
}

// calculate execution data an time from current date and time, exec date and time must be in the past 

// interval is a integer that has a unit minutes 

ClassMethod GetExecDT(counter As %Integer, Output ExecDateD, Output ExecTimeD)
{
    do ..GetCurrentDT(.CurrentDateD,.CurrentTimeD)
    set CurrentDateH = $zdh(CurrentDateD,4)
    set CurrentTimeH = $zth(CurrentTimeD,2)
    set intervalInSec = 600
    set ExecDateH = CurrentDateH - 10
    set ExecTimeH = CurrentTimeH + (counter * 60) 
    if ExecTimeH > 86399 {
        set ExecTimeH = ExecTimeH - 86400
        set ExecDateH = ExecDateH + 1 
    }
    set ExecDateD = $zdate(ExecDateH,4)
    set ExecTimeD = $ztime(ExecTimeH,2)
}

ClassMethod UpdateDateD(DateD As %String, Output NewDateD As %String)
{
    set DateH = $zdh(DateD,4)
    set DateH = DateH - 1
    set NewDateD = $zdate(DateH,4)
}

// update the mradm property of EpisodeVo

ClassMethod UpdateMradm(ByRef episodeVo As CDUI.DataGen.vo.EpisodeVo)
{
    //call the API to get episode by id, name of the property in request has to match API requirement!
    try{
        set request = ##class(CDUI.DataGen.Request.GetEpisodeById2).%New()
        set request.EpisodeIDs = episodeVo.ID

        set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
		set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
        set json = {}.%FromJSON(response.StringValue)
    }
    catch ex
    {   
        do LOG^%ETN
        $$$LOGERROR("[UpdateMradm] Failed to get episode info. Error(Ex): "_ex.DisplayString())
    }
    set results = json.results
    set mradm = results.%Get(0).mradm
    set episodeVo.mradm = mradm
}

// search through the location object list, find find the object where locDescValue equals to the inputted value, return the locCodeValue of the object 

// use locDescValue to obtain locCodeValue from location objects in LocObjList 

ClassMethod CheckLocObjList(LocObjList As %ListOfObjects, locDescValue As %String, Output locCodeValue)
{
    set cnt = LocObjList.Count()
    set locCodeValue = "not found"
    for i = 1:1:cnt{
        if LocObjList.GetAt(i).CTLOCDesc = locDescValue{
            set locCodeValue = LocObjList.GetAt(i).CTLOCCode
            quit 
        }
    }
}

// use one object of obs set info from a persistent calss while creating an observation request 

ClassMethod UpdateTableItems(obsItemSet, itemCode As %String, ByRef obsReq As CDUI.DataGen.Request.NewObservation)
{
    set obsItem = ##class(CDUI.DataGen.Request.NewObservationItem).%New()
    if itemCode = "HEIGHT"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 11
        set obsItem.OBSValue = obsItemSet.Height
    }
    if itemCode = "WEIGHT"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 185
        set obsItem.OBSValue = obsItemSet.Weight
    }
    if itemCode = "VS1"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 41
        set obsItem.OBSValue = obsItemSet.SBP
    }
    if itemCode = "VS2"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 868
        set obsItem.OBSValue = obsItemSet.DBP
    }
    if itemCode = "VS3"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 1134
        set obsItem.OBSValue = obsItemSet.HeartRate
    }
    if itemCode = "VS4"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 1185
        set obsItem.OBSValue = obsItemSet.Respirations
    }
    if itemCode = "VS5"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 334
        set obsItem.OBSValue = obsItemSet.Temp
    }
    if itemCode = "VS6"{
        set obsItem.OBSCode = itemCode
        set obsItem.ObsItemID = 825
        set obsItem.OBSValue = obsItemSet.O2Sat
    }

    Do obsReq.TableItems.Insert(obsItem)
}

Method PrintResult(ByRef failedByEpisodeIdArr, totalSuccess, totalFailure)
{
    set cnt = 0
    set key = $Order(failedByEpisodeIdArr(""))
    while (key '= "") {
        if (cnt = 0) {
            $$$LOGINFO("[ObsService.PrintResult] Failure per episode")
        }
        $$$LOGINFO("[ObsService.PrintResult] Patient Id: "_key_", Number of Failure: "_failedByEpisodeIdArr(key))
        set key = $Order(failedByEpisodeIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[ObsService.PrintResult] Total number of Episode with failed obsveration creation: "_cnt)
	$$$LOGINFO("[ObsService.PrintResult] Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method GetLocation(Output locationObjList As %ListOfObjects) [ Private ]
{
	//Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[EpisodeService.GetLocation] Retrive the location list.")
    set sc = ##class(TrakCareService).GetLocation(,1,..#locationTypeId,..PageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[EpisodeService.GetLocation] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}
}

// core component of runWithRety, do various business service calls using the list of requests 

Method Run(obsInput As CDUI.DataGen.DataGenService.Base.Input, obsOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    //obtain request objects 
    set requestObjList = obsInput.RequestObjList
    set numOfLoop = requestObjList.Count()
    $$$LOGINFO("[ObsService.Run] Number of requests: "_numOfLoop)

    //obtain obs vo list, it is empty if this is not a retry run 
    set obsVoObjList = obsOutput.ObsVoObjList

    //initialize lists to store responses
    if '$Data(obsVoObjList) {
		set obsVoObjList =  ##class(%ListOfObjects).%New()
	}
    
    set obsIdList = ##class(%ListOfDataTypes).%New()

    //prepare for rerun 
    set numOfFailed = 0 
    set failedObsRequestObjList = ##class(%ListOfObjects).%New()

    for cnt = 1:1:numOfLoop{
        set request = requestObjList.GetAt(cnt)
        $$$LOGINFO("[ObsService.Run] Request: "_request.SerialisedGet())
        set isSuccess = 0

        try {
            set sc = ..SendRequest(request,.response)
            if $$$ISOK(sc){
                $$$LOGINFO("[ObsService.Run] Response body: "_response.StringValue)
                set json = {}.%FromJSON(response.StringValue)
                if (json.ERROR = ""){
                    do obsVoObjList.Insert(##class(CDUI.DataGen.vo.ObsVo).newInstance(request,json.ID))
                    do obsIdList.Insert(json.ID)
                    set isSuccess = 1
                }
                else {
                    $$$LOGERROR("[ObsService.Run] Failed to create an observation. Error(Json): "_json.ERROR)
                    set isMatchTimeError = $MATCH(json.ERROR, ".*The time entered already exists.*")
                    if isMatchTimeError{
                        $$$LOGINFO("Time Already exist error.")
                        set DateD = request.OEOREDateExecuted
                        $$$LOGINFO("DateD: "_DateD)
                        do ..UpdateDateD(DateD,.NewDateD)
                        $$$LOGINFO("NewDateD: "_NewDateD)
                        set request.OEOREDateExecuted = NewDateD
                        set request.ObsDate = NewDateD
                        $$$LOGINFO("RequestDateD: "_request.OEOREDateExecuted)
                    }

                    set isMatchCritAlertError = $MATCH(json.ERROR, ".*The following items are within the Critical range of the Early Warning Scoring System.*")
                    if isMatchCritAlertError{
                        $$$LOGINFO("Critical Alert error.")
                        do ..GetObsItemSet(.obsItemSet)
                        do ..PackObsItemSetToRequest(obsItemSet, .request)
                    }

                    set isMatchFrequencyError = $MATCH(json.ERROR, ".*EWS  2 (MODERATE).*")
                    if isMatchFrequencyError{
                        $$$LOGINFO("Frequency error.")
                        set DateD = request.OEOREDateExecuted
                        do ..UpdateDateD(DateD,.NewDateD)
                        set request.OEOREDateExecuted = NewDateD
                        set request.ObsDate = NewDateD
                    }
                        
                    $$$LOGINFO("Frequency error: "_isMatchFrequencyError_" Critical Alert error: "_isMatchCritAlertError_" Time error: "_isMatchTimeError)
                    $$$LOGINFO("[ObsService.Run] NewRequest: "_request.SerialisedGet())
                }
            }
            else{
                $$$LOGERROR("[ObsService.Run] Failed to create an observation. Error(SC): "_$System.Status.DisplayError(sc))
            }
        }
        catch ex {
            do LOG^%ETN	
            $$$LOGERROR("[ObsService.Run] Failed to create an observation. Error(Ex): "_ex.DisplayString())
        }
        
        //if error occurs
        if isSuccess '= 1{
            do failedObsRequestObjList.Insert(request)
            set numOfFailed = numOfFailed + 1
        }
    }

    //Update the obsIdList in obsOutput
    //combine the id list if this run is a retry run; assign a new list if this run is not a retry run
    if (obsOutput.ObsIdList '= ""){
        for cnt = 1:1:obsIdList.Count(){
            do obsOutput.ObsIdList.Insert(obsIdList.GetAt(cnt))
        }
    }
    else{
        set obsOutput.ObsIdList = obsIdList
    }

    //Reset the input for retry
    set obsInput.RequestObjList = failedObsRequestObjList

    //Update the ObsVoList in the output object 
    set obsOutput.ObsVoObjList = obsVoObjList

    $$$LOGINFO("[ObsService.Run] Number of failed trails is "_numOfFailed)
    quit numOfFailed
}

}
