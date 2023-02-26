/// Business logic class defined by OpenAPI in Custom.CDUI.REST.spec<br/>
/// Updated Feb 6, 2023 07:05:40
Class Custom.CDUI.REST.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Get ...<br/>
/// The method arguments hold values for:<br/>
///     _count, Number of records<br/>
///     category, Order category for filter<br/>
/// WARNING: This method's signature has changed.
/// 
/// ClassMethod GetOrders(RowCount As %Integer = "", category As %String = "") As %DynamicObject
/// 
ClassMethod GetOrders(RowCount As %Integer = "", category As %String = "") As %DynamicObject
{
	// If RowCount is not specified, return 65 records
	if (RowCount = "") {
		set RowCount = 65
	}

	set ret={}
	set dynArray=[]
	set count = 0

	&SQL(DECLARE OrdCursor CURSOR FOR 

		SELECT Top :RowCount
		ORCAT_Desc, ARCIM_RowId, ARCIM_EffDate
		into :ORCATDesc, :ID, :ARCIMEffDate
		FROM (
			SELECT ORCAT_Desc, ARCIM_RowId, ARCIM_EffDate 

			FROM SQLUser.ARC_LabTestSet 	-- get test set
			RIGHT JOIN SQLUser.ARC_ItmMast  -- order item
			ON ARCIM_RowId = ARCTS_ParRef  

			INNER JOIN SQLUser.ARC_ItemCat   -- order subcategory
			ON ARCIM_ItemCat_DR =  ARCIC_RowId

			INNER JOIN SQLUser.OEC_OrderCategory  -- order category
			ON ORCAT_RowId = ARCIC_OrdCat_DR

			WHERE ( 
				(ARCIM_EffDateTo IS NULL )  -- active orders only 
				AND (ARCIM_OrderOnItsOwn LIKE '%Y%') -- OrderOnItsOwn box ticked
				AND (ARCTS_DateTo IS NULL) -- active test sets only
				AND ( (ORCAT_Desc IN  ('Consultation', 'Radiology') AND (ARCTS_TestSet_DR IS NULL) ) OR ((ORCAT_Desc ='Laboratory') AND (ARCTS_TestSet_DR IS NOT NULL)) ) -- select lab orders that have a test set only
				AND (ORCAT_Desc = :category) OR (:category IS NULL) -- category is specified or category is not specified
			
			)
		)
	)

	&sql(OPEN OrdCursor)
		QUIT:(SQLCODE'=0)

	for {
		&sql(FETCH OrdCursor)
		QUIT:SQLCODE
			do ret.%Set("ORCATDesc", ORCATDesc)
			do ret.%Set("ID", ID)
			do ret.%Set("ARCIMEffDate", ARCIMEffDate)
			do dynArray.%Set(count, ret)
			set ret={}
			set count = count + 1
		}
	&sql(CLOSE OrdCursor)
	
	set results = {}.%Set("results",dynArray)
	set results."count" = count
	quit results
}

/// Get ...
ClassMethod GetCareProviders() As %DynamicObject
{
	set ret={}
	set dynArray=[]
	set count = 0

	&SQL(DECLARE CPCursor CURSOR FOR 
			SELECT Top 50 CTPCP_RowId1 into :DoctorID
			FROM SQLUser.CT_CareProv
		)

		&sql(OPEN CPCursor)
			QUIT:(SQLCODE'=0)

		for {
			&sql(FETCH CPCursor)
			QUIT:SQLCODE
				do ret.%Set("DoctorID", DoctorID)
				do dynArray.%Set(count, ret)
				set ret={}
				set count = count + 1
			}
		
		&sql(CLOSE CPCursor)
		
		set results = {}.%Set("results",dynArray)
		set results."count" = count
		quit results
}

}
