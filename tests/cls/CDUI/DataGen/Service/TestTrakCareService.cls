Import (CDUI.DataGen.Utils, CDUI.DataGen.DataGenService.Base)

Class CDUI.DataGen.Service.TestTrakCareService Extends (%UnitTest.TestCase, BaseService)
{

Method TestGetARCAuxilInsurType() As %Status
{
    #dim status, sc as %Status = $$$OK
    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetARCAuxilInsurType(,,,.results)
    set status = $$$AssertStatusOK(sc,"Get Insurance List")
    
    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if Insurance List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Insurance List")

        set sc = $$$AssertEquals("CDUI.DataGen.vo.ARCAuxilInsurTypeVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

Method TestGetARCItmMast() As %Status
{
    #dim status, sc as %Status = $$$OK
    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetARCItmMast(,,,.results)
    set status = $$$AssertStatusOK(sc,"Get Order Item List")
    
    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if Order Item List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Order Item List")

        set sc = $$$AssertEquals("CDUI.DataGen.vo.ARCItmMasVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

Method TestGetLocation() As %Status
{
    #dim status, sc as %Status = $$$OK
    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetLocation(,,,,,.results)
    set status = $$$AssertStatusOK(sc,"Get Location List")
    
    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if Get Location List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Get Location List")

        set sc = $$$AssertEquals("CDUI.DataGen.vo.LocationVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

Method TestGetLocationServices() As %Status
{
    #dim status, sc as %Status = $$$OK
    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetLocationServices(,.results)
    set status = $$$AssertStatusOK(sc,"Get Location Service List")
    
    if $$$ISOK(status)
	{
        
        do $$$LogMessage("Check if Location is 241 Cardiology H1 for appointments creation")
        set val = results.GetAt(1).Loc
        set sc = $$$AssertEquals(241,val,"Loc is 241")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check if Get Location Service List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Get Location Service List")
        set sc = $$$AssertEquals("CDUI.DataGen.vo.LocationServicesVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)
        
        do $$$LogMessage("Check count of Get Location Service List")
        set val = results.Count()
        set sc = $$$AssertEquals(5,val,"Correct count of 5 services id returned")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

Method TestGetSlots() As %Status
{
    #dim sc, status as %Status = $$$OK

    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetLocationServices(,.locServObjList)
    set status = $$$AssertStatusOK(sc,"Get Location Services List")

    // Get random service id
    set randServIndex = ##class(PUtil).Random(locServObjList.Count()) + 1
    set servItem = locServObjList.GetAt(randServIndex)
    set servId = servItem.RowID

    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetSlots(241,servId,,,.results)
    set status = $$$AssertStatusOK(sc,"Get Slots List")

    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if Slots List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Slots List")
        set sc = $$$AssertEquals("CDUI.DataGen.vo.SlotVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

Method TestGetCareProvider() As %Status
{
    #dim sc, status as %Status = $$$OK

    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetCareProvider(.results)
    set status = $$$AssertStatusOK(sc,"Get Care Provider List")

    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if CareProviderList contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check CareProviderList's last value")
        set sc = $$$AssertEquals(1408,results.GetAt(50),"If Data(50) = 1408")
        set status = $$$ADDSC(status,sc)
    }
    quit status
}

Method TestGetOrderByCat() As %Status
{
    #dim sc, status as %Status = $$$OK

    set category = "Radiology"
    set sc = ##class(CDUI.DataGen.DataGenService.TrakCareService).GetOrderByCat(10,category,.results)
    set status = $$$AssertStatusOK(sc,"Get Order Items List by Category Radiology")

    if $$$ISOK(status)
	{
        do $$$LogMessage("Check if Order Items List contains data")
        set sc = $$$AssertEquals(1,$DATA(results),"Contains data")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check type of Order Items List")
        set sc = $$$AssertEquals("CDUI.DataGen.vo.OrderCatVo",$CLASSNAME(results.GetAt(1)),"Data belongs to correct class")
        set status = $$$ADDSC(status,sc)

        do $$$LogMessage("Check if order's category is Radiology")
        set val = results.GetAt(1).ORCATDesc
        set sc = $$$AssertEquals("Radiology",val,"Category is correct")
        set status = $$$ADDSC(status,sc)
    }

    quit status
}

}
