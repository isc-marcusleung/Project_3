Class CDUI.DataGen.Response.LocationList Extends (Ens.Response, %JSON.Adaptor)
{

Property results As array Of CDUI.DataGen.Response.Location;

Storage Default
{
<Data name="results">
<Attribute>results</Attribute>
<Structure>subnode</Structure>
<Subscript>"CDUI.DataGen.Response.LocationList.results"</Subscript>
</Data>
<Type>%Storage.Persistent</Type>
}

}
