Class CDUI.Web.Vo.GetJobsForDisplayVo Extends (%RegisteredObject, %JSON.Adaptor)
{

Property count As %Integer;

Property idPtr As %Integer;

Property results As %ListOfObjects;

Property links As %DynamicObject;

Method SerialisedGet() As %RawString
{
	do ..%JSONExportToString(.json)

	if (..links '= "") {
		set json = json_..links.%ToJSON()_"}"
	}

	return json
}

}
