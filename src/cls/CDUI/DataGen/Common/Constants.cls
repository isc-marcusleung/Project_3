Class CDUI.DataGen.Common.Constants
{

Parameter genders As STRING [ Final ] = "Female,Indeterminate,Male,Other,Unknown";

Parameter maxAge As INTEGER [ Final ] = 100;

// C: Cancel, A: Current, N: Did Not Attend, D: Discharge, P: Pre-admission

Parameter visitStatusCode As STRING [ Final ] = "C,A,N,D,P";

// I: in-patient, E: Emergency, O: out-patient

Parameter admTypeCode As STRING [ Final ] = "I,E,O";

}
