Class CDUI.DataGen.vo.BaseVo Extends (%RegisteredObject, %JSON.Adaptor)
{

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

}
