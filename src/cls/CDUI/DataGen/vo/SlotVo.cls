Class CDUI.DataGen.vo.SlotVo Extends BaseVo
{

Property Date As %String;

Property SessStartTime As %String;

Property SessEndTime As %String;

Property USRN As %String;

// Property BookedSlots As %String;

// Property DurationOfService As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.DataGen.vo.SlotVo
{
    set obj = ..%New()
    set obj.Date = dynamicObj.Date
    set obj.SessStartTime = dynamicObj.SessStartTime
    set obj.SessEndTime = dynamicObj.SessEndTime
    set obj.USRN = dynamicObj.USRN

    return obj
}

}
