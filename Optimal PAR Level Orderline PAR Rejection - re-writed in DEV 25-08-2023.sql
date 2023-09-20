select
 CAST (CONVERT_TIMEZONE('Europe/Paris', CURRENT_TIMESTAMP()) AS DATE)			AS Report_Date
,CLNDR.DAY_NM                                               					AS Report_Date_Day_Name
,CLNDR.FIS_WK                                               					AS Report_Date_Fiscal_Week
,CLNDR.FIS_MTH                                              					AS Report_Date_Fiscal_Month
,CLNDR.FIS_QTR                                              					AS Report_Date_Fiscal_Quarter
,CLNDR.FIS_YR                                               					AS Report_Date_Fiscal_Year
,CP_SALES_ORD_HDR.ORD_CREATE_DT                                      			AS PAR_Create_Date
,CP_SALES_ORD_DTL.PLANT_ID                                           			AS Plant
,CP_SALES_ORD_DTL.STOR_LOC_ID                                        			AS Storage_Location
,CONCAT (CP_SALES_ORG.SALES_ORG_DESC,' (',CP_SALES_ORD_HDR.SALES_ORG_ID,')')  	AS Sales_Organization
,CP_SALES_ORD_HDR.SALES_OFFICE_ID                                    			AS Sales_Office
,CP_SALES_ORD_HDR.SOLD_TO_CUST_ID                                    			AS SoldTo_Number
,CP_CUST_SOLDTO.CUST_NM                                        					AS SoldTo_Customer
,CP_SALES_ORD_HDR.SHIP_TO_CUST_ID                                    			AS ShipTo_Number
,CP_CUST_SHIPTO.CUST_NM                                        					AS ShipTo_Customer
,CP_CUST_SHIPTO.CITY_NM                                        					AS ShipTo_City
,CP_CUST_SHIPTO.CNTRY_ID                                       					AS ShipTo_Country_ID
,CP_CUST_SHIPTO.CNTRY_NM                                       					AS ShipTo_Country_Name
,VBAP.LPRIO                                                 					AS Delivery_Prio --//needs to be part of CP_SALES_ORD_DTL
,CAST (CP_SALES_ORD_DTL_SCHED.SCHED_LN_DT as date)                              AS Requested_Delivery_Date
,CP_SALES_ORD_HDR.SALES_ORD_ID                                       			AS Sales_Order
,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM                                   			AS Sales_Orderline
,CONCAT(CP_SALES_ORD_HDR.SALES_ORD_ID,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM)      	AS Unique_Line_Value
,CP_MATL.OU_HRCHY_OU_DESC                                      					AS Operating_Unit -->Added on 27-06-2023 as additional requirement
,CP_MATL.OU_HRCHY_IOU_LONG                                     					AS Sub_Operating_Unit -->Added on 03-07-2023 as additional requirement
,CP_SALES_ORD_DTL.MPG_ID                                             			AS MPG
,CP_MPG.mpg_desc                                               					AS MPG_Description    
,COALESCE(CP_MATL.CFN_id,'')                                   					AS CFN
,COALESCE(CP_MATL_UOM.GTIN,'')                                    				AS GTIN
,COALESCE(CP_MATL_char.version_number,'')                      					AS Version_Number
,CP_SALES_ORD_DTL.MATL_ID                                            			AS Material
,CAST(CP_SALES_ORD_DTL.ORD_QTY as INT)                               			AS Order_Qty
,COALESCE(CAST(CP_SALES_ORD_DTL_SCHED.CONFIRM_QTY as INT),'0')                  AS Confirmed_Qty
,CAST(ZSM_PAR_APPROVAL.ZPARLVLQTY AS INT)										AS PAR_Level
,ZSM_PAR_APPROVAL.ZPARLVLTYPE													AS PAR_Level_Status
--,ZSM_PAR_APPROVAL.ZPARSTATUS													AS PAR_Level_Status2
,CAST(ZSM_PAR_APPROVAL.ZCONSONHNDQTY AS INT)        							AS On_Hand_Qty
,CAST((ZSM_PAR_APPROVAL.ZPARLVLQTY - ZSM_PAR_APPROVAL.ZCONSONHNDQTY)AS INT)		AS Qty_Until_PAR_Level
,(ZSM_PAR_APPROVAL.ZCONSONHNDQTY < ZSM_PAR_APPROVAL.ZPARLVLQTY)	                AS Under_PAR
--,CP_SALES_ORD_DTL.SALES_UOM_ID                                       			AS UOM --> Commented on 27-06-2023 as it does not seem to be required
,COALESCE(CP_SALES_ORD_DTL.ln_dlvry_blk_id,'')                       			AS Delivery_Block
,COALESCE(CP_SALES_ORD_DTL.reject_reasn_id,'')                       			AS Current_Rejection_Reason
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.UNIT_OLD,'')               					AS Previous_PAR_Rejection
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.UNIT_NEW,'')                					AS Updated_PAR_Rejection
,CAST(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)    					            AS PAR_Rejection_Update_Date
,CAST(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)    					            AS PAR_Rejection_Update_Time
,COALESCE(CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID,'')          					AS PAR_Rejection_Updated_By
,CASE
    WHEN TRIM(COALESCE(CP_SALES_ORD_DTL.reject_reasn_id,'')) = '' 	THEN 'Released'
    WHEN CP_SALES_ORD_DTL.reject_reasn_id = '97'  					THEN 'Rejected'
																	ELSE 'Different Rejection Reason'
