Import (CDUI.DataGen.Utils, CDUI.DataGen.Common, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.DataGenService.OrderService Extends (%RegisteredObject, BaseService)
{

Method NewOrder(NumOfOrderPerEpisode As %Integer = 1, OrderCat As %String, PatientVoObjList As %ListOfObjects)
{
	
    set Count = ""
    set OrderCat = OrderCat

    set totalSuccess = 0
    set totalFailure = 0
    
    kill failedByEpisodeIdArr

	// Retrieve the order list for the creation of a new order
    $$$LOGINFO("[OrderService.NewOrder] Retrieve the order list.")

    // TO DO CN to update to TrakCare service here
    set sc = ##class(CDUI.DataGen.Test).GetOrderByCat(Count, OrderCat, .orderVoObjList)
	if $$$ISERR(sc)
	{
		$$$LOGERROR("[OrderService.NewOrder] Failed to get orders.")
		Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
	}

    $$$LOGINFO("[OrderService.NewOrder] Number of patients in this list: "_PatientVoObjList.Count())
    
    set numOfLoop = PatientVoObjList.Count()

    for cnt=1:1:numOfLoop{

        set patientVo = PatientVoObjList.GetAt(cnt)
        set NumOfEpisode = PatientVoObjList.GetAt(cnt)."EpisodeObjList".Count()
        $$$LOGINFO("[OrderService.NewOrder] Number of episodes for this patient: "_NumOfEpisode)
        $$$LOGINFO("[OrderService.NewOrder] Number of orders per episode: "_NumOfOrderPerEpisode)   
        $$$LOGINFO("[OrderService.NewOrder] Initialize order request, patient Id: "_patientVo.PatientId)

        // Get episodes objects for this patient
        set episodeVo = patientVo.EpisodeObjList

        // Loop through episodes object
        for i=1:1:NumOfEpisode{
            set episodeItem = episodeVo.GetAt(i)

            // TO DO CN - Any better way? 
			set EpisodeId = episodeItem.ID
            set EpisodeAdmDate = episodeItem.PAADMAdmDate
            set EpisodeAdmTime = episodeItem.PAADMAdmTime
            $$$LOGINFO("[OrderService.NewOrder] Initialize order request, episode Id: "_EpisodeId)

            // Generate order records and insert them to TrakCare via API.
            $$$LOGINFO("[OrderService.NewOrder] Create new order")

            // Run the method to initialise the request body
            do ..InitOrderRequestByRandom(orderVoObjList, NumOfOrderPerEpisode, EpisodeId, EpisodeAdmDate, EpisodeAdmTime, .orderInput)

            set orderOutput = ##class(CDUI.DataGen.DataGenService.Custom.OrderOutput).%New()

            do ..RunWithRetry(orderInput, orderOutput,)

            // Set the inserted ordersVo back to episodeVo for further use if necessary
            set episodeItem.OrderObjList = orderOutput.OrderVoObjList

            set orderIdList = orderOutput.OrderIdList
            set numOfSuccess = orderIdList.Count()

            $$$LOGINFO("[OrderService.NewOrder] Number of successful orders: "_numOfSuccess)
            
            set numOfFailure = NumOfOrderPerEpisode - numOfSuccess

            set totalSuccess = totalSuccess + numOfSuccess
            set totalFailure = totalFailure + numOfFailure

            if (numOfFailure > 0) {
                set failedByEpisodeIdArr(EpisodeId) = numOfFailure
            }
            
            $$$LOGINFO("[OrderService.NewOrder] Results: patient Id: "_patientVo.PatientId_", episode Id: "_EpisodeId_", orderId: "_##class(CommonUtil).convertListOfDataTypeToString(orderIdList,))
            $$$LOGINFO("[OrderService.NewOrder] Success count: "_numOfSuccess_", Failure count: "_numOfFailure)
			
		}
        
    }

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

    // TO CHECK $Data vs $Object
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
                    #; $$$LOGINFO("[OrderService.Run] isMatchAPI: "_isMatchAPI)
                    #; $$$LOGINFO("[OrderService.Run] isMatchTestSet: "_isMatchTestSet)

                    if ((isMatchTestSet=1) || (isMatchAPI=1)) 
                    {
                        $$$LOGINFO("[OrderService.Run] Removing order index...")

                        // Check index
                        $$$LOGINFO("[OrderService.Run] orderIndexList.GetAt(cnt) value: "_orderIndexList.GetAt(cnt))
                        #; $$$LOGINFO("[OrderService.Run] Index_OrderObjListArr: "_idxOfRemoveOrderObjListArr(orderIndexList.GetAt(cnt)))
                        #; $$$LOGINFO("[OrderService.Run] Index_OrderIndexListArr: "_idxOfRemoveOrderIndexListArr(cnt))
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

    /// ???
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
    
    // Check
    $$$LOGINFO("[OrderService.Run2] Check value of orderOutput.OrderIdList: "_orderOutput.OrderIdList)  
    if (orderOutput.OrderIdList '= "") {     
        $$$LOGINFO("[OrderService.Run2] Counts before insertion: "_orderOutput.OrderIdList.Count())   
		for cnt=1:1:orderIdList.Count(){
            $$$LOGINFO("[OrderService.Run2] Insertion: "_orderIdList.GetAt(cnt))
			do orderOutput.OrderIdList.Insert(orderIdList.GetAt(cnt))
            $$$LOGINFO("[OrderService.Run2] Count after insertion: "_orderOutput.OrderIdList.Count())
		}
	} else { 
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
    $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] Before removal of item - sourceList Size: "_sourceList.Count())
    
    set key = $Order(removalIndexArray(""), -1) //inverse order, delete the items in inverse order
    $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] Key value: "_key)

    while (key '= "") {
        do sourceList.RemoveAt(key)
        set key = $Order(removalIndexArray(key), -1)
    }
    $$$LOGINFO("[OrderService.RemoveItemsInverseFromList] After removal of item - sourceList Size: "_sourceList.Count())
}

// Initialise the resquest for orders

Method InitOrderRequestByRandom(orderObjList As %ListOfObjects, NumOfOrderPerEpisode As %Integer, EpisodeId As %String, EpisodeAdmDate As %String, EpisodeAdmTime As %String, Output orderInput As CDUI.DataGen.DataGenService.Custom.OrderInput, Output orderIndexList)
{
    kill orderInput
    set orderInput = ##class(CDUI.DataGen.DataGenService.Custom.OrderInput).%New()
    set orderTmpList = ##class(%ListOfObjects).%New()

    for cnt=1:1:NumOfOrderPerEpisode {

        //Set up Order request
        set request = ##class(CDUI.DataGen.Request.NewOrder).%New()

        // Get a random ordercategory object index 
        set randorderVoObjListListIndex = ($$$PRand(orderObjList.Count()) + 1)

        // Get the episode and ordercategory objects
        #; set episodeVo = episodeVoObjList.GetAt(randEpisodeVoListIndex)
        set orderCatVo = orderObjList.GetAt(randorderVoObjListListIndex)
        
        set request.Item = orderCatVo.ID

        if ('$Data(orderIndexList)) {
           set orderIndexList = ##class(%ListOfDataTypes).%New()
        }
        do orderIndexList.Insert(randorderVoObjListListIndex)

        $$$LOGINFO("[NewOrder INIT] orderIndex: "_randorderVoObjListListIndex)
        $$$LOGINFO("[NewOrder INIT] orderIndexList Count: "_orderIndexList.Count())
        for cnt=1:1:orderIndexList.Count() {
            $$$LOGINFO("[NewOrder INIT] orderIndexList items: "_orderIndexList.GetAt(cnt))
        }
        
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
