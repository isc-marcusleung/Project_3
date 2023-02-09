Class CDUI.Web.Request.CreateJobRequest Extends (%RegisteredObject, Ens.Util.IOLogger)
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
    set obj.isEpisode = $Get(%request.Data("isEpisode",1),default) 
    set obj.isOrder = $Get(%request.Data("isOrder",1),default)
    set obj.isAppointment = $Get(%request.Data("isAppointment",1),default)
    set obj.isObservation = $Get(%request.Data("isObservation",1),default)
    set obj.isEpisodeRange = $Get(%request.Data("isEpisodeRange",1),default) 
    set obj.isOrderRange = $Get(%request.Data("isOrderRange",1),default)  
    set obj.isAppointmentRange = $Get(%request.Data("isAppointmentRange",1),default) 
    set obj.isObservationRange = $Get(%request.Data("isObservationRange",1),default)

    return obj
}

ClassMethod isRequestValid(request As CDUI.Web.Request.CreateJobRequest) As %Integer
{
    set isPatientValid = (request.NumOfPatient > 0)
    set isEpisodeValid = ((request.NumOfEpisodePerPatient > 0) && (request.isEpisode)) || '(request.isEpisode)
    set isOrderValid = ((request.NumOfOrderPerEpisode > 0) && (request.isOrder) || '(request.isOrder))
    set isAppointmentValid = ((request.NumOfAppointmentPerPatient > 0) && (request.isAppointment) || '(request.isAppointment))
    set isObservationValid = ((request.NumOfObservationPerEpisode > 0) && (request.isObservation) || '(request.isObservation))
    set isEpisodeRangeValid = ((request.MinNumOfEpisodePerPatient > 0 || request.MaxNumOfEpisodePerPatient > 0) && (request.isEpisodeRange) || '(request.isEpisodeRange))
    set isOrderRangeValid = ((request.MinNumOfOrderPerEpisode > 0 || request.MaxNumOfOrderPerEpisode > 0) && (request.isOrderRange) || '(request.isOrderRange))
    set isAppointmentRangeValid = ((request.MinNumOfAppointmentPerPatient > 0 || request.MaxNumOfAppointmentPerPatient > 0) && (request.isAppointmentRange) || '(request.isAppointmentRange))
    set isObservationRangeValid = ((request.MinNumOfObservationPerEpisode > 0 || request.MaxNumOfObservationPerEpisode > 0) && (request.isObservationRange) || '(request.isObservationRange))

    set isAllValid = isPatientValid && isEpisodeValid && isOrderValid && isAppointmentValid && isObservationValid && isEpisodeRangeValid && isOrderRangeValid && isAppointmentRangeValid && isObservationRangeValid
  
    $$$LOGINFO("[CreateJobRequest.validateRequest] isAllValid: "_isAllValid)
    $$$LOGINFO("[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isObservationValid: "_isObservationValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid_", isObservationRangeValid: "_isObservationRangeValid)
    
    return isAllValid
}

}
