Class CDUI.DataGen.vo.APILogVo Extends BaseVo
{

Property currentDate;

Property currentTime;

Property APIname;

Property requestBody;

Property responseBody;

Property responseTime;

Property HTTPResponseStatusCode;

Property HTTPResponseStatusLine;

Method concatenateProp(Output info As %String)
{
    set info = ..currentDate_";"_..currentTime_";"_..APIname_";"_..requestBody_";"_..responseBody_";"_..responseTime_";"_..HTTPResponseStatusCode_";"_..HTTPResponseStatusLine
}

}
