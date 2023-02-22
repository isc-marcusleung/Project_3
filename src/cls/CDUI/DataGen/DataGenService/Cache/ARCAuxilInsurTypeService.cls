Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService Extends Ens.Util.IOLogger
{

Parameter PageSize = 500;

Parameter DefaultTimeout = 5;

ClassMethod GetInsurTypeByRandom(Output jsonStr, Output index)
{
    do ..checkSetup()
    set jsonStr = ""
    set index = 0
    set key = ##class(PUtil).Random(^DataGen.Cache("InsurType","maxIndex")) + 1
    set result = $Get(^DataGen.Cache("InsurType", key),"")
    if result = "" {
        //If it is not found via the index, then get the next item from the cache
        set key = $Order(^DataGen.Cache("InsurType", key), 1)
        //If it is not found by using the index next to the specified index, then get the preivou item from the cache
        if key = "" {
            set key = $Order(^DataGen.Cache("InsurType", key), -1)
        }
        //If it is found, return it back
        if key '= "" {
            set jsonStr = $Get(^DataGen.Cache("InsurType", key),"")
            set index = key
        }
    } else {
        set jsonStr = $Get(^DataGen.Cache("InsurType", key),"")
        set index = key
    }
}

ClassMethod clearCache()
{
      $$$LOGINFO("[ARCAuxilInsurTypeService.clearCache] Start to clear")

    set locked = 0
    Try {
        TSTART
        LOCK +^DataGen.Cache("InsurType"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[ARCAuxilInsurTypeService.clearCache] Failed to remove item.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService","Failed to get an exclusive lock.")
        }

        set locked = 1
        kill ^DataGen.Cache("InsurType")
        TCOMMIT
        $$$LOGINFO("[ARCAuxilInsurTypeService.clearCache] Finished clearing")
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Cache("InsurType")
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod checkSetup() [ Private ]
{
    if ($Order(^DataGen.Cache("InsurType","")) = "") {
        do ..InitGlobalVariable()
    }
}

ClassMethod InitGlobalVariable() [ Private ]
{
    $$$LOGINFO("[ARCAuxilInsurTypeService.InitGlobalVariable] start initializing global variable.")
    Set locked = 0
    Try {
        set sc = ##class(TrakCareService).GetARCAuxilInsurType(1, ..#PageSize,,.insurTypeObjList)
        if $$$ISERR(sc)
        {
            $$$LOGERROR("[ARCAuxilInsurTypeService.InitGlobalVariable] Failed to get ARCAuxilInsurTypes.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        
        if insurTypeObjList.Count() = 0 {
            $$$LOGINFO("[ARCAuxilInsurTypeService.InitGlobalVariable] No insurType record.")
            return
        }

        TSTART
        Lock +^DataGen.Cache("InsurType"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[ARCAuxilInsurTypeService.InitGlobalVariable] Failed to initialize global variable.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService","Failed to get an exclusive lock.")
        }
        set locked = 1
        if ($Data(^DataGen.Cache("InsurType")) = 0){
            set ^DataGen.Cache("InsurType") = insurTypeObjList.Count()
            set ^DataGen.Cache("InsurType","maxIndex") = insurTypeObjList.Count()
            set ^DataGen.Cache("InsurType","minIndex") = 1
            set ^DataGen.Cache("InsurType","createDateTime") = $ZDATETIME($HOROLOG,3,7)
            set ^DataGen.Cache("Location","lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)
            for cnt=1:1:insurTypeObjList.Count(){
                set ^DataGen.Cache("InsurType",cnt) = insurTypeObjList.GetAt(cnt).SerialisedGet()
            }
            
        } else {
            $$$LOGINFO("[ARCAuxilInsurTypeService.InitGlobalVariable] Global variable is already created.")
        }
        Lock -^DataGen.Cache("InsurType")

        TCOMMIT
        $$$LOGINFO("[ARCAuxilInsurTypeService.InitGlobalVariable] Finished initializing global variable.")
   
    } catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Cache("InsurType")
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod RemoveItem(index As %Integer) As %Integer
{
    $$$LOGINFO("[ARCAuxilInsurTypeService.RemoveItem] index: "_index)

    if ($Order(^DataGen.Cache("InsurType",index)) = "") {
        $$$LOGINFO("[ARCAuxilInsurTypeService.RemoveItem] The insurType cache is empty.")
        return -1
    }
    set locked = 0
    Try {
        TSTART
        LOCK +^DataGen.Cache("InsurType"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[ARCAuxilInsurTypeService.RemoveItem] Failed to remove item.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService","Failed to get an exclusive lock.")
        }

        set locked = 1
        kill ^DataGen.Cache("InsurType", index)
        set ^DataGen.Cache("InsurType") = ^DataGen.Cache("InsurType") -1
        set ^DataGen.Cache("Location","lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)
        Lock -^DataGen.Cache("InsurType")
        TCOMMIT
        $$$LOGINFO("[ARCAuxilInsurTypeService.RemoveItem] Finished removing an item. index: "_index)
        return 1
    } Catch exception {
        do LOG^%ETN
        if locked {
            Lock -^DataGen.Cache("InsurType")
        }
        TROLLBACK 
        Throw exception
    }
}

}
