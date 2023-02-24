Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService)

Class CDUI.DataGen.DataGenService.Cache.LocationService Extends Ens.Util.IOLogger
{

Parameter PageSize = 500;

Parameter DefaultTimeout = 5;

Parameter locationTypeId = "E";

ClassMethod GetLocationByRandom(Output jsonStr, Output index)
{
    do ..checkSetup()
    set jsonStr = ""
    set index = 0
    set key = ##class(PUtil).Random(^DataGen.Cache("Location","maxIndex")) + 1
    set result = $Get(^DataGen.Cache("Location", "r", key),"")
    if result = "" {
        //If it is not found via the index, then get the next item from the cache
        set key = $Order(^DataGen.Cache("Location","r", key), 1)
        //If it is not found by using the index next to the specified index, then get the preivou item from the cache
        if key = "" {
            set key = $Order(^DataGen.Cache("Location","r", key), -1)
        }
        //If it is found, return it back
        if key '= "" {
            set jsonStr = $Get(^DataGen.Cache("Location", "r", key),"")
            set index = key
        }
    } else {
        set jsonStr = $Get(^DataGen.Cache("Location", "r", key),"")
        set index = key
    }
}

ClassMethod clearCache()
{
      $$$LOGINFO("[LocationService.clearCache] Start to clear")

    
    set locked = 0
    Try {
        TSTART
        LOCK +^DataGen.Cache("Location"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[LocationService.clearCache] Failed to remove item.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.LocationService","Failed to get an exclusive lock.")
        }

        set locked = 1
        kill ^DataGen.Cache("Location")
        TCOMMIT
        $$$LOGINFO("[LocationService.clearCache] Finished clearing")
    } Catch exception {
        if locked {
            Lock -^DataGen.Cache("Location")
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod checkSetup() [ Private ]
{
    if ($Order(^DataGen.Cache("Location","")) = "") {
        do ..InitGlobalVariable()
    }
}

ClassMethod InitGlobalVariable() [ Private ]
{
    $$$LOGINFO("[LocationService.InitGlobalVariable] start initializing global variable.")
    Set locked = 0
    Try {

        set sc = ##class(TrakCareService).GetLocation(,1,..#locationTypeId,..#PageSize,, .locationObjList)
        if $$$ISERR(sc)
        {
            $$$LOGERROR("[LocationService.InitGlobalVariable] Failed to get Locations.")
            Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
        }
        
        if locationObjList.Count() = 0 {
            $$$LOGINFO("[LocationService.InitGlobalVariable] No Location record.")
            return
        }

        TSTART
        Lock +^DataGen.Cache("Location"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[LocationService.InitGlobalVariable] Failed to initialize global variable.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.ARCAuxilInsurTypeService","Failed to get an exclusive lock.")
        }
        set locked = 1
        if ($Data(^DataGen.Cache("Location")) = 0){
            set ^DataGen.Cache("Location") = locationObjList.Count()
            set ^DataGen.Cache("Location","maxIndex") = locationObjList.Count()
            set ^DataGen.Cache("Location","minIndex") = 1
            set ^DataGen.Cache("Location","createDateTime") = $ZDATETIME($HOROLOG,3,7)
            set ^DataGen.Cache("Location","lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)
            for cnt=1:1:locationObjList.Count(){
                set ^DataGen.Cache("Location","r", cnt) = locationObjList.GetAt(cnt).SerialisedGet()
            }
            
        } else {
            $$$LOGINFO("[LocationService.InitGlobalVariable] Global variable is already created.")
        }
        Lock -^DataGen.Cache("Location")

        TCOMMIT
        $$$LOGINFO("[LocationService.InitGlobalVariable] Finished initializing global variable.")
   
    } catch exception {
        if locked {
            Lock -^DataGen.Cache("Location")
        }
        TROLLBACK 
        Throw exception
    }
}

ClassMethod RemoveItem(index As %Integer) As %Integer
{
    $$$LOGINFO("[LocationService.RemoveItem] index: "_index)

    if ($Order(^DataGen.Cache("Location","r", index)) = "") {
        $$$LOGINFO("[LocationService.RemoveItem] The Location cache is empty.")
        return -1
    }

    
    set locked = 0
    Try {
        TSTART
        LOCK +^DataGen.Cache("Location"):..#DefaultTimeout

        if '$TEST {
            $$$LOGINFO("[LocationService.RemoveItem] Failed to remove item.")
            Throw ##class(%Exception.General).%New("ExclusiveLockException",5372,"CDUI.DataGen.DataGenService.Cache.LocationService","Failed to get an exclusive lock.")
        }

        set locked = 1
        kill ^DataGen.Cache("Location", "r", index)
        set ^DataGen.Cache("Location") = ^DataGen.Cache("Location") -1
        set ^DataGen.Cache("Location","lastUpdateDateTime") = $ZDATETIME($HOROLOG,3,7)
        Lock -^DataGen.Cache("Location")
        TCOMMIT
        $$$LOGINFO("[LocationService.RemoveItem] Finished removing an item. index: "_index)
        return 1
    } Catch exception {
        if locked {
            Lock -^DataGen.Cache("Location")
        }
        TROLLBACK 
        Throw exception
    }
}

}
