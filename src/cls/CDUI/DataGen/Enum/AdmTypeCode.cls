Class CDUI.DataGen.Enum.AdmTypeCode
{

Parameter InPatient As STRING [ Final ] = "I";

Parameter Emergency As STRING [ Final ] = "E";

Parameter OutPatient As STRING [ Final ] = "O";

/// Description
ClassMethod GetAdmTypeCodeString(delimiter As %String = ",") As %String
{
    Return ..#InPatient_delimiter_..#Emergency_delimiter_..#OutPatient
}

}