END                                                         					AS Released_Check
,VBAP.ZOTC_SREPCODE                                         					AS Sales_Rep  --//needs to be part of CP_SALES_ORD_DTL
,CP_CUST_SALESREP.CUST_NM                                          				AS Sales_Rep_Name
,ZSM_PAR_APPROVAL.REGIO                                        					AS Region
,ZSM_PAR_APPROVAL.ORT02                                        					AS District
,ZSM_PAR_APPROVAL.ZTERTRY                                         				AS Territory
,VBAP.ZOTC_SFORCE                                           					AS Sales_Force_ID  --//needs to be part of CP_SALES_ORD_DTL
,CP_SFORCE.SFORCE_DESC                                         					AS Sales_Force_Description

from       DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL           				CP_SALES_ORD_DTL-- Order Line Information
left join  DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           				CP_SALES_ORD_HDR-- Order Header Information 
        on CP_SALES_ORD_HDR.HK_CP_SALES_ORD_HDR = CP_SALES_ORD_DTL.HK_CP_SALES_ORD_HDR
left join  DEV_EMEA_CDH_DB.UNIFIED.CLNDR                      				CLNDR --> Calendar Info
        on  current_date = CLNDR.FIRST_DAY
left join  (select SALES_ORD_ID, SALES_ORD_LN_NUM, max(SCHED_LN_DT) as SCHED_LN_DT, sum(CONFIRM_QTY) as CONFIRM_QTY
             from DEV_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_SCHED
             group by SALES_ORD_ID, SALES_ORD_LN_NUM)                       CP_SALES_ORD_DTL_SCHED
        on  CP_SALES_ORD_DTL.HK_CP_SALES_ORD_DTL       = CP_SALES_ORD_DTL_SCHED.HK_CP_SALES_ORD_DTL
left join  	DEV_SDH_DB.CP.VBAP                                 				VBAP --> Orderline info which is not in ORD_DTL //NEEDS THE FIELD VBAP.ZOTC_SREPCODE TO THE ALREADY EXISTING VIEW IN FOUNDATION: CP_SALES_ORD_DTL
        on  CP_SALES_ORD_DTL.SALES_ORD_ID = VBAP.VBELN						--//this join is no longer needed when VBAP fields will become part of CP_SALES_ORD_DTL
        and CP_SALES_ORD_DTL.SALES_ORD_LN_NUM = VBAP.POSNR					--//this join is no longer needed when VBAP fields will become part of CP_SALES_ORD_DTL
left join  	DEV_EMEA_CDH_DB.UNIFIED.CP_MATL                    				CP_MATL --> Material Information
        on  CP_MATL.HK_CP_MATL = CP_SALES_ORD_DTL.HK_CP_MATL
left join  	DEV_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR               				CP_MATL_CHAR --> GTIN Version Number
        on  CP_MATL_CHAR.HK_CP_MATL = CP_MATL.HK_CP_MATL
left join   DEV_EMEA_CDH_DB.FOUNDATION.CP_MATL_UOM                 			CP_MATL_UOM  --> GTIN
        on  CP_MATL_UOM.HK_CP_MATL = CP_SALES_ORD_DTL.HK_CP_MATL
        and CP_MATL_UOM.UOM_ID = CP_SALES_ORD_DTL.SALES_UOM_ID				--//needs a HK in FOUNDATION.CP_SALES_ORD_DTL for SALES_UOM_ID = HK_CP_SALES_UOM
left join   DEV_EMEA_CDH_DB.UNIFIED.CP_MPG                    				CP_MPG --> Material Pricing Group Description
        on  CP_MPG.mpg_id = CP_SALES_ORD_DTL.mpg_id 						--//needs a HK in FOUNDATION.CP_SALES_ORD_DTL for MPG_ID = HK_CP_MPG
