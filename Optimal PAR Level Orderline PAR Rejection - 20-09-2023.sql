select TOP 10
 CAST (CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()) AS DATE)			            AS Report_Date
,CLNDR.DAY_NM                                               					            AS Report_Date_Day_Name
,CLNDR.FIS_WK                                               					            AS Report_Date_Fiscal_Week
,CLNDR.FIS_MTH                                              					            AS Report_Date_Fiscal_Month
,CLNDR.FIS_QTR                                              					            AS Report_Date_Fiscal_Quarter
,CLNDR.FIS_YR                                               					            AS Report_Date_Fiscal_Year
,CP_SALES_ORD_HDR.ORD_CREATE_DT                                      			            AS Order_Create_Date
,CP_SALES_ORD_DTL.PLANT_ID                                           			            AS Plant
,CP_SALES_ORD_DTL.STOR_LOC_ID                                        			            AS Storage_Location
,CONCAT (CP_SALES_ORG.SALES_ORG_DESC,' (',CP_SALES_ORD_HDR.SALES_ORG_ID,')')  	            AS Sales_Organization
,CP_SALES_ORD_HDR.SALES_OFFICE_ID                                    			            AS Sales_Office
,CP_SALES_ORD_HDR.SOLD_TO_CUST_ID                                    			            AS SoldTo_Number
,CP_CUST_SOLDTO.CUST_NM                                        					            AS SoldTo_Customer
,CP_SALES_ORD_HDR.SHIP_TO_CUST_ID                                    			            AS ShipTo_Number
,CP_CUST_SHIPTO.CUST_NM                                        					            AS ShipTo_Customer
,CP_CUST_SHIPTO.CITY_NM                                        					            AS ShipTo_City
,CP_CUST_SHIPTO.CNTRY_ID                                       					            AS ShipTo_Country_ID
,CP_CUST_SHIPTO.CNTRY_NM                                       					            AS ShipTo_Country_Name
,CP_SALES_ORD_DTL.DLVRY_PRIO_ID_SALES_ORD                      					            AS Delivery_Prio
,CAST (CP_SALES_ORD_DTL_SCHED.SCHED_LN_DT as date)                                          AS Requested_Delivery_Date
,CP_SALES_ORD_HDR.SALES_ORD_ID                                       			            AS Sales_Order
,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM                                   			            AS Sales_Orderline
,CONCAT(CP_SALES_ORD_HDR.SALES_ORD_ID,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM)      	            AS Unique_Line_Value
,CP_MATL.OU_HRCHY_OU_DESC                                      					            AS Operating_Unit
,CP_MATL.OU_HRCHY_IOU_LONG                                     					            AS Sub_Operating_Unit
,CP_SALES_ORD_DTL.MPG_ID                                             			            AS MPG
,CP_MPG.mpg_desc                                               					            AS MPG_Description    
,COALESCE(CP_MATL.CFN_id,'')                                   					            AS CFN
,COALESCE(CP_MATL_UOM.GTIN,'')                                    				            AS GTIN
,COALESCE(CP_MATL_char.version_number,'')                      					            AS Version_Number
,CP_SALES_ORD_DTL.MATL_ID                                            			            AS Material
,CAST(CP_SALES_ORD_DTL.ORD_QTY as INT)                               			            AS Order_Qty
,COALESCE(CAST(CP_SALES_ORD_DTL_SCHED.CONFIRM_QTY as INT),0)                                AS Confirmed_Qty
,COALESCE(CAST(CP_INV_PAR_APPRVL.PAR_LVL_QTY AS INT),0)							            AS PAR_Level_Qty
,COALESCE(CAST(CP_INV_PAR_APPRVL.ON_HAND_QTY AS INT),0)						                AS On_Hand_Qty
,COALESCE(CAST((CP_INV_PAR_APPRVL.PAR_LVL_QTY - CP_INV_PAR_APPRVL.ON_HAND_QTY)AS INT),0)	AS Qty_Until_PAR_Level
,CP_INV_PAR_APPRVL.ON_HAND_QTY < CP_INV_PAR_APPRVL.PAR_LVL_QTY                              AS Under_PAR
,COALESCE(CP_SALES_ORD_DTL.ln_dlvry_blk_id,'')                       			            AS Delivery_Block
,COALESCE(CP_SALES_ORD_DTL.reject_reasn_id,'')                       			            AS Current_Rejection_Reason
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD,'')               					            AS Previous_PAR_Rejection
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW,'')                					            AS Updated_PAR_Rejection
,CAST(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)    					                        AS PAR_Rejection_Update_Date
,CAST(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)    					                        AS PAR_Rejection_Update_Time
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID,'')          					            AS PAR_Rejection_Updated_By
,CASE
    WHEN TRIM(COALESCE(CP_SALES_ORD_DTL.reject_reasn_id,'')) = '' 	THEN 'Released'
    WHEN CP_SALES_ORD_DTL.reject_reasn_id = '97'  					THEN 'Rejected'
																	ELSE 'Different Rejection Reason'
END                                                         					            AS Released_Check
,CP_SALES_ORD_DTL.SALES_REP_ID_ORIG                                       		            AS Original_Sales_Rep
,CP_CUST_SALESREP.CUST_NM                                          				            AS Original_Sales_Rep_Name
,CP_INV_PAR_APPRVL.REGION_CD                                   					            AS Region
,CP_INV_PAR_APPRVL.CITY_CD                                     					            AS District
,CP_INV_PAR_APPRVL.TERR_ID                                         				            AS Territory
,CP_SALES_ORD_DTL.SFORCE_ID_ORIG                               					            AS Original_Sales_Force_ID
,CP_SFORCE.SFORCE_DESC                                         					            AS Original_Sales_Force_Description

