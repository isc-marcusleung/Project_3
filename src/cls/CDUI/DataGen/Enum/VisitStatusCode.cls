Class CDUI.DataGen.Enum.VisitStatusCode
{

// C: Cancel, A: Current, N: Did Not Attend, D: Discharge, P: Pre-admission

Parameter Cancel As STRING [ Final ] = "C";

Parameter Current As STRING [ Final ] = "A";

Parameter DidNotAttend As STRING [ Final ] = "N";

Parameter Discharge As STRING [ Final ] = "D";

Parameter PreAdmission As STRING [ Final ] = "P";

/// Description
ClassMethod GeVisitStatusCodeString(delimiter As %String = ",") As %String
{
    Return ..#Cancel_delimiter_..#Current_delimiter_..#DidNotAttend_delimiter_..#Discharge_delimiter_..#PreAdmission
}

}
