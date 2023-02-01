/// Business logic class defined by OpenAPI in Custom.CDUI.REST.spec<br/>
/// Updated Jan 17, 2023 03:41:40
Class Custom.CDUI.REST.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Get ...<br/>
/// The method arguments hold values for:<br/>
///     _count, Number of records<br/>
///     category, Order category for filter<br/>
/// WARNING: This method's signature has changed.
ClassMethod GetOrders(RowCount As %Integer = "", category As %String = "") As %DynamicObject
{

	set numRow = RowCount
	set ret={}
	set dynArray=[]
	set count = 0

	#; If no category or RowCount, return 50 records 
	if ((RowCount = "") && (category = ""))
	{
		&SQL(DECLARE OrdCursor CURSOR FOR 
			SELECT Top 50
			ARCIM_ItemCat_DR->ARCIC_OrdCat_DR->ORCAT_Desc, ARCIM_RowId, ARCIM_EffDate
			into :ORCATDesc, :ID, :ARCIMEffDate
			FROM SQLUser.ARC_ItmMast
		)

		&sql(OPEN OrdCursor)
			QUIT:(SQLCODE'=0)

		for {
			&sql(FETCH OrdCursor)
			QUIT:SQLCODE
				do ret.%Set("ORCATDesc", ORCATDesc)
				do ret.%Set("ID", ID)
				do ret.%Set("ARCIMEffDate", ARCIMEffDate)
				#; do dynArray.%Set(%ROWCOUNT - 1, ret)
				do dynArray.%Set(count, ret)
				set ret={}
				set count = count + 1
			}
		
		&sql(CLOSE OrdCursor)
		
		set results = {}.%Set("results",dynArray)
		set results."count" = count
		quit results
	}

	#; If category is specified, return 50 records only for that category
	elseif ((category '= "") && (RowCount = "")) 
	{
		&SQL(DECLARE OrdCursor1 CURSOR FOR 
			SELECT Top 50
			ARCIM_ItemCat_DR->ARCIC_OrdCat_DR->ORCAT_Desc, ARCIM_RowId, ARCIM_EffDate
			into :ORCATDesc, :ID, :ARCIMEffDate
			FROM SQLUser.ARC_ItmMast where ARCIM_ItemCat_DR->ARCIC_OrdCat_DR->ORCAT_Desc = :category
		)

		&sql(OPEN OrdCursor1)
			QUIT:(SQLCODE'=0)

		for {
			&sql(FETCH OrdCursor1)
			QUIT:SQLCODE
				do ret.%Set("ORCATDesc", ORCATDesc)
				do ret.%Set("ID", ID)
				do ret.%Set("ARCIMEffDate", ARCIMEffDate)
				#; do dynArray.%Set(%ROWCOUNT - 1, ret)
				do dynArray.%Set(count, ret)
				set ret={}
				set count = count + 1
			}
		&sql(CLOSE OrdCursor1)
		
		set results = {}.%Set("results",dynArray)
		set results."count" = count
		quit results
	}

	elseif ((category '= "") && (RowCount '= "")) 
	{
		&SQL(DECLARE OrdCursor2 CURSOR FOR 
			SELECT Top :RowCount
			ARCIM_ItemCat_DR->ARCIC_OrdCat_DR->ORCAT_Desc, ARCIM_RowId, ARCIM_EffDate
			into :ORCATDesc, :ID, :ARCIMEffDate
			FROM SQLUser.ARC_ItmMast where ARCIM_ItemCat_DR->ARCIC_OrdCat_DR->ORCAT_Desc = :category
		)

		&sql(OPEN OrdCursor2)
			QUIT:(SQLCODE'=0)

		for {
			&sql(FETCH OrdCursor2)
			QUIT:SQLCODE
				do ret.%Set("ORCATDesc", ORCATDesc)
				do ret.%Set("ID", ID)
				do ret.%Set("ARCIMEffDate", ARCIMEffDate)
				#; do dynArray.%Set(%ROWCOUNT - 1, ret)
				do dynArray.%Set(count, ret)
				set ret={}
				set count = count + 1
			}
		&sql(CLOSE OrdCursor2)
		
		set results = {}.%Set("results",dynArray)
		set results."count" = count
		quit results
	}
}

}
