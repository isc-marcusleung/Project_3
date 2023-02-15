Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.Enum)

Class CDUI.DataGen.DataGenService.ObsService Extends BaseService
{

// Assuming there is already a EpisodeVoObjList created 

Method NewObs(NumOfObsPerEpisode As %Integer = 1, EpisodeVoObjList As %ListOfObjects, Output ObsVoObjList As %ListOfObjects)
{
    set locationTypeId = "E"
    
    //Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[ObsService.NewObs] Retrive the location list.")
    set sc = ##class(TrakCareService).GetLocation(,1,locationTypeId,..PageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[ObsService.NewObs] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    $$$LOGINFO("[ObsService.NewObs] Number of episode: "_EpisodeVoObjList.Count())
    $$$LOGINFO("[ObsService.NewObs] Number of obserations per episode: "_NumOfObsPerEpisode)
	
    //Initialize the log file
	do ##class(CDUI.DataGen.ExportLog).LogJob(,"Observation Creation")

    set numOfLoop = EpisodeVoObjList.Count()
    for cnt = 1:1:numOfLoop{
        set episodeVo = EpisodeVoObjList.GetAt(cnt)
        $$$LOGINFO("[ObsService.NewObs] Initialize observation request, episode Id: "_episodeVo.ID)
        $$$LOGINFO("[ObsService.NewObs] Initialize observation request, episode location desc: "_episodeVo.CTLOCDesc)

        //One to many mapping, for each episode, create multiple observation creation requests and store them in obsInput
        do ..InitObsRequest(locationObjList, NumOfObsPerEpisode, episodeVo,.obsInput)

        set obsOutput = ##class(CDUI.DataGen.DataGenService.Custom.ObsOutput).%New()

        //Do business service call using obsInput, save response in obsOutput
        do ..RunWithRetry(obsInput, obsOutput,)
        set ObsVoObjList = obsOutput.ObsVoObjList
    }
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
    //call the API to get episode by id 
    try{
        set request = ##class(CDUI.DataGen.Request.GetEpisodeById).%New()
        set request.EpisodeIDs = episodeVo.ID

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

// core component of runWithRety, do various business service calls using the list of requests 

Method Run(obsInput As CDUI.DataGen.DataGenService.Base.Input, obsOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    //obtain request objects 
    set requestObjList = obsInput.RequestObjList
    set numOfLoop = requestObjList.Count()
    $$$LOGINFO("[ObsService.Run] Number of requests: "_numOfLoop)

    //obtain generated vo objects
    set obsVoObjList = obsOutput.ObsVoObjList

    //initialize lists to store responses
    set obsIdList = ##class(%ListOfDataTypes).%New()
    if '$Data(obsVoObjList) {
		set obsVoObjList =  ##class(%ListOfObjects).%New()
	}

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
        
        if isSuccess '= 1{
            do failedObsRequestObjList.Insert(request)
            set numOfFailed = numOfFailed + 1
        }
    }

    //combine the id list if this run is a retry run
    //assign a new list if this run is not a retry run
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

    set obsOutput.ObsVoObjList = obsVoObjList

    $$$LOGINFO("[ObsService.Run] Number of failed trails is "_numOfFailed)
    quit numOfFailed
}

}
