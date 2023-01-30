Import CDUI.DataGen.DataGenService

Class CDUI.DataGen.DataGenService.Base.BaseService Extends (%RegisteredObject, Ens.Util.IOLogger) [ Abstract ]
{

///  Default page size for record retrieval.
Property PageSize As %Integer [ InitialExpression = 500 ];

/// Default Max number of retry in the process
Property MaxNumOfRetry As %Integer [ InitialExpression = 8 ];

Parameter DispatchName = "CDUI.DataGen.Service.Adaptorless";

Method SetMaxNumOfRetry(maxNumOfRetry As %Integer)
{
   set ..MaxNumOfRetry = maxNumOfRetry
}

Method SetPageSize(pageSize As %Integer)
{
   set ..PageSize = pageSize
}

Method RunWithRetry(BaseInput As CDUI.DataGen.DataGenService.Base.Input, BaseOutput As CDUI.DataGen.DataGenService.Base.Output, NumOfRetry As %Integer)
{
    set trialCnt = 1
    set isRetry = 1
    $$$LOGINFO("[BaseService.RunWithRetry] MaxNumOfRetry: "_..MaxNumOfRetry)
    if ($Get(NumOfRetry) '= "") {
       set numOfRetry = NumOfRetry
    } else {
        set numOfRetry = ..MaxNumOfRetry
    }

    //if the number of retry specified is less than 0 then set it to 0 so it can run 1 time.
    if (numOfRetry < 0) {
        set numOfRetry = 0
    }

    while ((numOfRetry >= trialCnt) && isRetry){
        $$$LOGINFO("[BaseService.RunWithRetry] Trial: "_trialCnt)
        set result = ..Run(BaseInput, BaseOutput)

        if result > 0 {
             set trialCnt = trialCnt + 1
        } else {
            set isRetry = 0
        }
    }
}

// If the return value is > 0, then RunWithRetry will retry

// Implement this function for RunWithRetry

Method Run(BaseInput As CDUI.DataGen.DataGenService.Base.Input, BaseOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer [ Abstract, Private ]
{
}

Method SendRequest(request As Ens.Request, ByRef response) As %Status
{
    set sc = ##class(Ens.Director).CreateBusinessService(..#DispatchName,.svc)
    set sc = $$$ADDSC(sc,svc.ProcessInput(request,.response))
    return sc
}

}
