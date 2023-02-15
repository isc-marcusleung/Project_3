Class CDUI.DataGen.Common.Constants
{

Parameter genders As STRING [ Final ] = "Female,Indeterminate,Male,Other,Unknown";

Parameter maxAge As INTEGER [ Final ] = 100;

// Used to initialize log file 

Parameter logFileName As STRING = "/cduinterns/irissys/mgr/user/job_log.txt";

// Used to create obs table and submission array

Parameter obsHeader As STRING [ Final ] = "SubjectId,Date,Hour,SBP,DBP,HeartRate,Respirations,Temp,Height,Weight";

Parameter obsHeaderType As STRING [ Final ] = "%String,%String,%String,%Integer,%Integer,%Integer,%Integer,%Decimal,%Integer,%Decimal";

// Used to create FBC results table and submission array

Parameter FBCHeader As String [ Final ] = "SubjectId,Date,Hour,WBC,RBC,HB,HCT,MCV,MCH,MCHC,RDW,PLT";

Parameter FBCHeaderType As String [ Final ] = "%String,%String,%String,%Decimal,%Decimal,%Decimal,%Decimal,%Decimal,%Decimal,%Decimal,%Decimal,%Decimal";

// Available mode options,Used to create ItemIdDic 

Parameter ModeOptions As String [ Final ] = "Obs,FBC";

// Used to create ItemIdDic for mode Obs

Parameter ObsItemId As String [ Final ] = "220179,220180,220045,220210,223761,226512,226730";

Parameter ObsItemName As String [ Final ] = "SBP,DBP,HeartRate,Respirations,Temp,Weight,Height";

// Used to create ItemIdDic for mode FBC

Parameter FBCItemId As STRING [ Final ] = "51301,51279,51222,51221,51250,51248,51249,51277,51265";

Parameter FBCItemName As String [ Final ] = "WBC,RBC,HB,HCT,MCV,MCH,MCHC,RDW,PLT";

Parameter oecprDesc As STRING [ Final ] = "NORM,U";

Parameter SupportedOrderCategory As STRING [ Final ] = "Radiology,Consultation,Laboratory";

}
