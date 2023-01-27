Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Include %syPrompt

Class CDUI.DataGen.LoadExternal Extends Ens.Util.IOLogger
{

// Purpose: Create an array containing vital sign observations, values are all empty 

ClassMethod CreateVsArray(Output VsArray As %ArrayOfDataTypes)
{
    set list = $listfromstring(##class(Constants).#obsHeader,",")
    set VsArray = ##class(%ArrayOfDataTypes).%New()
    set p = 0
    While $LISTNEXT(list,p,value){
        do VsArray.SetAt("",value)
    }
}

// Purpose: Reset the input array

ClassMethod ResetArray(ByRef InputArray As %ArrayOfDataTypes)
{
    set key = ""
    for {
        set val = InputArray.GetNext(.key)
        quit:(key = "")
        do InputArray.SetAt("",key)
    }
}

// Purpose: check whether the input array has a value assigned to each key

ClassMethod IsArrayFull(InputArray As %ArrayOfDataTypes) As %Boolean
{
    set isFull = 1
    set key = ""
    for {
        set val = InputArray.GetNext(.key)
        quit:(key = "")
        if val = ""{
            set isFull = 0
        }
    }
    return isFull
}

// Purpose: check whether the input array key has a value attached to it  

ClassMethod IsArrayKeyUsed(key As %String, InputArray As %ArrayOfDataTypes) As %Boolean
{
    if (InputArray.GetAt(key) = ""){
        return 0
    }
    else {
        return 1 
    }
}

// Purpose: Convert from f to c

ClassMethod ConvertF(TempF As %Decimal) As %Decimal
{
    set TempC = (TempF-32)*5/9
    return TempC
}

// Purpose: save a value to a certain key in an array

ClassMethod SaveToArray(key As %String, value As %Decimal, ByRef InputArray As %ArrayOfDataTypes)
{
    do InputArray.SetAt(value,key)
}

// Purpose: copy the value from ArrayFrom to ArrayTo, cannot use "set ArrayTo = ArrayFrom" as this only make 2 variables pointing to the same array. 

// ArrayFrom and ArrayTo must have the exactly same set of keys!

ClassMethod CopyArrayValue(ByRef ArrayFrom As %ArrayOfDataTypes, ByRef ArrayTo As %ArrayOfDataTypes)
{
    set key = ""
    for {
        set val = ArrayFrom.GetNext(.key)
        quit:(key = "")
        do ArrayTo.SetAt(val,key)
    }
}

// Purpose: check whether the observation item is needed, return its ObsType and ObsValue 

ClassMethod CheckObsItemId(ObsObj As CDUI.DataGen.MIMIC.CHARTEVENTS, Output isNeeded As %Boolean, Output ObsType As %String, Output ObsValue As %Decimal)
{
    set isNeeded = 1 
    set ObsValue = ObsObj.value
    set ObsType = ""
    set itemId = ObsObj.itemId

    if (itemId = 220179){
        set ObsType = "SBP"
    }
    elseif (itemId = 220180){
        set ObsType = "DBP"
    }
    elseif (itemId = 220045){
        set ObsType = "HeartRate"
    }
    elseif (itemId = 220210){
        set ObsType = "Respirations"
    }
    elseif (itemId = 223761){
        set ObsType = "Temp"
        set ObsValue = ..ConvertF(ObsValue)
    }
    elseif (itemId = 226512){
        set ObsType = "Weight" 
    }
    elseif (itemId = 226730){
        set ObsType = "Height"
    }
    else{
        set isNeeded = 0
    }
}

// Purpose: check whether the obs object has a new set of icustayId, date and time 

ClassMethod CheckObsSession(ObsObj As CDUI.DataGen.MIMIC.CHARTEVENTS, CVsArray As %ArrayOfDataTypes, Output IsCurrentSession As %Boolean)
{
    set icuStayId = ObsObj.icustayId
    set date = $EXTRACT(ObsObj.charttime,1,10)
    set hour = $EXTRACT(ObsObj.charttime,12,13)
    if CVsArray.GetAt("IcuStayId") = ""{
        set IsCurrentSession = 1
    }
    else{
        if ((icuStayId '= CVsArray.GetAt("IcuStayId")) || (date '= CVsArray.GetAt("Date") ) || (hour '= CVsArray.GetAt("Hour"))){
            set IsCurrentSession = 0
        }
        else{
            set IsCurrentSession = 1
        }
    }
}

// The input CVsArray should not be full !

// Output:  ObsType: type of obs,  

//          ObsValue: value of obs

//          IsNewArray: whether the CVsArray needs to be submitted and resetted 

//          AddToArray: the ObsObj need to go into some array

// Purpose: check whether the observation object should be inserted into an array for submission 

//          if yes, whether it should be inserted into the current array or a new one 

ClassMethod CheckObsObj(ObsObj As CDUI.DataGen.MIMIC.CHARTEVENTS, CVsArray As %ArrayOfDataTypes, Output ObsType As %String, Output ObsValue As %Decimal, Output AddToArray As %Boolean, Output IsNewArray As %Boolean)
{
    set AddToArray = 1 
    
    // check if the item is needed by looking at its itemId
    do ..CheckObsItemId(ObsObj, .isNeeded, .ObsType, .ObsValue)
    if isNeeded = 0{
        set AddToArray = 0
    }

    //check if the ObsObj belong to the current or new session
    do ..CheckObsSession(ObsObj, CVsArray, .IsCurrentSession)

    //If the ObsObj belongs to the new session
    if (isNeeded = 1) && (IsCurrentSession = 0){
        set AddToArray = 1
        set IsNewArray = 1
    }

    //if the ObsObj belongs to the current session, check whether there is any duplicated value in the CVsArray
    if (isNeeded = 1) && (IsCurrentSession = 1){
        if (..IsArrayKeyUsed(ObsType, CVsArray) = 1){
            set AddToArray = 0
        }
        else{
            set AddToArray = 1
            set IsNewArray = 0
        }
    }
}

// Purpose: Update the height column with same icustayid when a new height value is found

ClassMethod UpdateHeight(height As %Integer, icuStayId As %Integer)
{
    &sql(UPDATE CDUI_DataGen_MIMIC.Observations SET Height = :height WHERE IcuStayId = :icuStayId)
}

// Purpose: if the VS array is not complete, use respective value from previous VS array to fill the blanks

//          Then insert the values in the cVsArray in the sql table 

ClassMethod SubmitCVsArray(ByRef CVsArray As %ArrayOfDataTypes, ByRef PVsArray As %ArrayOfDataTypes)
{
    //Update the current table if a new height value is obtained from the CVsArray
    set height = CVsArray.GetAt("Height")
    set icuStayId = CVsArray.GetAt("IcuStayId")
    if height '= ""{
        do ..UpdateHeight(height, icuStayId)
    }
    

    //fill blanks in the CVsArray using values from PVsArray
    set list = $listfromstring(##class(Constants).#obsHeader,",")
    set p = 0
    while $LISTNEXT(list,p,key){
        if (CVsArray.GetAt(key) = ""){
            set value = PVsArray.GetAt(key)
            do CVsArray.SetAt(value, key)
        }
    }

    //submit the CVsArray
    set NewObsSet = ##class(CDUI.DataGen.MIMIC.Observations).%New()
    set NewObsSet.IcuStayId = CVsArray.GetAt("IcuStayId")
    set NewObsSet.Date = CVsArray.GetAt("Date")
    set NewObsSet.Hour = CVsArray.GetAt("Hour")
    set NewObsSet.SBP = CVsArray.GetAt("SBP")
    set NewObsSet.DBP = CVsArray.GetAt("DBP")
    set NewObsSet.HeartRate = CVsArray.GetAt("HeartRate")
    set NewObsSet.Respirations = CVsArray.GetAt("Respirations")
    set NewObsSet.Temp = CVsArray.GetAt("Temp")
    set NewObsSet.Height = CVsArray.GetAt("Height")
    set NewObsSet.Weight = CVsArray.GetAt("Weight")
    do NewObsSet.%Save()


    //save CVsArray values in PVsArray, reset CVsArray
    do ..CopyArrayValue(.CVsArray,.PVsArray)
    do ..ResetArray(CVsArray)
}

ClassMethod LoadObs()
{
        set numOfRecord = 0
        &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.CHARTEVENTS)
        $$$LOGINFO("[LoadObs] Total number of obs record: "_numOfRecord)
        
        
        do ##class(CDUI.DataGen.LoadExternal).CreateVsArray(.CVsArray)
        do ##class(CDUI.DataGen.LoadExternal).CreateVsArray(.PVsArray)
        do PVsArray.SetAt(167,"Height")
        $$$LOGINFO("[LoadObs] empty CVsArray and PVsArray are created.")

        for Cnt = 1:1:numOfRecord{
            set ObsObj = ##class(CDUI.DataGen.MIMIC.CHARTEVENTS).%OpenId(Cnt)
            set icuStayId = ObsObj.icustayId
            set date = $EXTRACT(ObsObj.charttime,1,10)
            set hour = $EXTRACT(ObsObj.charttime,12,13)
            do ..CheckObsObj(ObsObj, CVsArray, .ObsType, .ObsValue, .AddToArray, .IsNewArray)


            #; if (ObsType = "Height"){
            #;     $$$LOGINFO("[LoadObs] Height value found: "_ObsValue)
            #; }

            if ((AddToArray = 1) && (IsNewArray = 0)){
                do ..SaveToArray("IcuStayId", icuStayId, .CVsArray)
                do ..SaveToArray("Date", date, .CVsArray)
                do ..SaveToArray("Hour", hour, .CVsArray)
                do ..SaveToArray(ObsType, ObsValue, .CVsArray)
            }
            
            if ((AddToArray = 1) && (IsNewArray = 1)){
                do ..SubmitCVsArray(.CVsArray, .PVsArray)
                do ..SaveToArray("IcuStayId", icuStayId, .CVsArray)
                do ..SaveToArray("Date", date, .CVsArray)
                do ..SaveToArray("Hour", hour, .CVsArray)
                do ..SaveToArray(ObsType, ObsValue, .CVsArray)
            }

            if (..IsArrayFull(CVsArray) = 1){
                do ..SubmitCVsArray(.CVsArray, .PVsArray)
            }
            }
}

ClassMethod test()
{
  
    set numOfRecord = 0
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.CHARTEVENTS)
    for Cnt = 1:1:numOfRecord{
        if Cnt<5000{
        set ObsObj = ##class(CDUI.DataGen.MIMIC.CHARTEVENTS).%OpenId(Cnt)
        do ..CheckObsItemId(ObsObj, .isNeeded, .ObsType, .ObsValue)
        #; $$$LOGINFO("[CheckObsItemId] obstype: "_ObsType_" obsValue: "_ObsValue_" isNeeded: "_isNeeded) 
        if ObsObj.itemId = 226730{
            $$$LOGINFO("[CheckObsItemId] Height value found: "_ObsValue)
        }     
        }

    }
}

ClassMethod test2()
{
    set list = $listfromstring(##class(Constants).#obsHeader,",")
    set PVsArray = ##class(%ArrayOfDataTypes).%New()
    set p = 0
    While $LISTNEXT(list,p,value){
        do PVsArray.SetAt("1",value)
    }
   
    set CVsArray = ##class(%ArrayOfDataTypes).%New()
    set p = 0
    While $LISTNEXT(list,p,value){
        do CVsArray.SetAt("2",value)
    }
   
    zw PVsArray
    zw CVsArray
    do ..CopyArrayValue(.CVsArray,.PVsArray)

    zw PVsArray
    zw CVsArray
    do ..ResetArray(CVsArray)
    zw PVsArray
    zw CVsArray
}

}