from       DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL           				CP_SALES_ORD_DTL    -- Order Line Information
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           				CP_SALES_ORD_HDR    -- Order Header Information 
        on CP_SALES_ORD_HDR.HK_CP_SALES_ORD_HDR = CP_SALES_ORD_DTL.HK_CP_SALES_ORD_HDR
inner join DEV_EMEA_CDH_DB.UNIFIED.CLNDR                      				CLNDR               --> Calendar Info
        on current_date = CLNDR.FIRST_DAY
left join (select HK_CP_SALES_ORD_DTL, max(SCHED_LN_DT) as SCHED_LN_DT, sum(CONFIRM_QTY) as CONFIRM_QTY
            from DEV_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_SCHED
            group by HK_CP_SALES_ORD_DTL) CP_SALES_ORD_DTL_SCHED
        on CP_SALES_ORD_DTL.HK_CP_SALES_ORD_DTL = CP_SALES_ORD_DTL_SCHED.HK_CP_SALES_ORD_DTL
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_MATL                    				CP_MATL             --> Material Information
        on CP_MATL.HK_CP_MATL = CP_SALES_ORD_DTL.HK_CP_MATL
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR               				CP_MATL_CHAR        --> GTIN Version Number
        on CP_MATL_CHAR.HK_CP_MATL = CP_MATL.HK_CP_MATL
inner join DEV_EMEA_CDH_DB.FOUNDATION.CP_MATL_UOM                 			CP_MATL_UOM         --> GTIN
        on CP_MATL_UOM.HK_CP_MATL = CP_SALES_ORD_DTL.HK_CP_MATL
       and CP_MATL_UOM.HK_CP_UOM = CP_SALES_ORD_DTL.HK_CP_SALES_UOM
left join  DEV_EMEA_CDH_DB.UNIFIED.CP_MPG                    				CP_MPG              --> Material Pricing Group Description
        on CP_MPG.HK_CP_MPG = CP_SALES_ORD_DTL.HK_CP_MPG
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORG               				CP_SALES_ORG        --> Sales Organization Name
        on CP_SALES_ORG.SALES_ORG_ID = CP_SALES_ORD_HDR.SALES_ORG_ID
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SHIPTO      --> Ship To Name
        on CP_CUST_SHIPTO.HK_CP_CUST = CP_SALES_ORD_HDR.HK_CP_SHIP_TO_CUST
inner join DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SOLDTO      --> Sold To Name
        on CP_CUST_SOLDTO.HK_CP_CUST = CP_SALES_ORD_HDR.HK_CP_SOLD_TO_CUST
inner join  DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SALESREP    --> Sales Rep Name
        on CP_CUST_SALESREP.CUST_ID = CP_SALES_ORD_DTL.SALES_REP_ID_ORIG
left join  DEV_EMEA_CDH_DB.UNIFIED.CP_SFORCE                  				CP_SFORCE           --> Sales Force Description
        on CP_SFORCE.HK_CP_SFORCE = CP_SALES_ORD_DTL.HK_CP_SFORCE_ORIG
left join  DEV_EMEA_CDH_DB.FOUNDATION.CP_INV_PAR_APPRVL					    CP_INV_PAR_APPRVL	--> PAR Approval Data
		on CP_INV_PAR_APPRVL.HK_CP_SALES_ORD_DTL = CP_SALES_ORD_DTL.HK_CP_SALES_ORD_DTL
left join  (SELECT
            MAX(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS) AS CHG_TS
           ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
           ,CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
           ,CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY
           ,CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
           ,CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
            FROM  DEV_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG
            WHERE TBL_NM = 'VBAP'
              AND FIELD_NM = 'ABGRU'
              AND (VAL_OLD = '97' OR VAL_NEW = '97')
            GROUP BY CHG_BY_USER_ID,SALES_ORD_ID,TBL_KEY,VAL_OLD,VAL_NEW) CP_SALES_ORD_DTL_CHG_LOG --> SAP Change Data
        ON  CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID       = CP_SALES_ORD_DTL.SALES_ORD_ID
        AND RIGHT(CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY, 6)  = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM

where      CP_SALES_ORD_HDR.sales_doc_typ_id = 'KB'                                                                                         --> Hardcoded filter to only take order type 'KB'
      and (CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD = '97' OR CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW = '97' OR CP_SALES_ORD_DTL.reject_reasn_id = '97')   --> Hardcoded filter to grab the lines which either currently have a PAR rejection reason or had it in the past
      and  CP_CUST_SHIPTO.CNTRY_ID IN (SELECT CNTRY_ID FROM DEV_EMEA_UDH_DB.CUSTOMERCARE.UMD_OPTIMAL_PAR_INCLUDED_COUNTRIES)                --> Specific Country filter for this report via UMD / Dropfile
      and  CP_SALES_ORD_HDR.ORD_CREATE_DT >= dateadd(DAYS, -365, current_date)                                                              --> Filter on the last 365 days of data
order by CP_SALES_ORD_HDR.ORD_CREATE_DT desc, unique_line_value desc
;