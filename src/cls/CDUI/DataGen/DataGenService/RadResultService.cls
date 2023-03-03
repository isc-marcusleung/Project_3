Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.RadResultService Extends (%RegisteredObject, BaseService)
{

Method NewRadResultPerOrder(PatientID As %String, OrderItem As CDUI.DataGen.vo.OrderVo, jobId As %Integer, ByRef ResultVoObjList As %ListOfObjects, ByRef NumOfSuccess As %Integer) [ Private ]
{
    set NumOfResultPerOrder = 1
    
    set EpisodeId = OrderItem.EpisodeID
    set OrderId = OrderItem.ID

    $$$LOGINFO("[RadResultService.NewResult] Initialize result request, patientId: "_PatientID_", episode Id: "_EpisodeId_", order Id: "_OrderId)
    $$$LOGINFO("[RadResultService.NewResult] Create new result...")

    // Run the method to initialise the request body
    do ..InitResultRequestByRandom(OrderItem, PatientID, jobId, .resultInput)

    set resultOutput = ##class(CDUI.DataGen.DataGenService.Custom.RadResultOutput).%New()

    do ..RunWithRetry(resultInput, resultOutput,)

    // Set the inserted resultVo back to orderVo for further use if necessary
    set OrderItem.RadResultList = resultOutput.ResultVoObjList

    set resultId = resultOutput.ResultId

    // If resultId is defined and has data, set NumOfSuccess = 1
    if $Data(resultId) = 1 {
        set NumOfSuccess = 1
    }
    set NumOfFailure = NumOfResultPerOrder - NumOfSuccess

    if NumOfSuccess '= 0 {
        $$$LOGINFO("[RadResultService.NewResult] Results: patient Id: "_PatientID_", episode Id: "_EpisodeId_", order Id: "_OrderId_", result Id: "_resultId)
    }

    $$$LOGINFO("[RadResultService.NewResult] order Id: "_OrderId_" - Success count: "_NumOfSuccess_", Failure count: "_NumOfFailure)
}

Method NewRadResult(PatientID As %String, EpisodeVoObjList As %ListOfObjects, jobId As %Integer, Output failedByOrderIdArr)
{
    set NumOfResultPerOrder = 1
    
    set totalSuccess = 0
    set totalFailure = 0
    
    kill failedByOrderIdArr

    set NumOfEpisode = EpisodeVoObjList.Count()
    set NumOfOrdersAllEpisodes = 0

    $$$LOGINFO("[RadResultService.NewResult] Patient Id: "_PatientID_", Number of episodes: "_NumOfEpisode)

    // Loop through episodes objects to get OrderVoObjList
    for k=1:1:EpisodeVoObjList.Count(){
        set episodeId = EpisodeVoObjList.GetAt(k).ID
        set OrderVoObjList = EpisodeVoObjList.GetAt(k).OrderObjList
        set NumOfOrder = OrderVoObjList.Count()

        $$$LOGINFO("[RadResultService.NewResult] Episode Id: "_episodeId_", Number of orders: "_NumOfOrder)
        
        set NumOfOrdersAllEpisodes = NumOfOrdersAllEpisodes + NumOfOrder
        
        // Loop through orders object
        for i=1:1:NumOfOrder{
            
            set orderItem = OrderVoObjList.GetAt(i)
            
            do ..NewRadResultPerOrder(PatientID, orderItem, jobId, .resultVoObjList, .numOfSuccess)
            
            set numOfFailure = NumOfResultPerOrder - numOfSuccess
            set totalSuccess = totalSuccess + numOfSuccess
            $$$LOGINFO("[RadResultService.NewResult] Check totalSuccess: "_totalSuccess)
            set totalFailure = totalFailure + numOfFailure
            set orderId = orderItem.ID
            if (numOfFailure > 0) {
                set failedByEpisodeIdArr(orderId) = numOfFailure
            }
            
        }
    }
    do ..PrintResult(.failedByOrderIdArr, totalSuccess, totalFailure)
    // NumOfOrdersAllEpisodes should be the same with totalSuccess in ..PrintResult() as each order has 1 result
    $$$LOGINFO("[RadResultService.NewResult] Number of orders of all episodes for Patient Id: "_PatientID_" is: "_NumOfOrdersAllEpisodes)
}

