Class CDUI.Demo.vo.Location Extends %RegisteredObject
{

Property CTLOCCode As %String;

Property CTLOCDesc As %String;

Property CTLOCType As %String;

Property HOSPDesc As %String;

Property CTLOCDateActiveFrom As %Date;

Property CTLOCDateActiveTo As %Date;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.Demo.vo.Location
{
    set obj = ..%New()
    set obj.CTLOCCode = dynamicObj.CTLOCCode
    set obj.CTLOCDesc = dynamicObj.CTLOCDesc
    set obj.CTLOCType = dynamicObj.CTLOCType
    set obj.HOSPDesc = dynamicObj.HOSPDesc
    set obj.CTLOCDateActiveFrom = dynamicObj.CTLOCDateActiveFrom
    set obj.CTLOCDateActiveTo = dynamicObj.CTLOCDateActiveTo
    return obj
}

}
