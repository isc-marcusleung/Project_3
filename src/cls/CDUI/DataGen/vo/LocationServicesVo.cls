Import CDUI.DataGen.Utils

Class CDUI.DataGen.vo.LocationServicesVo Extends BaseVo
{

Property OrderCode As %String;

Property Order As %String;

Property RowID As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.DataGen.vo.LocationServicesVo
{
    set obj = ..%New()
    set obj.OrderCode = dynamicObj.OrderCode
    set obj.Order = dynamicObj.Order
    set obj.RowID = dynamicObj.RowID

    return obj
}

}
