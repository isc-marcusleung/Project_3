Import CDUI.DataGen.Utils

Class CDUI.DataGen.vo.OrderCatVo Extends %RegisteredObject
{

Property ORCATDesc As %String;

Property ID As %String;

Property ARCIMEffDate As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.DataGen.vo.OrderCatVo
{
    set obj = ..%New()
    set obj.ORCATDesc = dynamicObj.ORCATDesc
    set obj.ID = dynamicObj.ID
    set obj.ARCIMEffDate = dynamicObj.ARCIMEffDate
    return obj
}

}
