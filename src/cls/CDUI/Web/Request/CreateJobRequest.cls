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
    
    //TODO marcus to remove it
    #; k ^marcus
    #; s ^marcus("NumOfPatient") = obj.NumOfPatient
    #; s ^marcus("NumOfEpisodePerPatient") = obj.NumOfEpisodePerPatient
    #; s ^marcus("NumOfOrderPerEpisode") = obj.NumOfOrderPerEpisode
    #; s ^marcus("NumOfAppointmentPerPatient") = obj.NumOfAppointmentPerPatient
    #; s ^marcus("NumOfObservationPerEpisode") = obj.NumOfObservationPerEpisode
    #; s ^marcus("MinNumOfEpisodePerPatient") = obj.MinNumOfEpisodePerPatient
    #; s ^marcus("MaxNumOfEpisodePerPatient") = obj.MaxNumOfEpisodePerPatient
    #; s ^marcus("MinNumOfOrderPerEpisode") = obj.MinNumOfOrderPerEpisode
    #; s ^marcus("MaxNumOfOrderPerEpisode") = obj.MaxNumOfOrderPerEpisode
    #; s ^marcus("MinNumOfAppointmentPerPatient") = obj.MinNumOfAppointmentPerPatient
    #; s ^marcus("MaxNumOfAppointmentPerPatient") = obj.MaxNumOfAppointmentPerPatient
    #; s ^marcus("MinNumOfObservationPerEpisode") = obj.MinNumOfObservationPerEpisode
    #; s ^marcus("MaxNumOfObservationPerEpisode") = obj.MaxNumOfObservationPerEpisode
    #; s ^marcus("isEpisode") = obj.isEpisode
    #; s ^marcus("isOrder") = obj.isOrder
    #; s ^marcus("isAppointment") = obj.isAppointment
    #; s ^marcus("isObservation") = obj.isObservation
    #; s ^marcus("isEpisodeRange") = obj.isEpisodeRange
    #; s ^marcus("isOrderRange") = obj.isOrderRange
    #; s ^marcus("isAppointmentRange") = obj.isAppointmentRange
    #; s ^marcus("isObservationRange") = obj.isObservationRange
    

    return obj
}

ClassMethod isRequestValid(request As CDUI.Web.Request.CreateJobRequest) As %Integer
{
    set isPatientValid = (request.NumOfPatient > 0)
    set isEpisodeValid = ((request.NumOfEpisodePerPatient > 0) && (request.isEpisode)) || '(request.isEpisode)
    set isOrderValid = (((request.NumOfOrderPerEpisode > 0) && (request.isOrder)) || '(request.isOrder))
    set isAppointmentValid = (((request.NumOfAppointmentPerPatient > 0) && (request.isAppointment)) || '(request.isAppointment))
    set isObservationValid = (((request.NumOfObservationPerEpisode > 0) && (request.isObservation)) || '(request.isObservation))
    set isEpisodeRangeValid = (((request.MinNumOfEpisodePerPatient > 0 && request.MaxNumOfEpisodePerPatient > 0) && (request.isEpisodeRange)) || '(request.isEpisodeRange))
    set isOrderRangeValid = (((request.MinNumOfOrderPerEpisode > 0 && request.MaxNumOfOrderPerEpisode > 0) && (request.isOrderRange)) || '(request.isOrderRange))
    set isAppointmentRangeValid = (((request.MinNumOfAppointmentPerPatient > 0 && request.MaxNumOfAppointmentPerPatient > 0) && (request.isAppointmentRange)) || '(request.isAppointmentRange))
    set isObservationRangeValid = (((request.MinNumOfObservationPerEpisode > 0 && request.MaxNumOfObservationPerEpisode > 0) && (request.isObservationRange)) || '(request.isObservationRange))
    
    set isOrderCatValid = 1
    if (request.OrderCat =' "") {
        set isOrderCatValid = $listfind($listfromstring(##class(CDUI.DataGen.Common.Constants).#SupportedOrderCategory,",") , request.OrderCat) > 0
    }

    set isAllValid = isPatientValid && isEpisodeValid && isOrderValid && isAppointmentValid && isObservationValid && isEpisodeRangeValid && isOrderRangeValid && isAppointmentRangeValid && isObservationRangeValid && isOrderCatValid
  
    $$$LOGINFO("[CreateJobRequest.validateRequest] isAllValid: "_isAllValid)
    $$$LOGINFO("[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isObservationValid: "_isObservationValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid_", isObservationRangeValid: "_isObservationRangeValid_", isOrderCatValid: "_isOrderCatValid)
    //TODO marcus to remove it
    #; s ^marcus("100") = "[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isObservationValid: "_isObservationValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid_", isObservationRangeValid: "_isObservationRangeValid
    return isAllValid
}

}
