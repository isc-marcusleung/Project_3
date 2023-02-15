Class CDUI.DataGen.DataGenService.Custom.ObsInput Extends CDUI.DataGen.DataGenService.Base.Input
{

// list of CDUI.DataGen.Request.NewObs

Property RequestObjList As %ListOfObjects;

// In case any invalid location is in this list, the list would be updated after any error occurs

Property LocationObjList As %ListOfObjects;

}
