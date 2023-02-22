Import CDUI.DataGen.Utils

Class CDUI.DataGen.vo.ARCAuxilInsurTypeVo Extends BaseVo
{

Property AUXITDesc As %String;

Property AUXITInsTypeDR As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.DataGen.vo.ARCAuxilInsurTypeVo
{
    set obj = ..%New()
    set obj.AUXITDesc = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.AUXITDesc)
    set obj.AUXITInsTypeDR = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.AUXITInsTypeDR)
    return obj
}

}
