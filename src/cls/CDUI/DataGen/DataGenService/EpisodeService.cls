Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.EpisodeService Extends (%RegisteredObject, BaseService)
{

ClassMethod NewEpisode(NumOfEpisodePerPatient As %Integer = 1, patientVoObjList As %ListOfObjects, ByRef episodeVoObjList As %ListOfObjects)
{
	set locationTypeId = "E" // TODO Marcus make it constant / enum
    set visitStatus = ""
	set minAdmDate = "1/1/1970"
	set episodeVoObjList = ##class(%ListOfObjects).%New()

	//Retrieve the location list for the creation of a new episode
	$$$LOGINFO("[EpisodeService.NewEpisode] Retrive the location list.")
    set sc = ##class(TrakCareService).GetLocation(,1,locationTypeId,..#DefaultPageSize,, .locationObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[EpisodeService.NewEpisode] Failed to get Locations.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    $$$LOGINFO("[EpisodeService.NewEpisode] Number of patient: "_patientVoObjList.Count())
    $$$LOGINFO("[EpisodeService.NewEpisode] Number of episode per patient: "_NumOfEpisodePerPatient)

    set numOfLoop = patientVoObjList.Count()
    #; for cnt = 1:1:numOfLoop 
    #; {	
    #;     try 
    #;     {
    #;         #; //Set up episode request
    #;         #; set request = ##class(CDUI.DataGen.Request.NewEpisode).%New()
    #;         #; set randPatientIdListIndex = $$$PRand($listlength(patientIdList))+1
    #;         #; set request.PatientID = $list(patientIdList,randPatientIdListIndex)
    #;         #; set request.PAADMType = $piece(admType, ",",$$$PRand(2)+1)
    #;         #; set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1))
    #;         #; set request.PAADMAdmTime = ##class(PUtil).Time(,,2)
    #;         #; if (locationObjList.Count() > 0){
    #;         #;     set randLocationIndex = ##class(PUtil).Random(locationObjList.Count()) + 1
    #;         #;     set location = locationObjList.GetAt(randLocationIndex)
    #;         #;     set request.CTLOCDesc = location.CTLOCDesc
    #;         #; }
    #;         //init episode requests for a patient
            


    #;         $$$LOGINFO("[EpisodeService.NewEpisode] Request: "_request.SerialisedGet())

    #;         //Send the request
    #;         set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
    #;         set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

    #;         if $$$ISOK(sc)
    #;         {	
    #;             $$$LOGINFO("[EpisodeService.NewEpisode] Response body: "_response.StringValue)
    #;             set json = {}.%FromJSON(response.StringValue)
    #;             if (json.ERROR = ""){ 
    #;                 //No error then store the record to episodeVoObjList
    #;                 do episodeVoObjList.Insert(##class(CDUI.DataGen.vo.EpisodeVo).newInstance(request,json.ID)) 
    #;                 //For the printout purpose in the bottom
    #;                 set $list(episodeIdList, * + 1) = json.ID
    #;                 //remove the used patient id from the patientIdList if it is used for the creation of episode successfully
    #;                 set patientIdList = $List(patientIdList,1,randPatientIdListIndex-1)_$list(patientIdList,randPatientIdListIndex+1,$LISTLENGTH(patientIdList))
    #;             } else 
    #;             {
    #;                 $$$LOGERROR("[EpisodeService.NewEpisode] Failed to create an episode. Error(Json): "_json.ERROR)
    #;                 // if it matches, remove the invalid insurance record from the list.
    #;                 set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^CTLOCDesc.*")
    #;                 if isMatch {
    #;                     do locationObjList.RemoveAt(randLocationIndex)
    #;                 }
    #;                 set numOfFailed = numOfFailed + 1
    #;             }
    #;         } else {
    #;                 $$$LOGERROR("[EpisodeService.NewEpisode] Failed to create an episode. Error(SC): "_$System.Status.DisplayError(sc))
    #;                 set numOfFailed = numOfFailed + 1
    #;         }
    #;     } catch ex 
    #;     {	
    #;             $$$LOGERROR("[EpisodeService.NewEpisode] Failed to create an episode. Error(Ex): "_ex.DisplayString())
    #;             set numOfFailed = numOfFailed + 1
    #;     } 

	#; 	$$$LOGINFO("[EpisodeService.NewEpisode] Number of failure: "_numOfFailed)
	#; 	set numOfLoop = numOfFailed
	#; 	set trialCnt = trialCnt + 1
	#; }
		
	set resultSize = $listlength(episodeIdList)
	$$$LOGINFO("[EpisodeService.NewEpisode] episodeIdList: "_$LISTTOSTRING(episodeIdList))
	$$$LOGINFO("[EpisodeService.NewEpisode] Success count: "_resultSize_", Failure count: "_(NumOfEpisode - resultSize))
}

Method Run(patientInput As CDUI.DataGen.DataGenService.Base.Input, patientOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
}

Method InitEpisodeRequestPerPatientByRandom(minAdmDate As %String, locationObjList As %ListOfObjects, numOfEpisodePerPatient As %Integer, patientId As %String, patientVo As CDUI.DataGen.vo.PatientVo, ByRef EpisodeInput As CDUI.DataGen.DataGenService.Custom.EpisodeInput)
{
    kill EpisodeInput
    set EpisodeInput = ##class(CDUI.DataGen.DataGenService.Custom.EpisodeInput).%New()
    set admTypeList = $LISTBUILD(##class(Constants).#admTypeCode)
    set visitStatusList = $LISTBUILD(##class(Constants).#visitStatusCode)
   /*
    	1. Only 1 current in-patient episode (Patient type = I and VisitStatus = A)
        2. If there is current in-patient , then no more inpatient after that
        3. If visit status = Discharge > set PAADMDischgDate and PAADMDischgTime
    */
    for cnt=1:1:numOfEpisodePerPatient{
        set request = ##class(CDUI.DataGen.Request.NewEpisode).%New()

        set request.PAADMType = $List(admTypeList, $$$PRand($listlength(admTypeList))+1)
        set request.PAADMVisitStatus = $List(visitStatusList, $$$PRand($listlength(visitStatusList))+1)
        
        set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1))
        set request.PAADMAdmTime = ##class(PUtil).Time(,,2)

        // Only 1 current in-patient episode (Patient type = I and VisitStatus = A), Remove the in-patient in the admTypeList
        if (request.PAADMType = "I" &&  request.PAADMVisitStatus = "A") {
            set idx =  $listfind(admTypeList, "I")
            set admTypeList=$List(admTypeList,1,idx-1)_$list(admTypeList,idx+1, $listlength(admTypeList))
        }

        //TODO Marcus check if discharge should only be applied to in-patient
        if (request.PAADMVisitStatus = "D"){
            //PAADMDischgDate should be after PAADMAdmDate
            set request.PAADMAdmDate = ##class(PUtil).CustomDate($zdateh(minAdmDate), $piece($horolog, ",", 1) - 2)
            set request.PAADMDischgDate = ##class(PUtil).CustomDate($zdateh(request.PAADMAdmDate + 1), $piece($horolog, ",", 1))
            set request.PAADMDischgTime = ##class(PUtil).Time(,,2)
        }

        if (locationObjList.Count() > 0){
                set randLocationIndex = ##class(PUtil).Random(locationObjList.Count()) + 1
                set location = locationObjList.GetAt(randLocationIndex)
                set request.CTLOCDesc = location.CTLOCDesc
        }
    }
}

Method GetPatientIdList(patientVoObjList As %ListOfObjects, ByRef patientIdList As %List)
{
    kill patientIdList

    for cnt=1:1:patientVoObjList.Count(){
        set $list(patientIdList, * + 1) = patientVoObjList.GetAt(cnt).PatientId
    }
}

}
