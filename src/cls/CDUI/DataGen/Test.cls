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

ClassMethod ListARCAuxilInsurTypes(PageSize As %Integer = 100, ByRef Page As %Integer = "")
{
	set sc = ..GetARCAuxilInsurType(PageSize,Page,.results)
	set i = ""
	set size = results.Count()
		for cnt=1:1:size{
			zw results.GetAt(cnt)
		}
}

ClassMethod mCreatePatient(NumOfPatient As %Integer = 1, jobId As %Integer, ByRef PatientVoObjList)
{
	w !,$$$CurrentClass
	w !,$$$CurrentMethod
	kill PatientVoObjList
	set patientService = ##class(CDUI.DataGen.DataGenService.PatientService).%New()
	do patientService.NewPatient(NumOfPatient, jobId, .PatientVoObjList)
	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] Patient Id ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).PatientId)
	}
	$$$LOGINFO("================================ [End] Patient Id ================================")
}

ClassMethod mCreateEpisode(NumOfEpisodePerPatient As %Integer = 1, PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()
	do episodeService.NewEpisode(NumOfEpisodePerPatient, PatientVoObjList, jobId)
	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateEpisodeByRange(MinNumOfEpisode As %Integer = 1, MaxNumOfEpisode As %Integer = 1, PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set episodeService = ##class(CDUI.DataGen.DataGenService.EpisodeService).%New()

	do episodeService.NewEpisodeByRange(MinNumOfEpisode, MaxNumOfEpisode, PatientVoObjList, jobId)

	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateOrder(NumOfOrderPerEpisode As %Integer = 1, OrderCat As %String, ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
	set OrderCat = OrderCat
	for i=1:1:PatientVoObjList.Count(){
		do orderService.NewOrder(NumOfOrderPerEpisode, OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList, jobId)
	}

	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateOrderByRange(MinNumOfOrder As %Integer = 1, MaxNumOfOrder As %Integer = 1, OrderCat As %String, ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set orderService = ##class(CDUI.DataGen.DataGenService.OrderService).%New()
	set OrderCat = OrderCat
	for i=1:1:PatientVoObjList.Count(){
		do orderService.NewOrderByRange(MinNumOfOrder, MaxNumOfOrder, OrderCat, PatientVoObjList.GetAt(i).EpisodeObjList, jobId)
	}
	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod CreateAppointment(NumOfApptPerPatient As %Integer = 1, ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()

	do apptService.NewAppt(NumOfApptPerPatient, PatientVoObjList, jobId)
	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateAppointmentByRange(MinNumOfAppt As %Integer = 1, MaxNumOfAppt As %Integer = 1, PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set apptService = ##class(CDUI.DataGen.DataGenService.ApptService).%New()

	do apptService.NewApptByRange(MinNumOfAppt, MaxNumOfAppt, PatientVoObjList, jobId)

	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateObs(NumOfObsPerEpisode As %Integer = 1, ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
    set obsService = ##class(CDUI.DataGen.DataGenService.ObsService).%New()
	for i=1:1:PatientVoObjList.Count(){
		do obsService.NewObs(NumOfObsPerEpisode, PatientVoObjList.GetAt(i).EpisodeObjList, jobId)
	}
    
	w !!!!
    for cnt = 1:1:PatientVoObjList.Count(){
        if (cnt = 1){
            $$$LOGINFO("================================ [Start] ================================")
        }
        $$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
    }
    $$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateObsByRange(MinNumOfObs As %Integer = 1, MaxNumOfObs As %Integer = 1, ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
    set obsService = ##class(CDUI.DataGen.DataGenService.ObsService).%New()
	for i=1:1:PatientVoObjList.Count(){
		set EpisodeVoObjList = PatientVoObjList.GetAt(i).EpisodeObjList
		do obsService.NewObsByRange(MinNumOfObs, MaxNumOfObs, EpisodeVoObjList, jobId)
	}
	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

ClassMethod mCreateRadResult(ByRef PatientVoObjList As %ListOfObjects, jobId As %Integer)
{
	set resultService = ##class(CDUI.DataGen.DataGenService.RadResultService).%New()

	for i=1:1:PatientVoObjList.Count(){
		set patientId = PatientVoObjList.GetAt(i).PatientId
		set EpisodeVoObjList = PatientVoObjList.GetAt(i).EpisodeObjList

		do resultService.NewRadResult(patientId, EpisodeVoObjList, jobId)
		
	}

	w !!!!
	for cnt = 1:1:PatientVoObjList.Count(){
		if (cnt = 1) {
			$$$LOGINFO("================================ [Start] ================================")
		}
		$$$LOGINFO(PatientVoObjList.GetAt(cnt).SerialisedGet())
	}
	$$$LOGINFO("================================ [End] ================================")
}

}
