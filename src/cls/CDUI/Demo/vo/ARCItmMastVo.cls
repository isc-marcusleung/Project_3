Import CDUI.Demo.Utils

Class CDUI.Demo.vo.ARCItmMasVo Extends %RegisteredObject
{

Property ID As %String;

Property ARCIMCode As %String;

Property ARCIMDesc As %String;

Property ARCBGDesc As %String;

Property ARCSGDesc As %String;

Property ARCIMItemCatDR As %String;

Property ARCIMEffDate As %String;

ClassMethod newInstance(dynamicObj As %DynamicObject) As CDUI.Demo.vo.ARCItmMasVo
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
