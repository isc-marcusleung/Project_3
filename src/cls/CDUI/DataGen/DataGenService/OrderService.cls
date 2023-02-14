Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.OrderService Extends (%RegisteredObject, BaseService)
{

Method NewOrderByRange(MinNumOfOrder As %Integer = 1, MaxNumOfOrder As %Integer = 1, OrderCat As %String, EpisodeVoObjList As %ListOfObjects)
{
    do ..GetOrderByCat("", OrderCat, .orderVoObjList)

    set diff = MaxNumOfOrder - MinNumOfOrder
    set totalSuccess = 0
    set totalFailure = 0
    set failedByEpisodeIdArr = []
    for i=1:1:EpisodeVoObjList.Count(){
        set ranNum = ##class(PUtil).Random(diff) + MinNumOfOrder
        do ..NewOrderPerPatient(ranNum, EpisodeVoObjList.GetAt(i), .orderVoObjList, .numOfSuccess, .numOfFailure)
        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure

        if (numOfFailure > 0) {
            set failedByEpisodeIdArr(EpisodeVoObjList.GetAt(i).ID) = numOfFailure
        }
    }

    do ..PrintResult(failedByEpisodeIdArr, totalSuccess, totalFailure)
}

Method NewOrderPerPatient(NumOfOrderPerEpisode As %Integer = 1, EpisodeItem As CDUI.DataGen.vo.EpisodeVo, ByRef OrderVoObjList As %ListOfObjects, ByRef NumOfSuccess As %Integer, ByRef NumOfFailure As %Integer) [ Private ]
{
    // TO DO CN - Any better way? 
    set EpisodeId = EpisodeItem.ID
    set EpisodeAdmDate = EpisodeItem.PAADMAdmDate
    set EpisodeAdmTime = EpisodeItem.PAADMAdmTime
    set PatientID = EpisodeItem.PatientID

    $$$LOGINFO("[OrderService.NewOrder] Initialize order request, episode Id: "_EpisodeId)

    // Generate order records and insert them to TrakCare via API.
    $$$LOGINFO("[OrderService.NewOrder] Create new order")

    // Run the method to initialise the request body
    do ..InitOrderRequestByRandom(OrderVoObjList, NumOfOrderPerEpisode, EpisodeId, EpisodeAdmDate, EpisodeAdmTime, PatientID, .orderInput,)

    set orderOutput = ##class(CDUI.DataGen.DataGenService.Custom.OrderOutput).%New()

    do ..RunWithRetry(orderInput, orderOutput,)

    // Set the inserted ordersVo back to episodeVo for further use if necessary
    set EpisodeItem.OrderObjList = orderOutput.OrderVoObjList

    set orderIdList = orderOutput.OrderIdList
    set NumOfSuccess = orderIdList.Count()

    set failedByPatientIdArr = []
    set NumOfFailure = NumOfOrderPerEpisode - NumOfSuccess

    if NumOfSuccess '= 0 {
        $$$LOGINFO("[OrderService.NewOrder] Results: patient Id: "_EpisodeItem.PatientID_", episode Id: "_EpisodeId_", orderId: "_##class(CommonUtil).convertListOfDataTypeToString(orderIdList,))
    }

    $$$LOGINFO("[EpisodeService.NewOrder] Success count: "_NumOfSuccess_", Failure count: "_NumOfFailure)
}

Method NewOrder(NumOfOrderPerEpisode As %Integer = 1, OrderCat As %String, EpisodeVoObjList As %ListOfObjects)
{
    set Count = ""
    set OrderCat = OrderCat

    set totalSuccess = 0
    set totalFailure = 0
    
    kill failedByEpisodeIdArr

    do ..GetOrderByCat(Count, OrderCat, .orderVoObjList)
    set NumOfEpisode = EpisodeVoObjList.Count()

    $$$LOGINFO("[OrderService.NewOrder] Number of episodes for this patient: "_NumOfEpisode)
    $$$LOGINFO("[OrderService.NewOrder] Number of requested orders per episode: "_NumOfOrderPerEpisode)  

    // Loop through episodes object
    for i=1:1:NumOfEpisode{
        
        set episodeItem = EpisodeVoObjList.GetAt(i)
        
        do ..NewOrderPerPatient(NumOfOrderPerEpisode, episodeItem, .orderVoObjList, .numOfSuccess, .numOfFailure)
        
        set failedByEpisodeIdArr = []
        set totalSuccess = totalSuccess + numOfSuccess
        set totalFailure = totalFailure + numOfFailure
        set episodeId = episodeItem.ID
        if (numOfFailure > 0) {
            set failedByEpisodeIdArr(episodeId) = numOfFailure
        }
    }
    do ..PrintResult(failedByEpisodeIdArr, totalSuccess, totalFailure)
}

Method GetOrderByCat(Count As %Integer, OrderCat As %String, Output OrderVoObjList As %ListOfObjects) [ Private ]
{
	// Retrieve the order list for the creation of a new order
    $$$LOGINFO("[OrderService.GetOrderByCat] Retrieve the order list.")

    set sc = ##class(TrakCareService).GetOrderByCat(Count, OrderCat, .OrderVoObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[OrderService.GetOrderByCat] Failed to get orders.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}
}

Method PrintResult(failedByEpisodeIdArr, totalSuccess, totalFailure)
{
    set cnt = 0
    set key = $Order(failedByEpisodeIdArr(""))
    while (key '= "") {
        if (cnt = 0) {
            $$$LOGINFO("[OrderService.NewOrder] Failure per episode")
        }
        $$$LOGINFO("Episode Id: "_key_", Number of Failure: "_failedByEpisodeIdArr(key))
        set key = $Order(failedByEpisodeIdArr(key))
        set cnt = cnt + 1
    }

    $$$LOGINFO("[OrderService.NewOrder] Total number of Episode with failed order creation: "_cnt)
	$$$LOGINFO("[OrderService.NewOrder] Total number of Success: "_totalSuccess_", Total number of Failure: "_totalFailure)
}

Method Run(orderInput As CDUI.DataGen.DataGenService.Base.Input, orderOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    kill idxOfRemoveOrderObjListArr
    kill idxOfRemoveOrderIndexListArr

    set requestObjList = orderInput.RequestObjList
    set orderObjList = orderInput.OrderObjList
    set orderIndexList = orderInput.OrderIndexList
    set orderIdList = ##class(%ListOfDataTypes).%New()
    
    set orderVoObjList = orderOutput.OrderVoObjList

    set numOfLoop = requestObjList.Count()
    set numOfFailed = 0

    if '$Data(orderVoObjList) {
		set orderVoObjList =  ##class(%ListOfObjects).%New()
	}

    set failedOrderRequestObjList =  ##class(%ListOfObjects).%New()

    $$$LOGINFO("[OrderService.Run] Number of order requests executing: "_numOfLoop)

    for cnt=1:1:numOfLoop {
        set request = requestObjList.GetAt(cnt)
        $$$LOGINFO("[OrderService.Run] Request: "_request.SerialisedGet())
        set isSuccess = 0
        try {
            // Send the request
            set sc = ##class(Ens.Director).CreateBusinessService("CDUI.DataGen.Service.Adaptorless",.svc)
            set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))

            if $$$ISOK(sc)
            {	
                $$$LOGINFO("[OrderService.Run] Response body: "_response.StringValue)
                set json = {}.%FromJSON(response.StringValue)
                if (json.ERROR = "")
                { 

                    //No error then store the results to OrderVo objects
                    do orderVoObjList.Insert(##class(CDUI.DataGen.vo.OrderVo).newInstance(request,json.ID))
                    do orderIdList.Insert(json.ID)
                    set isSuccess = 1
                } 
                else 
                {
                    $$$LOGERROR("[OrderService.Run] Failed to create an order. Error(Json): "_json.ERROR)
                    
                    // Remove order failures
                    set isMatchAPI = $MATCH(json.ERROR, ".*API Save Failed.*")
                    set isMatchTestSet = $MATCH(json.ERROR, ".*no correct test set associated with the order item.*")

                    if ((isMatchTestSet=1) || (isMatchAPI=1)) 
                    {
                        $$$LOGINFO("[OrderService.Run] Removing order index...")

                        // Check index
                        $$$LOGINFO("[OrderService.Run] Order index to be removed: "_orderIndexList.GetAt(cnt))
                        set idxOfRemoveOrderObjListArr(orderIndexList.GetAt(cnt)) = ""
                        set idxOfRemoveOrderIndexListArr(cnt) = ""
                    } 
                }
            } 
            else 
            {
                $$$LOGERROR("[OrderService.NewOrder] Failed to create an order. Error(SC): "_$System.Status.DisplayError(sc))
            }
        } 
        catch ex 
        {	
            $$$LOGERROR("[OrderService.NewOrder] Failed to create an order. Error(Ex): "_ex.DisplayString())
        }

        if isSuccess '= 1 {
            do failedOrderRequestObjList.Insert(request)
            #; $$$LOGINFO("[OrderService.Run] Request in failedOrderRequestObjList:  "_request.SerialisedGet())
            set numOfFailed = numOfFailed + 1
        }
    }

    if $Order(idxOfRemoveOrderObjListArr("")) {
        do ..RemoveItemsInverseFromList(orderObjList, .idxOfRemoveOrderObjListArr)
    }

    if $Order(idxOfRemoveOrderIndexListArr("")) {
        do ..RemoveItemsInverseFromList(orderIndexList, .idxOfRemoveOrderIndexListArr)
    }

    // Set request with new order item
    for cnt=1:1:failedOrderRequestObjList.Count(){
        do ..AssignOrderItem(orderObjList, failedOrderRequestObjList.GetAt(cnt), .orderIndexList)  
    }

    $$$LOGINFO("[OrderService.Run] Number of orders after executing requests: "_orderIdList.Count()) 

    for cnt=1:1:orderIdList.Count()
    {
		$$$LOGINFO("[OrderService.Run1] Items in orderIdList: "_orderIdList.GetAt(cnt))
	}
     
    // Combine the list or assign a new one  
    // If orderOutput.OrderIdList has values, execute the if {} to insert new order ID into the list via a loop
    if (orderOutput.OrderIdList '= "") {     
		for cnt=1:1:orderIdList.Count(){  
			do orderOutput.OrderIdList.Insert(orderIdList.GetAt(cnt))
		}
	} 

    // if (orderOutput.OrderIdList = "") ie. there is no value in orderOutput.OrderIdList, then set equal to new orderIdlist 
    else { 
        $$$LOGINFO("[OrderService.Run2] Reset: "_orderIdList)
		set orderOutput.OrderIdList = orderIdList
	}
    
    //Reset the input for retry
    set orderInput.RequestObjList = failedOrderRequestObjList
    set orderInput.OrderObjList = orderObjList
    set orderInput.OrderIndexList = orderIndexList


    set orderOutput.NumOfFailed = numOfFailed
	set orderOutput.OrderVoObjList = orderVoObjList

	quit numOfFailed
}

