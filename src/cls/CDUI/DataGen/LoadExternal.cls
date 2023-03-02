Import (CDUI.DataGen.Utils, CDUI.DataGen.Common)

Include %syPrompt

Class CDUI.DataGen.LoadExternal Extends Ens.Util.IOLogger
{

/** The class methods are commented out as they are only used once when loading and restructuring external datasets.

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

// Purpose: Reset the input array, keep keys, replace all values with ""

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

// Purpose: check whether the key already has a value attached to it in the input array  

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

// key:Obs    value: an itemId array of observations 

// key:FBC    value: an itemId array of FBC results 

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

// Dynamically create a persistent class by providing Column Info(column name and respective datatype), new table name, new class name 

// If a table with the same name exists, drop it.

ClassMethod NewPClass(ColumnInfo As %ArrayOfDataTypes, TableName As %String = "CDUI_DataGen_MIMIC.TestTable", ClassName As %String = "CDUI.DataGen.MIMIC.TestTable")
{
    //if the Persistent class exists, delete it. Then create a new one. 
    if $$$comClassDefined(TableName){
        $$$LOGINFO("[NewPClass] Class already exists. Delete and recreate the class.")
        DO $SYSTEM.SQL.Schema.DropTable(TableName,1)
    }

    //define class name 
    set clsDef = ##class(%Dictionary.ClassDefinition).%New()
    set clsDef.Name = ClassName
    set clsDef.Super = "%Persistent"
    $$$LOGINFO("[NewPClass] New persistent class created with "_TableName)

    //define property name and property data type from ColumnInfo
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

    //save and compile the persistent class
    s sc =  clsDef.%Save()
    do $system.OBJ.Compile(ClassName,"ck")
}

// Check whether the instance(a row from the original table) has the wanted itemId, if Yes, return its item name and item value.

// ItemIdArray has been selected from ItemIdDic 

ClassMethod CheckItemId(Instance, ItemIdArray As %ArrayOfDataTypes, Output isNeeded As %Boolean, Output ItemName As %String, Output ItemValue)
{
    set itemId = Instance.ItemId
    set ItemValue = Instance.Value
    set isNeeded = 0
    set ItemName = "Not needed item"

    //loop through the itemID array from the dictionary, if any key/itemID matches with itemId from the Instance, the item is needed 
    set key = ""
    for {
        set value = ItemIdArray.GetNext(.key)
        quit:(key = "")
        if key = itemId {
            set isNeeded = 1
            set ItemName = value
            quit 
        }
    }
}

// Check the SubjectId, Date and Hour combination of the Instance, compare with the combination in current submission array, to determine whether the current submission array's session has finished. 

// limitation: "instance" must have "SubjectId", "Date" and "Hour" 

ClassMethod CheckSession(Instance, Array As %ArrayOfDataTypes, Output IsCurrentSession As %Boolean)
{
    //if current submission array is empty, do not start a new session 
    if Array.GetAt("Date") = ""{
        set IsCurrentSession = 1
    }
    else{
        set ArrayDate = Array.GetAt("Date")
        set ArrayHour = Array.GetAt("Hour")
        set ArrayId = Array.GetAt("SubjectId")
        do ..extractDH(Instance.Charttime, .date, .time)
        set hour = $EXTRACT(time,1,2)
        set id = Instance.SubjectId

        //if any value of date, hour, subjectid does not match, the current session is finished and a new session is about to begin
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

// Check whether the instance contains the needed item, check whether the instance belongs to which session

// !!! item name in the submission array must be the same as name in the Instance(row in the original table)

ClassMethod CheckInstance(Instance, Mode As %String, ItemIdDic As %ArrayOfDataTypes, Array As %ArrayOfDataTypes, Output ItemName As %String, Output ItemValue, Output AddToArray As %Boolean, Output IsNewArray As %Boolean)
{
    //Find the right ItemId array in the ItemId dictionary
    set ItemIdArray = ItemIdDic.GetAt(Mode)
    set IsNewArray = 0

    do ..CheckItemId(Instance, ItemIdArray, .isNeeded, .ItemName, .ItemValue)
    if isNeeded = 0{
        set AddToArray = 0
    }

    do ..CheckSession(Instance, Array, .IsCurrentSession)
    //If the item is needed and it belongs to the new session
    if (isNeeded = 1) && (IsCurrentSession = 0){
        set AddToArray = 1
        set IsNewArray = 1
    }

    //if the item belongs to the current session, check whether the key is used in the current submission array
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
        set NewPClassName = "CDUI.DataGen.MIMIC.FBCresult"
        set NewTableName = "CDUI_DataGen_MIMIC.FBCresult"
        set SourcePClassName = "CDUI.DataGen.MIMIC.LABEVENTSfull"
        set SourceTableName = "CDUI_DataGen_MIMIC.LABEVENTSfull"
    }
    elseif Mode = "Obs"{
        set NewPClassName = "CDUI.DataGen.MIMIC.Observations"
        set NewTableName = "CDUI_DataGen_MIMIC.Observations"
        set SourcePClassName = "CDUI.DataGen.MIMIC.CHARTEVENTS"
        set SourceTableName = "CDUI_DataGen_MIMIC.CHARTEVENTS"
    }

    //Create target Pclass
    do ..NewPClass(ColumnInfo,NewTableName,NewPClassName)
    $$$LOGINFO("[LoadExternal] New persistent class created.")
 

    //Initialize submission arrays
    do ..CreateArray(ColumnInfo, .CArray)
    do ..CreateArray(ColumnInfo, .PArray)
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
        do ..extractDH(Instance.Charttime, .date, .time)
        set hour = $EXTRACT(time,1,2)
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

ClassMethod ConvertTemp()
{
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.TriageNew)
    for i = 1:1:numOfRecord {
        set ObsObj = ##class(CDUI.DataGen.MIMIC.TriageNew).%OpenId(i)
        if ObsObj.Temp '= ""{
            set ObsObj.Temp = ..ConvertF(ObsObj.Temp)
        }
        do ObsObj.%Save()
    }
}

ClassMethod RemoveEmptyTriage()
{
    &sql(SELECT COUNT(*) INTO :numOfRecord FROM CDUI_DataGen_MIMIC.TriageOriginal)
    for i = 1:1:numOfRecord {
        set ObsObj = ##class(CDUI.DataGen.MIMIC.TriageOriginal).%OpenId(i)
        if (ObsObj.Temp = "") &&(ObsObj.Respirations = "")&&(ObsObj.HeartRate = "") {
        }
        else{
            do ..InsertToTriageNew(ObsObj)
        }
    }
}

ClassMethod InsertToTriageNew(Instance)
{
    set newInstance =  ##class(CDUI.DataGen.MIMIC.TriageNew).%New()
    set newInstance.Temp = Instance.Temp
    set newInstance.HeartRate = Instance.HeartRate
    set newInstance.Respirations = Instance.Respirations
    set newInstance.O2Sat = Instance.O2Sat
    set newInstance.SBP = Instance.SBP
    set newInstance.DBP = Instance.DBP
    do newInstance.%Save()
}

ClassMethod InsertToLABNew(Instance)
{
    set newInstance =  ##class(CDUI.DataGen.MIMIC.LABEVENTSfull).%New()
    set newInstance.Temp = Instance.Temp
    set newInstance.HeartRate = Instance.HeartRate
    set newInstance.Respirations = Instance.Respirations
    set newInstance.O2Sat = Instance.O2Sat
    set newInstance.SBP = Instance.SBP
    set newInstance.DBP = Instance.DBP
    do newInstance.%Save()
}
// extract date and time from stamptime, add missing zeros

// so that they can be read properly when restructiong a new table

// orignially stamptime is stored in a form of "5/08/2180 0:20"


ClassMethod extractDH(stamptime As %String, Output dateDnew As %String, Output timeDnew As %String)
{
    //get dateD and timeD from stamptime
    set dateD = $PIECE(stamptime," ",1)
    set timeD = $PIECE(stamptime," ",2)

    //convert to dateH and timeH
    set timeH = $ztimeH(timeD,2)
    set dateH = $zdateH(dateD,4)

    //convert back to dateD and timeD, add missing zeros
    set dateDnew = $zdate(dateH,4)
    set timeDnew = $ztime(timeH,2)
}

// Use name of the schema as input, not name of the persistent class 

ClassMethod dropTable(Name As %String = "CDUI_DataGen_MIMIC.FBCresult")
{
    set sc =  $SYSTEM.SQL.Schema.DropTable(Name,1)
}

}
*/
}