left join  	DEV_EMEA_CDH_DB.UNIFIED.CP_SALES_ORG               				CP_SALES_ORG --> Sales Organization Name
        on  CP_SALES_ORG.SALES_ORG_ID = CP_SALES_ORD_HDR.SALES_ORG_ID		--//needs a HK in FOUNDATION.CP_SALES_ORD_HDR for SALES_ORG_ID = HK_CP_SALES_ORG
left join   DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SHIPTO --> Ship To Name
        on  CP_CUST_SHIPTO.HK_CP_CUST = CP_SALES_ORD_HDR.HK_CP_SHIP_TO_CUST
left join   DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SOLDTO --> Sold To Name
        on  CP_CUST_SOLDTO.HK_CP_CUST = CP_SALES_ORD_HDR.HK_CP_SOLD_TO_CUST
left join   DEV_EMEA_CDH_DB.UNIFIED.CP_CUST                   				CP_CUST_SALESREP --> Sales Rep Name
        on  CP_CUST_SALESREP.CUST_ID = VBAP.ZOTC_SREPCODE 
left join  	DEV_EMEA_CDH_DB.UNIFIED.CP_SFORCE                  				CP_SFORCE --> Sales Force Description
        on  CP_SFORCE.SFORCE_ID = VBAP.ZOTC_SFORCE							--//needs a HK in FOUNDATION.CP_SALES_ORD_DTL for ZOTC_SFORCE = HK_CP_ZOTC_SFORCE
left join	DEV_SDH_DB.CP.ZSM_PAR_APPROVAL									ZSM_PAR_APPROVAL --> PAR Level info //we need to created a view in FOUNDATION / UNIFIED with a HK: HK_CP_SALES_ORD_DTL
		on	ZSM_PAR_APPROVAL.VBELN = CP_SALES_ORD_DTL.SALES_ORD_ID			--//needs to be replaced by HK in new (to be created view)
		and	ZSM_PAR_APPROVAL.POSNR = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM		--//needs to be replaced by HK in new (to be created view)
left join  	DEV_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                 				CP_GEO_ISO --> Country Geo info used in filter
        on  CP_CUST_SHIPTO.CNTRY_ID = CP_GEO_ISO.GEO_ISO_ID
left join   (SELECT
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            FROM DEV_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            WHERE HRCHY_NM = 'WWR_ENTITY')                      			RPT_LOC_HRCHY --> Country Finance Hierarchy info used in filter
        ON  CP_GEO_ISO.HK_CP_ENTITY = RPT_LOC_HRCHY.HK_CP_ENTITY       
left join   (SELECT
              MAX(CP_SALES_ORD_DTL_CHG_LOG.CHG_TS) AS CHG_TS
             ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
             ,CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
             ,CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY
             ,CP_SALES_ORD_DTL_CHG_LOG.UNIT_OLD
             ,CP_SALES_ORD_DTL_CHG_LOG.UNIT_NEW
             FROM  DEV_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG
             WHERE TBL_NM = 'VBAP'
               AND FIELD_NM = 'ABGRU'
               AND (UNIT_OLD = '97' OR UNIT_NEW = '97')
             GROUP BY CHG_BY_USER_ID,SALES_ORD_ID,TBL_KEY,UNIT_OLD,UNIT_NEW) CP_SALES_ORD_DTL_CHG_LOG --> SAP Change Data
        ON  CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID       = CP_SALES_ORD_DTL.SALES_ORD_ID
        AND RIGHT(CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY, 5)  = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM
where CP_SALES_ORD_HDR.sales_doc_typ_id = 'KB'
      and CP_CUST_SHIPTO.CNTRY_ID       IN ('FR','PT','IT','GB','SE','ES','NO','FI','AT','IE','DK','CH','BE','ZA') --> Use UMD / Dropfile solution instead of hardcoded country codes
      and (CP_SALES_ORD_DTL_CHG_LOG.UNIT_OLD = '97' OR CP_SALES_ORD_DTL_CHG_LOG.UNIT_NEW = '97' OR CP_SALES_ORD_DTL.reject_reasn_id = '97')
      --and ord_dtl.SALES_ORD_ID        = '6214631765'
      and CP_SALES_ORD_HDR.ORD_CREATE_DT       >= '2022-12-24'
order by unique_line_value
;"DEV_EMEA_CDH_DB"."FOUNDATION"."CP_MRP_AREA_LOCATION"