Method RemoveItemsInverseFromList(sourceList, ByRef removalIndexArray) [ Private ]
{
    #; $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] Before removal of item - sourceList Size: "_sourceList.Count())
    
    set key = $Order(removalIndexArray(""), -1) // Inverse order, delete the items in inverse order
    

    while (key '= "") {
        do sourceList.RemoveAt(key)
        set key = $Order(removalIndexArray(key), -1)
        #; $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] Remove index in reverse order: "_key)
    }
    #; $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] After removal of item - sourceList Size: "_sourceList.Count())
}

// Initialise the request for orders

Method InitOrderRequestByRandom(orderObjList As %ListOfObjects, NumOfOrderPerEpisode As %Integer, EpisodeId As %String, EpisodeAdmDate As %String, EpisodeAdmTime As %String, PatientID As %String, Output orderInput As CDUI.DataGen.DataGenService.Custom.OrderInput, Output orderIndexList)
{
    kill orderInput
    set orderInput = ##class(CDUI.DataGen.DataGenService.Custom.OrderInput).%New()
    set orderTmpList = ##class(%ListOfObjects).%New()

    for cnt=1:1:NumOfOrderPerEpisode {

        //Set up Order request
        set request = ##class(CDUI.DataGen.Request.NewOrder).%New()

        // Get a random ordercategory object index 
        set randorderVoObjListListIndex = ($$$PRand(orderObjList.Count()) + 1)

        // Get the ordercategory objects
        set orderCatVo = orderObjList.GetAt(randorderVoObjListListIndex)
        
        set request.Item = orderCatVo.ID

        if ('$Data(orderIndexList)) {
           set orderIndexList = ##class(%ListOfDataTypes).%New()
        }
        do orderIndexList.Insert(randorderVoObjListListIndex)
        
        set request.EpisodeID = EpisodeId

        //orderCatVo (ARCIMEffDate) must < Order (OEORISttDat,OEORISttTim)
        //Episode (PAADMAdmDate,PAADMAdmTime) must < Order (OEORISttDat, OEORISttTim)
        set arcimEffDate = orderCatVo.ARCIMEffDate
        set paadmAdmDate = $zdateh(EpisodeAdmDate,4)
        set minDate = paadmAdmDate
        set isAdmDateAsMinDate = 1

        //Get the larger date as a min date for the generation of the date (OEORISttDat) in Order 
        if arcimEffDate > paadmAdmDate {
            set minDate = arcimEffDate
            set isAdmDateAsMinDate = 0
        }
        $$$LOGINFO("[NewOrder] Check dates: arcimEffDate: "_$zdate(arcimEffDate, 4)_", PAADMAdmDate: "_EpisodeAdmDate_", minDate for order: "_$zdate(minDate, 4))

        set request.OEORISttDat = ##class(PUtil).CustomDate(minDate, $piece($horolog, ",", 1))

        if isAdmDateAsMinDate {
            set request.OEORISttTim = ##class(PUtil).Time(EpisodeAdmTime,,2)
        } else {
            set request.OEORISttTim = ##class(PUtil).Time(,,2)
        }

        // Retrieve the care provider ID list 
        $$$LOGINFO("[NewOrder INIT] Retrieve the careprovider list.")

        set sc = ##class(TrakCareService).GetCareProvider(.cpList)
        if $$$ISERR(sc)
        {
            $$$LOGERROR("[NewOrder INIT] Failed to get care providers.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }

        // Set DoctorID & AuthDoctorID
        set randCPIndex = ##class(PUtil).Random(cpList.Count()) + 1   
	    set request.DoctorID = cpList.GetAt(randCPIndex)
        set request.AuthDoctorID = cpList.GetAt(randCPIndex)

        // Set OECPRDesc, OEORIDepProcNotes
        set request.OECPRDesc = ##class(PUtil).ListElement($listfromstring(##class(Constants).#oecprDesc,","))
        set request.OEORIDepProcNotes = "comments"
        set request.PatientID = PatientID

        do orderTmpList.Insert(request)
    }

    // Output of this method is orderInput
    // Three parameters

    // List of requests
    set orderInput.RequestObjList = orderTmpList

    // List of orders from REST API
    set orderInput.OrderObjList = orderObjList
    set orderInput.OrderIndexList = orderIndexList
}

Method AssignOrderItem(orderObjList As %ListOfObjects, request As CDUI.DataGen.Request.NewOrder, Output orderIndexList)
{
    // If the order list is not empty
    if (orderObjList.Count() > 0)
    {
        // Get new order item
        set randorderVoObjListListIndex = ##class(PUtil).Random(orderObjList.Count()) + 1   
        set orderCatVo = orderObjList.GetAt(randorderVoObjListListIndex)
        set request.Item = orderCatVo.ID
        $$$LOGINFO("[OrderService.AssignOrderItem] New order for new request: "_request.Item)
        do orderIndexList.Insert(randorderVoObjListListIndex)
        #; set $list(orderIndexList, * + 1) = randorderVoObjListListIndex
    }
}

}
