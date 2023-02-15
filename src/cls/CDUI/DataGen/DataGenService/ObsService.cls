Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ObsService Extends BaseService
{

Parameter locationTypeId = "E";

Method NewObsPerEpisode(NumOfObsPerEpisode As %Integer = 1, EpisodeVo As CDUI.DataGen.vo.EpisodeVo, ByRef locationObjList As %ListOfObjects, ByRef numOfSuccess As %Integer)
{
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Initialize obs request, episode Id: "_EpisodeVo.ID)

    //generate obsverations records 
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Create new obsverations.")
    do ..InitObsRequest(locationObjList, NumOfObsPerEpisode, EpisodeVo,.obsInput)
    set obsOutput = ##class(CDUI.DataGen.DataGenService.Custom.ObsOutput).%New()

    do ..RunWithRetry(obsInput,obsOutput,)
    //Insert the obsveration vo created back to respective episode vo
    set EpisodeVo.ObsObjList = obsOutput.ObsVoObjList
    set obsIdList = obsOutput.ObsIdList
    set numOfSuccess = obsOutput.Count()
    set numOfFailure = NumOfObsPerEpisode - numOfSuccess
    if numOfSuccess '= 0 {
        $$$LOGINFO("[ObsService.NewObsPerEpisode] episode Id: "_EpisodeVo.ID_", episodeIdList: "_##class(CommonUtil).convertListOfDataTypeToString(obsIdList,))
    }
    $$$LOGINFO("[ObsService.NewObsPerEpisode] Success count: "_numOfSuccess_", Failure count: "_numOfFailure)
}

// Create same number of observations for all episodes

Method NewObs(NumOfObsPerEpisode As %Integer = 1, EpisodeVoObjList As %ListOfObjects)
{
    set totalSuccess = 0
    set totalFailure = 0
    $$$LOGINFO("[ObsService.NewObs] Number of episode: "_EpisodeVoObjList.Count())
    $$$LOGINFO("[ObsService.NewObs] Number of obserations per episode: "_NumOfObsPerEpisode)
    
    //Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[ObsService.NewObs] Retrive the location list.")

    //Initialize the log file
	do ##class(CDUI.DataGen.ExportLog).LogJob(,"Observation Creation")

    do ..GetLocation(.locationObjList)

    set numOfLoop = EpisodeVoObjList.Count()
    for cnt = 1:1:numOfLoop{
        set episodeVo = EpisodeVoObjList.GetAt(cnt)
        kill numOfSuccess
        kill numOfFailure

        //One to many mapping, for each episode, create multiple observation creation requests and store them in obsInput
        do ..NewObsPerEpisode(NumOfObsPerEpisode, episodeVo, .locationObjList, .numOfSuccess)
        set numOfFailure = NumOfObsPerEpisode - numOfSuccess
        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure
        set failedByEpisodeIdArr = []

        if (numOfFailure > 0) {
            set failedByEpisodeIdArr(episodeVo.ID) = numOfFailure
        }
    }
    do ..PrintResult(failedByEpisodeIdArr, totalSuccess, totalFailure)
}

// initialize obs request for one episode, number of request depends on NumOfObsPerEpisode

// pack a list of request objects for one episode in the ObsInput object 

Method InitObsRequest(locationObjList As %ListOfObjects, NumOfObsPerEpisode As %Integer, episodeVo As CDUI.DataGen.vo.EpisodeVo, Output obsInput As CDUI.DataGen.DataGenService.Custom.ObsInput) [ Private ]
{
    kill obsInput
    set obsInput = ##class(CDUI.DataGen.DataGenService.Custom.ObsInput).%New()

    do ..GetCurrentDT(.DateD,.TimeD)
    set locationDesc = episodeVo.CTLOCDesc

    for cnt = 1:1:NumOfObsPerEpisode{
        do ..UpdateMradm(.episodeVo)
        do ..CheckLocObjList(locationObjList, locationDesc, .locationCode)
        //update date and time so that each request has different date and time 
        do ..UpdateDT(.DateD,.TimeD,30)
        do ..UpdateD(.DateD)
        
        //Randomly select a set of observations 
        set numOfRecord = 0
        &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.Observations)
        set randomNum = $RANDOM(numOfRecord)+1
        set obsItemSet = ##class(CDUI.DataGen.MIMIC.Observations).%OpenId(randomNum)

        //packing one request object 
        set request = ##class(CDUI.DataGen.Request.NewObservation).%New()
        set request.PatientID = episodeVo.PatientID
        set request.mradm = episodeVo.mradm
        set request.EpisodeID = episodeVo.ID
        set request.ObsDate = DateD
        set request.ObsTime = TimeD
        set request.OBSENTRYPatLocDesc = locationCode

        do ..UpdateTableItems(obsItemSet,"VS1", .request)
        do ..UpdateTableItems(obsItemSet,"VS2", .request)
        do ..UpdateTableItems(obsItemSet,"VS3", .request)
        do ..UpdateTableItems(obsItemSet,"VS4", .request)
        do ..UpdateTableItems(obsItemSet,"VS5", .request)
        do ..UpdateTableItems(obsItemSet,"VS6", .request)
        do ..UpdateTableItems(obsItemSet,"HEIGHT", .request)
        do ..UpdateTableItems(obsItemSet,"WEIGHT", .request)

        //save the request object to the list 
        do obsInput.RequestObjList.Insert(request)

    }
}

// Get current date and time and convert them to be in the form used to create observations

ClassMethod GetCurrentDT(Output dateR, Output timeR)
{
    SET dateH=$PIECE($HOROLOG,",",1)
    SET timeH=$PIECE($HOROLOG,",",2)
    set dateR = $zdate(dateH,4)
    set timeR = $ztime(timeH,2)
}

// update date and time with desired interval 

// interval is a integer that has a unit minutes 

ClassMethod UpdateDT(ByRef dateR, ByRef timeR, intervalM As %Integer = 30)
{
    set dateH = $zdh(dateR,4)
    set timeH = $zth(timeR,2)
    set intervalS = intervalM * 60
    set timeH = timeH + intervalS
    if timeH > 86399 {
        set timeH = timeH - 86400
        set dateH = dateH + 1 
    }
    set dateR = $zdate(dateH,4)
    set timeR = $ztime(timeH,2)
}

// increase date by one 

ClassMethod UpdateD(ByRef dateR)
{
    set dateH = $zdh(dateR,4)
    set dateH = dateH+1
    set dateR = $zdate(dateH,4)
}

// update the mradm property of EpisodeVo

ClassMethod UpdateMradm(ByRef episodeVo As CDUI.DataGen.vo.EpisodeVo)
{
    //call the API to get episode by id, name of the property in request has to match API requirement!
    try{
        set request = ##class(CDUI.DataGen.Request.GetEpisodeById2).%New()
        set request.EpisodeId = episodeVo.ID

        set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
		set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
        set json = {}.%FromJSON(response.StringValue)
    }
    catch ex
    {
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
        set obsItem.OBSValue = ""
        //set obsItem.OBSValue = obsItemSet.OS
    }

    Do obsReq.TableItems.Insert(obsItem)
}

Method PrintResult(failedByEpisodeIdArr, totalSuccess, totalFailure)
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

        //test hang
        HANG 10

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
                }
            }
            else{
                $$$LOGERROR("[ObsService.Run] Failed to create an observation. Error(SC): "_$System.Status.DisplayError(sc))
            }
        }
        catch ex {	
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
