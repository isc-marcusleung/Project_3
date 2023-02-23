Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base, CDUI.DataGen.DataGenService, CDUI.DataGen.DataGenService.Cache)

Class CDUI.DataGen.DataGenService.PatientService Extends BaseService
{

Method NewPatient(NumOfPatient As %Integer = 1, jobId As %Integer, Output patientVoObjList)
{
	// generate patient records and insert them to TrakCare via API.
	$$$LOGINFO("[PatientService.NewPatient] Create new patients.")
	set patientInput = ##class(CDUI.DataGen.DataGenService.Custom.PatientInput).%New()
	set patientOutput = ##class(CDUI.DataGen.DataGenService.Custom.PatientOutput).%New()

	set patientInput.NumOfPatient = NumOfPatient

	//pass jobId to patientInput object 
	set patientInput.jobId = jobId

	do ..RunWithRetry(patientInput, patientOutput,)
	
	set patientIdList = patientOutput.PatientIdList
	set resultSize = patientIdList.Count()
	set patientVoObjList = patientOutput.PatientVoObjList
	
	$$$LOGINFO("[PatientService.NewPatient] patientIdList: "_##class(CommonUtil).convertListOfDataTypeToString(patientIdList,))
	$$$LOGINFO("[PatientService.NewPatient] Success count: "_resultSize_", Failure count: "_(NumOfPatient - resultSize))
}

Method Run(patientInput As CDUI.DataGen.DataGenService.Base.Input, patientOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
	set numOfLoop = patientInput.NumOfPatient
	set jobId = patientInput.jobId
	set patientVoObjList = patientOutput.PatientVoObjList
	set patientIdList = ##class(%ListOfDataTypes).%New()

	if '$Data(patientVoObjList) {
		set patientVoObjList =  ##class(%ListOfObjects).%New()
	}

	$$$LOGINFO("[PatientService.Run] Number of patient to be created: "_numOfLoop)
	set numOfFailed = 0
	for cnt = 1:1:numOfLoop 
	{	
		try 
		{
			$$$LOGINFO("[PatientService.Run] Initialize patient request")
			do ..InitPatientRequestByRandom(jobId, .request,.randInsurTypeIndex)
			
			//TODO Marcus add PAPMIMedicare

			$$$LOGINFO("[PatientService.Run] Request body: "_request.SerialisedGet())
			
			//Send the request
			set sc = ..SendRequest(request,.response)
			if $$$ISOK(sc)
			{
				$$$LOGINFO("[PatientService.Run] Response body: "_response.StringValue)
				$$$LOGINFO("[PatientService.Run] Response Time in ms: "_response.ResponseTime)
				
				set json = {}.%FromJSON(response.StringValue)
				if (json.ERROR = ""){
					//No error then create an patientVo
					do patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,json.ID)) 
					do patientIdList.Insert(json.ID)

				} else {
					$$$LOGERROR("[PatientService.Run] Failed to create a patient. Error(JSON): "_json.ERROR)
					// if it matches, remove the invalid insurance record from the list
					set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^(INSTDesc|AUXITDesc).*") 
					if isMatch {
						do ##class(ARCAuxilInsurTypeService).RemoveItem(randInsurTypeIndex)
					}
					set numOfFailed = numOfFailed + 1
				}
			} else {
				$$$LOGERROR("[PatientService.Run] Failed to create a patient. Error(SC): "_$System.Status.DisplayError(sc))
				set isMatch =  $MATCH($System.Status.GetErrorCodes(sc), "7201")
				if isMatch {
					do ##class(ARCAuxilInsurTypeService).RemoveItem(randInsurTypeIndex)
				}
				set numOfFailed = numOfFailed + 1
			}
		} 
		catch ex 
		{	
			$$$LOGERROR("[PatientService.Run] Failed to create a patient. Error(Ex): "_ex.DisplayString())
			set numOfFailed = numOfFailed + 1
		} 
	}
	set patientOutput.NumOfFailed = numOfFailed
	set patientOutput.PatientVoObjList = patientVoObjList

	//combine the list or assign a new one
	if patientOutput.PatientIdList '= "" {	
		for cnt=1:1:patientIdList.Count(){
			do patientOutput.PatientIdList.Insert(patientIdList.GetAt(cnt))
		}
		//set patientOutput.PatientIdList = $List(patientOutput.PatientIdList,1,$LISTLENGTH(patientOutput.PatientIdList))_$list(patientIdList,1,$LISTLENGTH(patientIdList))
	} else { 
		set patientOutput.PatientIdList = patientIdList
	}

	//reset the NumOfPatient for next retry
	set patientInput.NumOfPatient = numOfFailed

	quit numOfFailed
}

Method InitPatientRequestByRandom(jobId As %Integer, ByRef request As CDUI.DataGen.Request.NewPatient, Output randInsurTypeIndex As %Integer) [ Private ]
{
    kill request
    kill randInsurTypeIndex

    // Set up patient creation request
	set request =  ##class(CDUI.DataGen.Request.NewPatient).%New()
    // Set last name
    set request.PAPERName = ##class(PUtil).LastName()

    // set first name
    set request.PAPERName2 = ##class(PUtil).FirstName()
    set request.CTSEXDesc = ##class(PUtil).ListElement($listfromstring(##class(Constants).#genders,","))
    // min date = current date - maxAge, max date is current date
    set currentDateInt = $piece($horolog, ",", 1)
    set minDateInt = currentDateInt - (##class(Constants).#maxAge * 365)
    set request.PAPERDob = ##class(PUtil).CustomDate(minDateInt, currentDateInt) 

	// Randomly select the location record 
 	do ##class(ARCAuxilInsurTypeService).GetInsurTypeByRandom(.jsonStr, .randInsurTypeIndex)
    if randInsurTypeIndex '= 0 {
		set dynamicObj = ##class(%DynamicAbstractObject).%FromJSON(jsonStr)
		set request.INSTDesc = dynamicObj.AUXITInsTypeDR
		set request.AUXITDesc = dynamicObj.AUXITDesc
	}

	// set jobId
	set request.jobId = jobId
}

}