Method PrintResult(ByRef failedByOrderIdArr, totalSuccess As %Integer, totalFailure As %Integer) [ Private ]
{
    set cnt = 0
    set key = $Order(failedByOrderIdArr(""))
    while (key '= "") {
        if (cnt = 0) {
            $$$LOGINFO("[RadResultService.NewResult] Failure per Order")
        }
        $$$LOGINFO("Order Id: "_key_", Number of Failure: "_failedByOrderIdArr(key))
        set key = $Order(failedByOrderIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[RadResultService.NewResult] Total number of Order with failed result creation: "_cnt)
	$$$LOGINFO("[RadResultService.NewResult] All orders - Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method Run(resultInput As CDUI.DataGen.DataGenService.Base.Input, resultOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{

    set requestObjList = resultInput.RequestObjList 
    
    set resultVoObjList = resultOutput.ResultVoObjList

    set numOfFailed = 0

    if '$Data(resultVoObjList) {
		set resultVoObjList =  ##class(%ListOfObjects).%New()
	}

    set failedResultRequestObjList =  ##class(%ListOfObjects).%New()

    // Get the request
    set request = requestObjList.GetAt(1)

    $$$LOGINFO("[RadResultService.Run] Request: "_request.SerialisedGet())
    set isSuccess = 0
    try {
        // Send the request
        set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
        set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

        if $$$ISOK(sc)
        {	
            $$$LOGINFO("[RadResultService.Run] Response body: "_response.StringValue)
            set json = {}.%FromJSON(response.StringValue)
            if (json.ERROR = "")
            { 
                //No error then store the results to ResultVo objects
                do resultVoObjList.Insert(##class(CDUI.DataGen.vo.RadResultVo).newInstance(request,json.ID))
                set resultId = json.ID
                set isSuccess = 1
            } 
            else 
            {
                $$$LOGERROR("[RadResultService.Run] Failed to create a result. Error(Json): "_json.ERROR)
            }
        } 
        else 
        {
            $$$LOGERROR("[RadResultService.Run] Failed to create a result. Error(SC): "_$System.Status.DisplayError(sc))
        }
    } 
    catch ex 
    {	
        do LOG^%ETN
        $$$LOGERROR("[RadResultService.Run] Failed to create a result. Error(Ex): "_ex.DisplayString())
    }

    if isSuccess '= 1 {
        do failedResultRequestObjList.Insert(request)
        set numOfFailed = numOfFailed + 1
    }
    
    set resultOutput.ResultId = resultId

    //Reset the input for retry
    set resultInput.RequestObjList = failedResultRequestObjList

    set resultOutput.NumOfFailed = numOfFailed
	set resultOutput.ResultVoObjList = resultVoObjList

	quit numOfFailed
}

Method InitResultRequestByRandom(OrderItem As CDUI.DataGen.vo.OrderVo, PatientID As %String, jobId As %Integer, Output resultInput As CDUI.DataGen.DataGenService.Custom.RadResultInput)
{
    kill resultInput
    set resultInput = ##class(CDUI.DataGen.DataGenService.Custom.RadResultInput).%New()
    
    // Only one result request at one time
    set resultTmpList = ##class(%ListOfObjects).%New()

    //Set up Result request
    set request = ##class(CDUI.DataGen.Request.NewRadResult).%New()
    set request.jobId = jobId

    // Set up the parameters
    set request.EpisodeID = OrderItem.EpisodeID
    set request.OEOrdItemID = OrderItem.ID
    set request.PatientID = PatientID

    set orderDate = OrderItem.OEORISttDat
    
    // Set date reported later than order's date and earlier than current date
    set minDate = orderDate
    set request.DateReported = ##class(PUtil).CustomDate($zdateh(minDate,4), $piece($horolog, ",", 1))

    $$$LOGINFO("[RadResultService.Init] Check dates: orderDate: "_orderDate_", Result's date reported: "_request.DateReported)

    set request.PlainText = "text result sample from the api on "_request.DateReported

    do resultTmpList.Insert(request)

    // Output of this method is resultInput
    set resultInput.RequestObjList = resultTmpList
}

}
