Class CDUI.Web.Vo.JobVo Extends (%RegisteredObject, %JSON.Adaptor)
{

Property id As %Integer;

Property pid As %Integer;

Property status As %String;

Property createDateTime As %String;

Property completeDateTime As %String;

Property lastUpdateDateTime As %String;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)
	return json
}

}
