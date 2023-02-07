Class CDUI.Web.Request.CreateJobRequest Extends (%RegisteredObject, Ens.Util.IOLogger)
{

Property NumOfPatient As %Integer;

Property NumOfEpisodePerPatient As %Integer;

Property NumOfOrderPerPatient As %Integer;

Property NumOfAppointmentPerPatient As %Integer;

Property MinNumOfEpisodePerPatient As %Integer;

Property MaxNumOfEpisodePerPatient As %Integer;

Property MinNumOfOrderPerPatient As %Integer;

Property MaxNumOfOrderPerPatient As %Integer;

Property MinNumOfAppointmentPerPatient As %Integer;

Property MaxNumOfAppointmentPerPatient As %Integer;

Property isEpisode As %Boolean;

Property isOrder As %Boolean;

Property isAppointment As %Boolean;

Property isEpisodeRange As %Boolean;

Property isOrderRange As %Boolean;

Property isAppointmentRange As %Boolean;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.Web.Request.CreateJobRequest
{
    set obj = ..%New()

    set obj.NumOfPatient = dynamicObj.NumOfPatient
    set obj.NumOfEpisodePerPatient = dynamicObj.NumOfEpisodePerPatient
    set obj.NumOfOrderPerPatient = dynamicObj.NumOfOrderPerPatient
    set obj.NumOfAppointmentPerPatient = dynamicObj.NumOfAppointmentPerPatient
    set obj.MinNumOfEpisodePerPatient = dynamicObj.MinNumOfEpisodePerPatient
    set obj.MaxNumOfEpisodePerPatient = dynamicObj.MaxNumOfEpisodePerPatient
    set obj.MinNumOfOrderPerPatient = dynamicObj.MinNumOfOrderPerPatient
    set obj.MaxNumOfOrderPerPatient = dynamicObj.MaxNumOfOrderPerPatient
    set obj.MinNumOfAppointmentPerPatient = dynamicObj.MinNumOfAppointmentPerPatient
    set obj.MaxNumOfAppointmentPerPatient = dynamicObj.MaxNumOfAppointmentPerPatient
    set obj.isEpisode = dynamicObj.isEpisode
    set obj.isOrder = dynamicObj.isOrder
    set obj.isAppointment = dynamicObj.isAppointment
    set obj.isEpisodeRange = dynamicObj.isEpisodeRange
    set obj.isOrderRange = dynamicObj.isOrderRange
    set obj.isAppointmentRange = dynamicObj.isAppointmentRange

    return obj
}

ClassMethod isRequestValid(request As CDUI.Web.Request.CreateJobRequest) As %Integer
{
    set isPatientValid = (request.NumOfPatient > 0)
    set isEpisodeValid = ((request.NumOfEpisodePerPatient > 0) && (request.isEpisode)) || '(request.isEpisode)
    set isOrderValid = ((request.NumOfOrderPerPatient > 0) && (request.isOrder) || '(request.isOrder))
    set isAppointmentValid = ((request.NumOfAppointmentPerPatient > 0) && (request.isAppointment) || '(request.isAppointment))
    set isEpisodeRangeValid = ((request.MinNumOfEpisodePerPatient > 0 || request.MaxNumOfEpisodePerPatient > 0) && (request.isEpisodeRange) || '(request.isEpisodeRange))
    set isOrderRangeValid = ((request.MinNumOfOrderPerPatient > 0 || request.MaxNumOfOrderPerPatient > 0) && (request.isOrderRange) || '(request.isOrderRange))
    set isAppointmentRangeValid = ((request.MinNumOfAppointmentPerPatient > 0 || request.MaxNumOfAppointmentPerPatient > 0) && (request.isAppointmentRange) || '(request.isAppointmentRange))


    set isAllValid = isPatientValid && isEpisodeValid && isOrderValid && isAppointmentValid && isEpisodeRangeValid && isOrderRangeValid && isAppointmentRangeValid

    $$$LOGINFO("[CreateJobRequest.validateRequest] isAllValid: "_isAllValid)
    $$$LOGINFO("[CreateJobRequest.validateRequest] isPatientValid: "_isPatientValid_", isEpisodeValid: "_isEpisodeValid_", isOrderValid: "_isOrderValid_", isAppointmentValid: "_isAppointmentValid_", isEpisodeRangeValid: "_isEpisodeRangeValid_", isOrderRangeValid: "_isOrderRangeValid_", isAppointmentRangeValid: "_isAppointmentRangeValid)

    return isAllValid
}

}
