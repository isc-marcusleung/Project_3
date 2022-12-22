Class CDUI.Demo.Response.LocationList Extends (Ens.Response, %JSON.Adaptor)
{

Property results As array Of CDUI.Demo.Response.Location;

Storage Default
{
<Data name="results">
<Attribute>results</Attribute>
<Structure>subnode</Structure>
<Subscript>"CDUI.Demo.Response.LocationList.results"</Subscript>
</Data>
<Type>%Storage.Persistent</Type>
}

}
