Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.PatientService Extends (%RegisteredObject, BaseService)
{

Method NewPatient(NumOfPatient As %Integer = 1, ByRef patientVoObjList)
{
	//Retrieve the ARCAuxilInsurType list for the creation of patient
	$$$LOGINFO("[PatientService.NewPatient] Retrive the insurance list.")
	set sc = ##class(TrakCareService).GetARCAuxilInsurType(1, ..#DefaultPageSize,,.insurTypeObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[PatientService.NewPatient] Failed to get ARCAuxilInsurTypes.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}
	// generate patient records and insert them to TrakCare via API.
	$$$LOGINFO("[PatientService.NewPatient] Create new patients.")
	set patientInput = ##class(CDUI.DataGen.DataGenService.Custom.PatientInput).%New()
	set patientOutput = ##class(CDUI.DataGen.DataGenService.Custom.PatientOutput).%New()

	set patientInput.NumOfPatient = NumOfPatient
	set patientInput.InsurTypeObjList = insurTypeObjList

	do ..RunWithRetry(patientInput, patientOutput)
	
	set patientIdList = patientOutput.PatientIdList
	set resultSize = $LISTLENGTH(patientIdList)
	set patientVoObjList = patientOutput.PatientVoObjList
	$$$LOGINFO("[PatientService.NewPatient] patientIdList: "_$LISTTOSTRING(patientIdList))
	$$$LOGINFO("[PatientService.NewPatient] Success count: "_resultSize_", Failure count: "_(NumOfPatient - resultSize))
}

Method Run(patientInput As CDUI.DataGen.DataGenService.Base.Input, patientOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
	set numOfLoop = patientInput.NumOfPatient
	set insurTypeObjList = patientInput.InsurTypeObjList
	set patientVoObjList = patientOutput.PatientVoObjList
	
	if '$ISOBJECT(patientVoObjList) {
		set patientVoObjList =  ##class(%ListOfObjects).%New()
	}

	$$$LOGINFO("[PatientService.Run] Number of patient to be created: "_numOfLoop)
	set numOfFailed = 0
	for cnt = 1:1:numOfLoop 
	{	
		try 
		{
			do ..InitPatientRequestByRandom(insurTypeObjList,.request,.randInsurTypeIndex)
			//TODO Marcus add PAPMIMedicare

			$$$LOGINFO("[PatientService.Run] Request body: "_request.SerialisedGet())
			
			//Send the request
			set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
			set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
			if $$$ISOK(sc)
			{
				$$$LOGINFO("[PatientService.Run] Response body: "_response.StringValue)
				set json = {}.%FromJSON(response.StringValue)
				if (json.ERROR = ""){
					//No error then create an patientVo
					do patientVoObjList.Insert(##class(CDUI.DataGen.vo.PatientVo).newInstance(request,json.ID)) 
					set $list(patientIdList, * + 1) = json.ID
				} else {
					$$$LOGERROR("[PatientService.Run] Failed to create a patient. Error(JSON): "_json.ERROR)
					// if it matches, remove the invalid insurance record from the list
					set isMatch = $MATCH(json.ERROR, ".*does not have a valid entry\^(INSTDesc|AUXITDesc).*")
					if isMatch {
						do insurTypeObjList.RemoveAt(randInsurTypeIndex)
					}
					set numOfFailed = numOfFailed + 1
				}
			} else {
				$$$LOGERROR("[PatientService.Run] Failed to create a patient. Error(SC): "_$System.Status.DisplayError(sc))
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
	if patientOutput.PatientIdList '= ""
	{
		set patientOutput.PatientIdList = $List(patientOutput.PatientIdList,1,$LISTLENGTH(patientOutput.PatientIdList))_$list(patientIdList,1,$LISTLENGTH(patientIdList))
	} else {
		set patientOutput.PatientIdList = patientIdList
	}

	//reset the NumOfPatient for next retry
	set patientInput.NumOfPatient = numOfFailed

	quit numOfFailed
}

Method InitPatientRequestByRandom(insurTypeObjList As %ListOfObjects, ByRef request As CDUI.DataGen.Request.NewPatient, ByRef randInsurTypeIndex As %Integer)
{
    kill request
    kill randInsurTypeIndex

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
    if $ISOBJECT(insurTypeObjList) && (insurTypeObjList.Count() > 0){
        set randInsurTypeIndex = ##class(PUtil).Random(insurTypeObjList.Count()) + 1
        set insurType = insurTypeObjList.GetAt(randInsurTypeIndex)
        set request.INSTDesc = insurType.AUXITInsTypeDR
        set request.AUXITDesc = insurType.AUXITDesc
    }
}

}
