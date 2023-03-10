Class CDUI.Web.Request.CreateJobRequest Extends (%RegisteredObject, Ens.Util.IOLogger, %JSON.Adaptor)
{

Property NumOfPatient As %Integer;

Property NumOfEpisodePerPatient As %Integer;

Property NumOfOrderPerEpisode As %Integer;

Property NumOfAppointmentPerPatient As %Integer;

Property NumOfObservationPerEpisode As %Integer;

Property MinNumOfEpisodePerPatient As %Integer;

Property MaxNumOfEpisodePerPatient As %Integer;

Property MinNumOfOrderPerEpisode As %Integer;

Property MaxNumOfOrderPerEpisode As %Integer;

Property MinNumOfAppointmentPerPatient As %Integer;

Property MaxNumOfAppointmentPerPatient As %Integer;

Property MinNumOfObservationPerEpisode As %Integer;

Property MaxNumOfObservationPerEpisode As %Integer;

Property isEpisode As %Boolean;

Property isOrder As %Boolean;

Property isAppointment As %Boolean;

Property isObservation As %Boolean;

Property isEpisodeRange As %Boolean;

Property isOrderRange As %Boolean;

Property isAppointmentRange As %Boolean;

Property isObservationRange As %Boolean;

Property OrderCat As %String;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

ClassMethod newInstance(request As %CSP.Request) As CDUI.Web.Request.CreateJobRequest
{
    set obj = ..%New()
    set default = ""
    set obj.NumOfPatient = $Get(%request.Data("numOfPatient",1),default) 
    set obj.NumOfEpisodePerPatient = $Get(%request.Data("numOfEpisodePerPatient",1),default) 
    set obj.NumOfOrderPerEpisode = $Get(%request.Data("numOfOrderPerEpisode",1),default) 
    set obj.NumOfAppointmentPerPatient = $Get(%request.Data("numOfAppointmentPerPatient",1),default)
    set obj.NumOfObservationPerEpisode = $Get(%request.Data("numOfObservationPerEpisode",1),default) 
    set obj.MinNumOfEpisodePerPatient = $Get(%request.Data("minNumOfEpisodePerPatient",1),default)
    set obj.MaxNumOfEpisodePerPatient = $Get(%request.Data("maxNumOfEpisodePerPatient",1),default) 
    set obj.MinNumOfOrderPerEpisode = $Get(%request.Data("minNumOfOrderPerEpisode",1),default)
    set obj.MaxNumOfOrderPerEpisode = $Get(%request.Data("maxNumOfOrderPerEpisode",1),default) 
    set obj.MinNumOfAppointmentPerPatient = $Get(%request.Data("minNumOfAppointmentPerPatient",1),default)
    set obj.MaxNumOfAppointmentPerPatient = $Get(%request.Data("maxNumOfAppointmentPerPatient",1),default)
    set obj.MinNumOfObservationPerEpisode = $Get(%request.Data("minNumOfObservationPerEpisode",1),default)
    set obj.MaxNumOfObservationPerEpisode = $Get(%request.Data("maxNumOfObservationPerEpisode",1),default)
    set obj.isEpisode = $Get(%request.Data("isEpisode",1),default) 
    set obj.isOrder = $Get(%request.Data("isOrder",1),default)
    set obj.isAppointment = $Get(%request.Data("isAppointment",1),default)
    set obj.isObservation = $Get(%request.Data("isObservation",1),default)
    set obj.isEpisodeRange = $Get(%request.Data("isEpisodeRange",1),default) 
    set obj.isOrderRange = $Get(%request.Data("isOrderRange",1),default)  
    set obj.isAppointmentRange = $Get(%request.Data("isAppointmentRange",1),default) 
    set obj.isObservationRange = $Get(%request.Data("isObservationRange",1),default)
    set obj.OrderCat = $Get(%request.Data("orderCat",1),default)
 
    return obj
}

ClassMethod isRequestValid(request As CDUI.Web.Request.CreateJobRequest) As %Integer
{
    set isPatientValid = (request.NumOfPatient > 0)
    set isEpisodeValid = ((request.NumOfEpisodePerPatient > 0) && (request.isEpisode)) || '(request.isEpisode)
    set isOrderValid = (((request.NumOfOrderPerEpisode > 0) && (request.isOrder)) || '(request.isOrder))
    set isAppointmentValid = (((request.NumOfAppointmentPerPatient > 0) && (request.isAppointment)) || '(request.isAppointment))
    set isObservationValid = (((request.NumOfObservationPerEpisode > 0) && (request.isObservation)) || '(request.isObservation))
    set isEpisodeRangeValid = (((request.MinNumOfEpisodePerPatient >= 0 && request.MaxNumOfEpisodePerPatient > 0) && (request.MinNumOfEpisodePerPatient < request.MaxNumOfEpisodePerPatient) && (request.isEpisodeRange)) || '(request.isEpisodeRange))
    set isOrderRangeValid = (((request.MinNumOfOrderPerEpisode >= 0 && request.MaxNumOfOrderPerEpisode > 0) && (request.MinNumOfOrderPerEpisode < request.MaxNumOfOrderPerEpisode)  && (request.isOrderRange)) || '(request.isOrderRange))
    set isAppointmentRangeValid = (((request.MinNumOfAppointmentPerPatient >= 0 && request.MaxNumOfAppointmentPerPatient > 0) && (request.MinNumOfAppointmentPerPatient < request.MaxNumOfAppointmentPerPatient) && (request.isAppointmentRange)) || '(request.isAppointmentRange))
    set isObservationRangeValid = (((request.MinNumOfObservationPerEpisode >= 0 && request.MaxNumOfObservationPerEpisode > 0) && (request.MinNumOfObservationPerEpisode < request.MaxNumOfObservationPerEpisode) && (request.isObservationRange)) || '(request.isObservationRange))
    
    set isOrderCatValid = 1
    if (request.OrderCat =' "") {
        set isOrderCatValid = $listfind($listfromstring(##class(CDUI.DataGen.Common.Constants).#SupportedOrderCategory,",") , request.OrderCat) > 0
    }

    set isAllValid = isPatientValid && isEpisodeValid && isOrderValid && isAppointmentValid && isObservationValid && isEpisodeRangeValid && isOrderRangeValid && isAppointmentRangeValid && isObservationRangeValid && isOrderCatValid
  
    $$$LOGINFO("[CreateJobRequest.validateRequest] isAllValid: "_isAllValid)
    $$$LOGINFO("[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isObservationValid: "_isObservationValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid_", isObservationRangeValid: "_isObservationRangeValid_", isOrderCatValid: "_isOrderCatValid)
    //set ^DataGen.Log($i(^DataGen.Log),"validate") = "[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isObservationValid: "_isObservationValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid_", isObservationRangeValid: "_isObservationRangeValid
    return isAllValid
}

Method generateStringParamValues() As %String
{
    set result = ..NumOfPatient
    set result =  result_"^"_..NumOfEpisodePerPatient 
    set result =  result_"^"_..NumOfOrderPerEpisode
    set result =  result_"^"_..NumOfAppointmentPerPatient
    set result =  result_"^"_..NumOfObservationPerEpisode
    set result =  result_"^"_..MinNumOfEpisodePerPatient
    set result =  result_"^"_..MaxNumOfEpisodePerPatient
    set result =  result_"^"_..MinNumOfOrderPerEpisode
    set result =  result_"^"_..MaxNumOfOrderPerEpisode
    set result =  result_"^"_..MinNumOfAppointmentPerPatient
    set result =  result_"^"_..MaxNumOfAppointmentPerPatient
    set result =  result_"^"_..MinNumOfObservationPerEpisode
    set result =  result_"^"_..MaxNumOfObservationPerEpisode
    set result =  result_"^"_..isEpisode
    set result =  result_"^"_..isOrder
    set result =  result_"^"_..isAppointment
    set result =  result_"^"_..isObservation
    set result =  result_"^"_..isEpisodeRange
    set result =  result_"^"_..isOrderRange
    set result =  result_"^"_..isAppointmentRange
    set result =  result_"^"_..isObservationRange
    set result =  result_"^"_..OrderCat

    return result
}

ClassMethod newInstanceFromStringParamValues(paramValues As %String) As CDUI.Web.Request.CreateJobRequest
{
	set alist = $listfromstring(paramValues, "^") 
    set obj = ..%New()
	
    set obj.NumOfPatient = $list(alist, 1)
    set obj.NumOfEpisodePerPatient = $list(alist, 2)
    set obj.NumOfOrderPerEpisode =$list(alist, 3)
    set obj.NumOfAppointmentPerPatient = $list(alist, 4)
    set obj.NumOfObservationPerEpisode = $list(alist, 5)
    set obj.MinNumOfEpisodePerPatient = $list(alist, 6)
    set obj.MaxNumOfEpisodePerPatient = $list(alist, 7)
    set obj.MinNumOfOrderPerEpisode = $list(alist, 8)
    set obj.MaxNumOfOrderPerEpisode = $list(alist, 9)
    set obj.MinNumOfAppointmentPerPatient = $list(alist, 10)
    set obj.MaxNumOfAppointmentPerPatient = $list(alist, 11)
    set obj.MinNumOfObservationPerEpisode = $list(alist, 12)
    set obj.MaxNumOfObservationPerEpisode = $list(alist, 13)
    set obj.isEpisode = $list(alist, 14)
    set obj.isOrder = $list(alist, 15)
    set obj.isAppointment = $list(alist, 16)
    set obj.isObservation = $list(alist, 17)
    set obj.isEpisodeRange = $list(alist, 18)
    set obj.isOrderRange = $list(alist, 19)
    set obj.isAppointmentRange = $list(alist, 20)
    set obj.isObservationRange = $list(alist, 21)
    set obj.OrderCat = $list(alist, 22)
    
    return obj
}

}
