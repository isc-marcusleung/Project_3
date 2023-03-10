Import CDUI.DataGen.Utils

Class CDUI.DataGen.vo.ARCItmMasVo Extends BaseVo
{

Property ID As %String;

Property ARCIMCode As %String;

Property ARCIMDesc As %String;

Property ARCBGDesc As %String;

Property ARCSGDesc As %String;

Property ARCIMItemCatDR As %String;

Property ARCIMEffDate As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.DataGen.vo.ARCItmMasVo
{
    set obj = ..%New()
    set obj.ID = dynamicObj.ID
    set obj.ARCIMCode = dynamicObj.ARCIMCode
    set obj.ARCIMDesc = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.ARCIMDesc)
    set obj.ARCBGDesc = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.ARCBGDesc)
    set obj.ARCSGDesc = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.ARCSGDesc)
    set obj.ARCIMItemCatDR = ##class(CommonUtil).decodeXMLEscapedChar(dynamicObj.ARCIMItemCatDR)
    set obj.ARCIMEffDate = $piece(dynamicObj.ARCIMEffDate,"Z")

    return obj
}

}
