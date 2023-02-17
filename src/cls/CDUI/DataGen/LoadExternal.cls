Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Include %syPrompt

Class CDUI.DataGen.LoadExternal Extends Ens.Util.IOLogger
{

// Create an array containing required keys, values are all empty

// Use info array to extract all required keys 

ClassMethod CreateArray(InfoArray As %ArrayOfDataTypes, Output OutArray As %ArrayOfDataTypes)
{
    set OutArray = ##class(%ArrayOfDataTypes).%New()
    set key = ""
    for {
        set val = InfoArray.GetNext(.key)
        quit:(key = "")
        do OutArray.SetAt("",key)
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

// Create an Array from two lists of the same size

ClassMethod FromListToArray(KeyList, ValueList, Output OutputArray As %ArrayOfDataTypes)
{
    set OutputArray = ##class(%ArrayOfDataTypes).%New()
    set length = $LISTLENGTH(KeyList)
    for i = 1:1:length {
        set arrayKey = $LIST(KeyList,i)
        set arrayValue = $list(ValueList,i)
        do OutputArray.SetAt(arrayValue, arrayKey)
    }
    #; while $LISTNEXT(KeyList,p,value){
    #;     set arrayKey = value
    #;     set arrayValue = $list(ValueList,p)
    #;     do OutputArray.SetAt(arrayValue, arrayKey)
    #; }
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

// Purpose: Convert from f to c

ClassMethod ConvertF(TempF As %Decimal)
{
    set TempC =  $fnumber(((TempF-32)*5/9),"",2)
    return TempC
}

// Purpose: Update the height column with same icustayid when a new height value is found

ClassMethod UpdateHeight(height As %Integer, icuStayId As %Integer)
{
    &sql(UPDATE CDUI_DataGen_MIMIC.Observations SET Height = :height WHERE IcuStayId = :icuStayId)
}

// create a dictionary containing column info(header name and datatype) of different modes

// Unachieved design: read from list of modeoptions, dynamically find the right parameters and construct a column dictionary

// Currently hardcoding

ClassMethod CreateColumnDic(Output ColumnDic)
{
    #; set ModeOptions = $LISTFROMSTRING(##class(Constants).#ModeOptions,",")
    set ListObs = $listfromstring(##class(Constants).#obsHeader,",")
    set ListObsDt = $listfromstring(##class(Constants).#obsHeaderType,",")
    do ..FromListToArray(ListObs,ListObsDt,.ObsArray)

    set ListFBC = $listfromstring(##class(Constants).#FBCHeader,",")
    set ListFBCDt = $listfromstring(##class(Constants).#FBCHeaderType,",")
    do ..FromListToArray(ListFBC,ListFBCDt,.FBCArray)

    set ColumnDic = ##class(%ArrayOfDataTypes).%New()
    do ColumnDic.SetAt(ObsArray,"Obs")
    do ColumnDic.SetAt(FBCArray,"FBC")
}

// create a dictionary containing itemId arrays of different modes

// Unachieved design: read from list of modeoptions, dynamically find the right parameters and construct a itemId dictionary

// currently hardcoding 

ClassMethod CreateItemIdDic(Output ItemIdDic)
{
    set ObsItemId = $listfromstring(##class(Constants).#ObsItemId,",")
    set ObsItemName = $listfromstring(##class(Constants).#ObsItemName,",")
    do ..FromListToArray(ObsItemId,ObsItemName,.ObsItemArray)

    set FBCItemId = $listfromstring(##class(Constants).#FBCItemId,",")
    set FBCItemName = $listfromstring(##class(Constants).#FBCItemName,",")
    do ..FromListToArray(FBCItemId,FBCItemName,.FBCItemArray)

    set ItemIdDic = ##class(%ArrayOfDataTypes).%New()
    do ItemIdDic.SetAt(ObsItemArray,"Obs")
    do ItemIdDic.SetAt(FBCItemArray,"FBC")
}

// Dynamically create a persistent class

// Note that if this method is used to update a table, datatype will be updated. New columns will be added but excess columns will not be deleted. 

ClassMethod NewPClass(ColumnInfo As %ArrayOfDataTypes, Name As %String = "CDUI.DataGen.MIMIC.TestTable")
{
    //if the Persistent class exists, delete it. Then create a new one. 
    if $$$comClassDefined(Name){
        $$$LOGINFO("[NewPClass] Class already exists. Delete and recreate the class.")
        DO $SYSTEM.SQL.Schema.DropTable(Name,1)
    }
    set clsDef = ##class(%Dictionary.ClassDefinition).%New()
    set clsDef.Name = Name
    set clsDef.Super = "%Persistent"
    $$$LOGINFO("[NewPClass] New persistent class created with "_Name)

    //read column name and data type from ColumnInfo
    set key = ""
    for {
        set val = ColumnInfo.GetNext(.key)
        quit:(key = "")
        set propDef = ##class(%Dictionary.PropertyDefinition).%New()
        set propDef.Name = key
        set propDef.Type = val
        do clsDef.Properties.Insert(propDef)
        $$$LOGINFO("[NewPClass] New Property "_ key_" is created with datatype "_val)
    }
    s sc =  clsDef.%Save()
    do $system.OBJ.Compile(Name,"ck")
}

// Check whether the instance has the wanted itemId, if Yes, return its item name and item value.

ClassMethod CheckItemId(Instance, ItemIdDic As %ArrayOfDataTypes, Output isNeeded As %Boolean, Output ItemName As %String, Output ItemValue As %Decimal)
{
    set itemId = Instance.ItemId
    set ItemValue = Instance.Value
    set isNeeded = 0
    set ItemName = "Not needed item"

    //check the dictionary array, if any key/itemID matches with itemId from the Instance, the item is needed 
    set key = ""
    for {
        set value = ItemIdDic.GetNext(.key)
        quit:(key = "")
        if key = itemId {
            set isNeeded = 1
            if 
            set ItemName = value
            quit 
        }
    }
    #; $$$LOGINFO("[CheckItemId] isNeeded: "_isNeeded_" ItemName: "_ItemName_" ItemValue: "_ItemValue)
}

// CheckSession, Type:"Obs","Res" 

// limitation: "instance" must have "SubjectId", "Date" and "Hour" 

ClassMethod CheckSession(Instance, Array As %ArrayOfDataTypes, Output IsCurrentSession As %Boolean)
{
    if Array.GetAt("Date") = ""{
        set IsCurrentSession = 1
    }
    else{
        set ArrayDate = Array.GetAt("Date")
        set ArrayHour = Array.GetAt("Hour")
        set ArrayId = Array.GetAt("SubjectId")
        set date = $EXTRACT(Instance.Charttime,1,10)
        set hour = $EXTRACT(Instance.Charttime,12,13)
        set id = Instance.SubjectId
        #; $$$LOGINFO("[CheckSession]date: "_date_" hour: "_hour_" id: "_id_" ArrayDate: "_ArrayDate)
        if ((id '= ArrayId) || (date '= ArrayDate)  || (hour '= ArrayHour)){
            set IsCurrentSession = 0
        }
        else{
            set IsCurrentSession = 1
        }
    }
}

// Mode: "FBC" or "Obs"

// Check whether the instance should be loaded into the submission array

ClassMethod CheckInstance(Instance, Mode As %String, ItemIdDic As %ArrayOfDataTypes, Array As %ArrayOfDataTypes, Output ItemName As %String, Output ItemValue As %Decimal, Output AddToArray As %Boolean, Output IsNewArray As %Boolean)
{
    //Initilize the dictionaries of targetTableColumn and itemId
    set ItemIdArray = ItemIdDic.GetAt(Mode)
    set IsNewArray = 0


    do ..CheckItemId(Instance, ItemIdArray, .isNeeded, .ItemName, .ItemValue)
    #; $$$LOGINFO("[CheckInstance]isNeeded: "_isNeeded_" ItemValue: "_ItemValue_" ItemName: "_ItemName)
    if isNeeded = 0{
        set AddToArray = 0
    }

    do ..CheckSession(Instance, Array, .IsCurrentSession)
    #; $$$LOGINFO("[CheckInstance]IsCurrentSession: "_IsCurrentSession)
    //If the ObsObj belongs to the new session
    if (isNeeded = 1) && (IsCurrentSession = 0){
        set AddToArray = 1
        set IsNewArray = 1
    }

    //if the ObsObj belongs to the current session, check whether there is any duplicated value in the CVsArray
    if (isNeeded = 1) && (IsCurrentSession = 1){
        if (..IsArrayKeyUsed(ItemName,Array) = 1){
            set AddToArray = 0
        }
        else{
            set AddToArray = 1
        }
    }
}

ClassMethod SubmitArray(Mode As %String, ByRef CArray As %ArrayOfDataTypes, ByRef PArray As %ArrayOfDataTypes)
{
    if Mode = "FBC"{
        set NewSet = ##class(CDUI.DataGen.MIMIC.FBCresult).%New()
        set NewSet.SubjectId = CArray.GetAt("SubjectId")
        set NewSet.Date = CArray.GetAt("Date")
        set NewSet.Hour = CArray.GetAt("Hour")
        set NewSet.WBC = CArray.GetAt("WBC")
        set NewSet.RBC = CArray.GetAt("RBC")
        set NewSet.HB = CArray.GetAt("HB")
        set NewSet.HCT = CArray.GetAt("HCT")
        set NewSet.MCV = CArray.GetAt("MCV")
        set NewSet.MCH = CArray.GetAt("MCH")
        set NewSet.MCHC = CArray.GetAt("MCHC")
        set NewSet.RDW = CArray.GetAt("RDW")
        set NewSet.PLT = CArray.GetAt("PLT")
    }
    elseif Mode = "Obs"{
        set NewSet = ##class(CDUI.DataGen.MIMIC.Observations).%New()
        set NewSet.SubjectId = CArray.GetAt("SubjectId")
        set NewSet.Date = CArray.GetAt("Date")
        set NewSet.Hour = CArray.GetAt("Hour")
        set NewSet.SBP = CArray.GetAt("SBP")
        set NewSet.DBP = CArray.GetAt("DBP")
        set NewSet.HeartRate = CArray.GetAt("HeartRate")
        set NewSet.Respirations = CArray.GetAt("Respirations")
        set NewSet.Temp = CArray.GetAt("Temp")
        set NewSet.Height = CArray.GetAt("Height")
        set NewSet.Weight = CArray.GetAt("Weight")
    }
    do NewSet.%Save()
    do ..CopyArrayValue(.CArray,.PArray)
    do ..ResetArray(CArray)
}

ClassMethod LoadExternal(Mode As %String)
{
    //initialize dictionaris, dunamically create arrays for columninfo and itemIdinfo 
    do ..CreateColumnDic(.ColumnDic)
    do ..CreateItemIdDic(.ItemIdDic)

    set ColumnInfo = ColumnDic.GetAt(Mode)
    set ItemIdInfo = ItemIdDic.GetAt(Mode)

    if Mode = "FBC"{
        set PClassName = "CDUI.DataGen.MIMIC.FBCresult"
        set SourcePClassName = "CDUI.DataGen.MIMIC.LABEVENTS"
        set SourceTableName = "CDUI_DataGen_MIMIC.LABEVENTS"
    }
    elseif Mode = "Obs"{
        set PClassName = "CDUI.DataGen.MIMIC.Observations"
        set SourcePClassName = "CDUI.DataGen.MIMIC.CHARTEVENTS"
        set SourceTableName = "CDUI_DataGen_MIMIC.CHARTEVENTS"
    }

    //Create target Pclass
    do ..NewPClass(ColumnInfo,PClassName)
    $$$LOGINFO("[LoadExternal] New persistent class created.")
 

    //Initialize submission arrays
    do ##class(CDUI.DataGen.LoadExternal).CreateArray(ColumnInfo, .CArray)
    do ##class(CDUI.DataGen.LoadExternal).CreateArray(ColumnInfo, .PArray)
    set ArraySubmitted = 0
    $$$LOGINFO("[LoadExternal] Initialize CArray and PArray.")
    
    //get number of records
    set numOfRecord = 0
    set query($increment(query)) = "SELECT COUNT(*) As CT FROM "_SourceTableName
    set result = ##class(%SQL.Statement).%ExecDirect(,.query)
    set sc = result.%Next()
    set numOfRecord = result.%Get("CT")
    $$$LOGINFO("[LoadExternal] Total number of records from "_SourcePClassName_". source table: "_numOfRecord)

    //check every row of the source table
    for Cnt = 1:1:numOfRecord{
        Set Instance = $classmethod(SourcePClassName,"%OpenId",Cnt,0,.sc)
        do ##class(CDUI.DataGen.LoadExternal).CheckInstance(Instance, Mode, ItemIdDic, CArray, .ItemName, .ItemValue, .AddToArray, .IsNewArray)

        #; $$$LOGINFO("[LoadExternal]Itemname: "_ItemName_" ItemValue: "_ItemValue_" AddToArray: "_AddToArray_" IsNewArray: "_IsNewArray)
        set subjectId = Instance.SubjectId
        set date = $EXTRACT(Instance.Charttime,1,10)
        set hour = $EXTRACT(Instance.Charttime,12,13)
        if ((AddToArray = 1) && (IsNewArray = 0)){
            do ..SaveToArray("SubjectId", subjectId, .CArray)
            do ..SaveToArray("Date", date, .CArray)
            do ..SaveToArray("Hour", hour, .CArray)
            do ..SaveToArray(ItemName, ItemValue, .CArray)
        }
        
        if ((AddToArray = 1) && (IsNewArray = 1)){
            set ArraySubmitted = ArraySubmitted + 1 
            do ..SubmitArray(Mode,.CArray, .PArray)
            do ..SaveToArray("SubjectId", subjectId, .CArray)
            do ..SaveToArray("Date", date, .CArray)
            do ..SaveToArray("Hour", hour, .CArray)
            do ..SaveToArray(ItemName, ItemValue, .CArray)
        }

        if (..IsArrayFull(CArray) = 1){
            set ArraySubmitted = ArraySubmitted + 1 
            do ..SubmitArray(Mode,.CArray, .PArray)
        } 
        #;  $$$LOGINFO("[LoadExternal] Total Count: "_numOfRecord_". Current count: "_Cnt)
    }
    $$$LOGINFO("[LoadExternal] Successfully loaded "_Mode_" data, "_ArraySubmitted_" entries created.")
}

ClassMethod CleanVS()
{
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.CHARTEVENTfull)
    for i = 1:1:numOfRecord {
        set ObsObj = ##class(CDUI.DataGen.MIMIC.CHARTEVENTfull).%OpenId(i)
        set ObsObj.Temp = ..ConvertF(ObsObj.Temp)
        do ObsObj.%Save()
    }
}

ClassMethod CleanVS2()
{
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.CHARTEVENTfull)
    for i = 1:1:numOfRecord {
        set ObsObj = ##class(CDUI.DataGen.MIMIC.CHARTEVENTfull).%OpenId(i)
        if ObsObj.Temp < 0 {
            set ObsObj.Temp = ""
        }
        
        do ObsObj.%Save()
    }
}

}
