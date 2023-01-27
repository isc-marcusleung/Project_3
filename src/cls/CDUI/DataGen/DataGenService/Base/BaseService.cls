Import CDUI.DataGen.DataGenService

Class CDUI.DataGen.DataGenService.Base.BaseService Extends Ens.Util.IOLogger
{

///  Default page size for record retrieval.
Parameter DefaultPageSize = 500;

/// Default Max number of retry in the process
Parameter MaxNumOfRetry = 8;

Method RunWithRetry(BaseInput As CDUI.DataGen.DataGenService.Base.Input, BaseOutput As CDUI.DataGen.DataGenService.Base.Output)
{
    set trialCnt = 1
    set isRetry = 1

    while ((..#MaxNumOfRetry >= trialCnt) && isRetry){
        $$$LOGINFO("[BaseService] Trial: "_trialCnt)
        set result = ..Run(BaseInput, BaseOutput)

        if result > 0 {
             set trialCnt = trialCnt + 1
        } else {
            set isRetry = 0
        }
    }
}

// If the return value is > 0, then RunWithRetry will retry

// Override this function for RunWithRetry

Method Run(BaseInput As CDUI.DataGen.DataGenService.Base.Input, BaseOutput As CDUI.DataGen.DataGenService.Base.Output) As %Integer
{
    return 0
}

}
