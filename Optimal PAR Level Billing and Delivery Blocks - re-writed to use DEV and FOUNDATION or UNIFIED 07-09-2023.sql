--1. Header Information for Activation of Billing + Delivery Blocks
select
 CAST (VBAK.zorf_recv_date as DATE)								                        as Order_Receive_Date
,VBAK.zorf_recv_time                                                                    as Order_Receive_Time
,CP_SALES_ORD_HDR.ORD_CREATE_DT                                                         as Order_Creation_Date
,CAST (VBAK.erzet as TIME)                                                              as Order_Creation_Time
,CP_SALES_ORD_HDR.CREATED_BY_USER_ID                                                    as Order_Created_By
,CP_SALES_ORD_HDR.SALES_ORG_ID			                                                as Sales_Org
,CP_SALES_ORD_HDR.SALES_OFFICE_ID		                                                as Sales_Office
,CP_SALES_ORD_HDR.SOLD_TO_CUST_ID                                                       as SoldTo_Number
,CP_CUST.CUST_NM                                             	                        as SoldTo_Customer
,CP_CUST.CNTRY_ID			                                 	                        as SoldTo_Country
,CP_CUST.CNTRY_NM			                                 	                        as SoldTo_Country_Name
,CP_SALES_ORD_HDR.DIST_CHAN_ID			                                                as Distribution_Channel
,CP_SALES_ORD_HDR.PO_TYP_ID				                                                as PO_Type
,CP_SALES_ORD_HDR.SALES_DOC_TYP_ID		                                                as Order_Type
,CP_SALES_ORD_HDR.SALES_ORD_ID                                                          as Order_Number
,case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSK' THEN 'Billing_Block_Order'
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSK' THEN 'Delivery_Block_Order'
    else '' END                                                                         as Order_Block_Type 
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)                                         as Order_Block_Date
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)                                         as Order_Block_Time
,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID                                                as Order_Blocked_By_User_ID
,coalesce(PEARL_USER_CLASS.GROUP_CODE_DESC,'')                                          as Order_Blocked_By_User_Group
,coalesce(CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW,'')                                          as Order_Block_Value
,coalesce(case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSK' then CP_BILL_BLK_NEW.BILL_BLK_DESC
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSK' then CP_DLVRY_BLK_NEW.DLVRY_BLK_DESC
    else '' end,'')                                                                     as Order_Block_Description
--,CAST (CP_BILL_HDR.CREATE_DT AS DATE)                                          		as First_Invoiced_Date
--,CAST (CP_BILL_HDR.CREATE_TIME AS TIME)                                          		as First_Invoiced_Time
--,coalesce(CP_BILL_HDR.CREATED_BY,'')                                            		as First_Invoiced_By

from 		PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           						CP_SALES_ORD_HDR --> Sales Order Header info
left join   PROD_SDH_DB.CP.VBAK                                 						VBAK --> Sales Order Header info which is not yet available in CP_SALES_ORD_HDR
        on  VBAK.vbeln = CP_SALES_ORD_HDR.SALES_ORD_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    						CP_CUST --> Customer Description
        on  CP_CUST.CUST_ID = CP_SALES_ORD_HDR.SOLD_TO_CUST_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                 						CP_GEO_ISO --> Country Geo info used in filter
        on  CP_CUST.CNTRY_ID = CP_GEO_ISO.GEO_ISO_ID
left join   (select distinct
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            from PROD_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            where HRCHY_NM = 'WWR_ENTITY')                      					    RPT_LOC_HRCHY --> Country Finance Hierarchy info used in filter
        on  CP_GEO_ISO.HK_CP_ENTITY = RPT_LOC_HRCHY.HK_CP_ENTITY     
--left join  (SELECT
--            CREATE_DT
--           ,CREATE_TIME
--           ,CREATED_BY
--           ,HK_CP_SALES_ORD_HDR
--            FROM PROD_EMEA_CDH_DB.FOUNDATION.CP_BILL_HDR)								CP_BILL_HDR --> Invoice / Billing info on header level
left join   (select
             CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.OBJ_CLASS_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_NUM
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
            from    PROD_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG
			where 	CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM in ('FAKSK','LIFSK')
			    and	CP_SALES_ORD_DTL_CHG_LOG.TBL_NM in   ('VBAK')
                and CP_SALES_ORD_DTL_CHG_LOG.CHG_TS like '2023%')                       CP_SALES_ORD_DTL_CHG_LOG --> CDPOS/CDHDR information which represents change log info 
		on  CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID = CP_SALES_ORD_HDR.SALES_ORD_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                					    CP_BILL_BLK_OLD -->
        on  CP_BILL_BLK_OLD.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                					    CP_BILL_BLK_NEW
        on  CP_BILL_BLK_NEW.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                					    CP_DLVRY_BLK_OLD
        on  CP_DLVRY_BLK_OLD.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                					    CP_DLVRY_BLK_NEW
        on  CP_DLVRY_BLK_NEW.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   DEV_EMEA_RDH_DB.CUSTOMERCARE.PEARL_USER_CLASSIFICATION                      PEARL_USER_CLASS
        on  PEARL_USER_CLASS.SOURCE_CODE = CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID

where       CP_SALES_ORD_HDR.SALES_DOC_TYP_ID    IN ('KE', 'ZFKE')
    and	    (CP_SALES_ORD_HDR.ORD_CREATE_DT::DATE BETWEEN (CURRENT_DATE::DATE - INTERVAL '62 DAYS') AND CURRENT_DATE::DATE)
    and     RPT_LOC_HRCHY.HRCHY_LVL1_DESC   = 'EMEA'
	and     RPT_LOC_HRCHY.HRCHY_LVL2_DESC   = 'Western Europe' --> Use UMD / Dropfile solution instead of hardcoded country codes / Regions
    and     CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW <> ' '
    and     CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW <> ''
    and     CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW IS NOT NULL
    and     CP_SALES_ORD_DTL_CHG_LOG.CHG_TS IS NOT NULL
order by    CP_SALES_ORD_HDR.ORD_CREATE_DT,CP_SALES_ORD_HDR.SALES_ORD_ID,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID;
    
--2. Header Information for Released Billing + Delivery Blocks
select
 CAST (VBAK.zorf_recv_date as DATE)                             						as Order_Receive_Date
,VBAK.zorf_recv_time                                            						as Order_Receive_Time
,CP_SALES_ORD_HDR.ORD_CREATE_DT                                 						as Order_Creation_Date
,CAST (VBAK.erzet as TIME)                                      						as Order_Creation_Time
,CP_SALES_ORD_HDR.CREATED_BY_USER_ID                            						as Order_Created_By
,CP_SALES_ORD_HDR.SALES_ORG_ID			                        						as Sales_Org
,CP_SALES_ORD_HDR.SALES_OFFICE_ID		                        						as Sales_Office
,CP_SALES_ORD_HDR.SOLD_TO_CUST_ID                               						as SoldTo_Number
,CP_CUST.CUST_NM                                             							as SoldTo_Customer
,CP_CUST.CNTRY_ID			                                 							as SoldTo_Country
,CP_CUST.CNTRY_NM			                                 							as SoldTo_Country_Name
,CP_SALES_ORD_HDR.DIST_CHAN_ID			                        						as Distribution_Channel
,CP_SALES_ORD_HDR.PO_TYP_ID				                        						as PO_Type
,CP_SALES_ORD_HDR.SALES_DOC_TYP_ID		                        						as Order_Type
,CP_SALES_ORD_HDR.SALES_ORD_ID                                  						as Order_Number
,case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSK' THEN 'Billing_Block_Order'
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSK' THEN 'Delivery_Block_Order'
    else '' END                                                 						as Order_Release_Type 
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)                 						as Order_Release_Date
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)                 						as Order_Release_Time
,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID                        						as Order_Released_By_User_ID
,coalesce(PEARL_USER_CLASS.GROUP_CODE_DESC,'')                                          as Order_Released_By_User_Group
,coalesce(CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD,'')                 						    as Previous_Order_Block_Value
,coalesce(case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSK' then CP_BILL_BLK_OLD.BILL_BLK_DESC
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSK' then CP_DLVRY_BLK_OLD.DLVRY_BLK_DESC
    else '' end,'')                                             						as Previous_Order_Block_Description
--,CAST (CP_BILL_HDR.CREATE_DT AS DATE)                                          		as First_Invoiced_Date
--,CAST (CP_BILL_HDR.CREATE_TIME AS TIME)                                          		as First_Invoiced_Time
--,coalesce(CP_BILL_HDR.CREATED_BY,'')                                            		as First_Invoiced_By

from 		PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           							CP_SALES_ORD_HDR --> Sales Order Header info
left join   PROD_SDH_DB.CP.VBAK                                 							VBAK --> Sales Order Header info which is not yet available in CP_SALES_ORD_HDR
        on  VBAK.vbeln = CP_SALES_ORD_HDR.SALES_ORD_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    							CP_CUST --> Customer Description
        on  CP_CUST.CUST_ID = CP_SALES_ORD_HDR.SOLD_TO_CUST_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                 							CP_GEO_ISO --> Country Geo info used in filter
        on  CP_CUST.CNTRY_ID = CP_GEO_ISO.GEO_ISO_ID
left join   (select distinct
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            from PROD_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            where HRCHY_NM = 'WWR_ENTITY')                      						RPT_LOC_HRCHY --> Country Finance Hierarchy info used in filter
        on  CP_GEO_ISO.HK_CP_ENTITY = RPT_LOC_HRCHY.HK_CP_ENTITY     
--left join  (SELECT
--            CREATE_DT
--           ,CREATE_TIME
--           ,CREATED_BY
--           ,HK_CP_SALES_ORD_HDR
--            FROM DEV_EMEA_CDH_DB.FOUNDATION.CP_BILL_HDR)								CP_BILL_HDR --> Invoice / Billing info on header level
left join   (select
             CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.OBJ_CLASS_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_NUM
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
            from    PROD_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG
			where 	CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM in ('FAKSK','LIFSK')
			    and	CP_SALES_ORD_DTL_CHG_LOG.TBL_NM in   ('VBAK'))                  	CP_SALES_ORD_DTL_CHG_LOG --> CDPOS/CDHDR information which represents change log info 
		on  CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID = CP_SALES_ORD_HDR.SALES_ORD_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                						CP_BILL_BLK_OLD
        on  CP_BILL_BLK_OLD.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                						CP_BILL_BLK_NEW
        on  CP_BILL_BLK_NEW.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                					    CP_DLVRY_BLK_OLD
        on  CP_DLVRY_BLK_OLD.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                					    CP_DLVRY_BLK_NEW
        on  CP_DLVRY_BLK_NEW.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   DEV_EMEA_RDH_DB.CUSTOMERCARE.PEARL_USER_CLASSIFICATION                      PEARL_USER_CLASS
        on  PEARL_USER_CLASS.SOURCE_CODE = CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID

where       CP_SALES_ORD_HDR.SALES_DOC_TYP_ID    IN ('KE', 'ZFKE')
    and	    (CP_SALES_ORD_HDR.ORD_CREATE_DT::DATE BETWEEN (CURRENT_DATE::DATE - INTERVAL '365 DAYS') AND CURRENT_DATE::DATE)
    and     RPT_LOC_HRCHY.HRCHY_LVL1_DESC   = 'EMEA'
	and     RPT_LOC_HRCHY.HRCHY_LVL2_DESC   = 'Western Europe' --> Use UMD / Dropfile solution instead of hardcoded country codes / Regions
    and     (CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW = ' '     or CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW = ''    or CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW IS NULL)
    and     (CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD <> ' '    AND CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD <> ''   AND CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD IS NOT NULL)
    order by CP_SALES_ORD_HDR.ORD_CREATE_DT,CP_SALES_ORD_HDR.SALES_ORD_ID,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
    --and     CP_SALES_ORD_HDR.SALES_ORD_ID        = '6216553179';

--3. Line Information for Activation of Billing + Delivery Blocks
SELECT
 CAST(CP_SALES_ORD_DTL.CREATE_DT as DATE)                                               as Orderline_Creation_Date
,CAST(VBAP.erzet as TIME)                                                               as Orderline_Creation_Time
,CP_SALES_ORD_DTL.CREATE_BY_USER_ID                                                     as Orderline_Created_By
,CP_SALES_ORD_DTL.SALES_ORD_ID                                                          as Order_Number
,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM                                                      as Order_Line
,CP_SALES_ORD_DTL.MATL_ID                                                               as Material_ID
,CP_MATL.MATL_DESC                                                                      as Material_Description
,COALESCE(CP_MATL.CFN_id,'')                                                            as CFN
,CAST(CP_SALES_ORD_DTL.ORD_QTY as INT)                                                  as Order_Qty
,CP_SALES_ORD_DTL.SALES_UOM_ID                                                          as Sales_UOM
,CP_SALES_ORD_DTL.ITEM_CAT_ID                                                           as Item_Category
,CP_SALES_ORD_DTL.DIV_ID                                                                as Division_ID
,CP_DIV.DIV_DESC				                                                        as Division_Description
,CP_SALES_ORD_DTL.MPG_ID                                                                as MPG_ID
,CP_MPG.MPG_DESC					                                                    as MPG_Description
,CP_MATL.OU_HRCHY_OU_DESC                                                               as Operating_Unit
,case 
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP' THEN 'Billing_Block_Line'
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP' THEN 'Delivery_Block_Line'
    else '' END                                                                         as Line_Block_Type 
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)                                         as Line_Block_Date
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)                                         as Line_Block_Time
,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID                                                as Line_Blocked_By_User_ID
,coalesce(PEARL_USER_CLASS.GROUP_CODE_DESC,'')                                          as Line_Blocked_By_User_Group
,coalesce(CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW,'')                                          as Line_Block_Value
,coalesce(case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP' then BILL_BLK_NEW.BILL_BLK_DESC
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP' then DEL_BLK_NEW.DLVRY_BLK_DESC
    else '' end,'')                                                                     as Line_Block_Description
--,CAST (CP_BILL_DTL.CREATE_DT AS DATE)                                          		as First_Invoiced_Date
--,CAST (CP_BILL_DTL.CREATE_TIME AS TIME)                                          		as First_Invoiced_Time
--,coalesce(CP_BILL_DTL.CREATED_BY,'')                                            		as First_Invoiced_By

FROM 		PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL                                    CP_SALES_ORD_DTL --> order details from unified
left join   PROD_SDH_DB.CP.VBAP                                                          VBAP --> raw order details
        on  VBAP.vbeln = CP_SALES_ORD_DTL.sales_ord_id
        and VBAP.posnr = CP_SALES_ORD_DTL.sales_ord_ln_num
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_MPG                                              CP_MPG --> Material Pricing Group Description
        on  CP_MPG.mpg_id = CP_SALES_ORD_DTL.mpg_id 
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DIV                                              CP_DIV --> Division Description
        on  CP_DIV.div_id = CP_SALES_ORD_DTL.div_id 
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                                             CP_CUST --> Customer Description
        on  CP_CUST.CUST_ID = CP_SALES_ORD_DTL.SOLD_TO_CUST_ID
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                                          CP_GEO_ISO --> Country Geo info used in filter
        ON  CP_CUST.CNTRY_ID = CP_GEO_ISO.GEO_ISO_ID
left join   (SELECT
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            FROM PROD_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            WHERE HRCHY_NM = 'WWR_ENTITY')                                              RPT_LOC_HRCHY --> Country Finance Hierarchy info used in filter
        ON  CP_GEO_ISO.HK_CP_ENTITY = RPT_LOC_HRCHY.HK_CP_ENTITY     
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL                                             CP_MATL --> Material Information
        on  CP_MATL.matl_id = CP_SALES_ORD_DTL.matl_id
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR                                        CP_MATL_CHAR --> GTIN Version Number
        on  CP_MATL_CHAR.HK_CP_MATL = CP_MATL.HK_CP_MATL
inner join  PROD_EMEA_CDH_DB.FOUNDATION.CP_MATL_UOM                                      CP_MATL_UOM --> GTIN
        on  CP_MATL_UOM.HK_CP_MATL = CP_SALES_ORD_DTL.HK_CP_MATL
        and CP_MATL_UOM.UOM_ID = CP_SALES_ORD_DTL.SALES_UOM_ID -->replace this join by a HK join once the HK_CP_SALES_UOM is in the CP_SALES_ORD_DTL
--left join  (SELECT
--            MIN (CREATE_DT) AS CREATE_DT
--           ,MIN (CREATE_TIME) AS CREATE_TIME
--           ,MIN (CREATED_BY) AS CREATED_BY
--           ,SALES_ORD_ID
--           ,SALES_ORD_LN_NUM
--            FROM DEV_EMEA_CDH_DB.FOUNDATION.CP_BILL_DTL
--            GROUP BY SALES_ORD_ID,SALES_ORD_LN_NUM)                                     CP_BILL_DTL --> Invoice / Billing info on line level
--        ON  CP_BILL_DTL.SALES_ORD_ID = CP_SALES_ORD_DTL.SALES_ORD_ID
--        AND CP_BILL_DTL.SALES_ORD_LN_NUM = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM
left join   (select
             CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY
            ,CP_SALES_ORD_DTL_CHG_LOG.OBJ_CLASS_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_NUM
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
            from    PROD_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG)                CP_SALES_ORD_DTL_CHG_LOG --> CDPOS/CDHDR information which represents change log info 
        on          CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID = CP_SALES_ORD_DTL.SALES_ORD_ID
        and COALESCE(CAST(SUBSTR(CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY, 14, 6) AS INT),'000000') = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM  
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                                        BILL_BLK_OLD
        on  bill_blk_old.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                                        BILL_BLK_NEW
        on  bill_blk_new.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                                       DEL_BLK_OLD
        on  del_blk_old.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                                       DEL_BLK_NEW
        on  del_blk_new.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   DEV_EMEA_RDH_DB.CUSTOMERCARE.PEARL_USER_CLASSIFICATION                      PEARL_USER_CLASS
        on  PEARL_USER_CLASS.SOURCE_CODE = CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
        
where       CP_SALES_ORD_DTL.ITEM_CAT_ID         = 'KEN'
        and CP_SALES_ORD_DTL.CREATE_DT::DATE BETWEEN (CURRENT_DATE::DATE - INTERVAL '365 DAYS') AND CURRENT_DATE::DATE
        and RPT_LOC_HRCHY.HRCHY_LVL2_DESC      = 'Western Europe'
        and RPT_LOC_HRCHY.HRCHY_LVL1_DESC      = 'EMEA'
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW <> ' '    
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW <> '' 
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW IS NOT NULL
        and ((CP_SALES_ORD_DTL_CHG_LOG.TBL_NM  = 'VBAP' and CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP') or (CP_SALES_ORD_DTL_CHG_LOG.TBL_NM = 'VBEP' and CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP'))
        --and CP_CUST.CNTRY_ID                   = 'GB'
        --and CP_SALES_ORD_DTL.CREATE_DT         like '2023-06-21%'
        --and CP_SALES_ORD_DTL.SALES_ORD_ID      = '6216036261'
        order by CP_SALES_ORD_DTL.CREATE_DT,CP_SALES_ORD_DTL.SALES_ORD_ID,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM
        
--4. Line Information for Releasing of Billing + Delivery Blocks
SELECT
 CP_SALES_ORD_DTL.CREATE_DT                                                  				as Orderline_Creation_Date
,CAST(VBAP.erzet as TIME)                                           						as Orderline_Creation_Time
,CP_SALES_ORD_DTL.CREATE_BY_USER_ID                                          				as Orderline_Created_By
,CP_SALES_ORD_DTL.SALES_ORD_ID                                               				as Order_Number
,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM                                           				as Order_Line
,CP_SALES_ORD_DTL.MATL_ID                                                    				as Material_ID
,CP_MATL.MATL_DESC                                                     						as Material_Description
,COALESCE(CP_MATL.CFN_ID,'')                                           						as CFN
,CAST(CP_SALES_ORD_DTL.ORD_QTY as INT)                                       				as Order_Qty
,CP_SALES_ORD_DTL.SALES_UOM_ID                                               				as Sales_UOM
,CP_SALES_ORD_DTL.ITEM_CAT_ID                                                				as Item_Category
,CP_SALES_ORD_DTL.DIV_ID                                                     				as Division_ID
,CP_DIV.DIV_DESC				                                        					as Division_Description
,CP_SALES_ORD_DTL.MPG_ID                                                     				as MPG_ID
,CP_MPG.MPG_DESC					                                    					as MPG_Description
,CP_MATL.OU_HRCHY_OU_DESC                                              						as Operating_Unit
,coalesce(case 
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP' THEN 'Billing_Block_Line'
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP' THEN 'Delivery_Block_Line'
    else '' END,'')                                                 						as Line_Release_Type 
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS DATE)                                             as Line_Release_Date
,CAST (CP_SALES_ORD_DTL_CHG_LOG.CHG_TS AS TIME)                                             as Line_Release_Time
,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID                                                  	as Line_Released_By_User_ID
,coalesce(PEARL_USER_CLASS.GROUP_CODE_DESC,'')                                              as Line_Released_By_User_Group
,coalesce(CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD,'')                                              as Previous_Line_Block_Value
,coalesce(case
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP' then bill_blk_old.BILL_BLK_DESC
    when CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP' then del_blk_old.DLVRY_BLK_DESC
    else '' end,'')                                                 						as Previous_Line_Block_Description
--,CAST (CP_BILL_DTL.CREATE_DT AS DATE)                                          			as First_Invoiced_Date
--,CAST (CP_BILL_DTL.CREATE_TIME AS TIME)                                          			as First_Invoiced_Time
--,coalesce(CP_BILL_DTL.CREATED_BY,'')                                            			as First_Invoiced_By

from 		PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL               						CP_SALES_ORD_DTL --> order details from unified
left join   PROD_SDH_DB.CP.VBAP                                     						VBAP --> raw order details
        on  VBAP.vbeln = CP_SALES_ORD_DTL.sales_ord_id
        and VBAP.posnr = CP_SALES_ORD_DTL.sales_ord_ln_num
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_MPG                         						CP_MPG --> Material Pricing Group Description
        on  CP_MPG.mpg_id = CP_SALES_ORD_DTL.mpg_id 
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DIV                         						CP_DIV --> Division Description
        on  CP_DIV.div_id = CP_SALES_ORD_DTL.div_id 
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                        						CP_CUST --> Customer Description
        on  CP_CUST.CUST_ID = CP_SALES_ORD_DTL.SOLD_TO_CUST_ID
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                     						CP_GEO_ISO --> Country Geo info used in filter
        on  CP_CUST.CNTRY_ID = CP_GEO_ISO.GEO_ISO_ID
left join   (SELECT
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            FROM PROD_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            WHERE HRCHY_NM = 'WWR_ENTITY')                          						RPT_LOC_HRCHY --> Country Finance Hierarchy info used in filter
        on  CP_GEO_ISO.HK_CP_ENTITY = RPT_LOC_HRCHY.HK_CP_ENTITY     
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL                        						CP_MATL --> Material Information
        on  CP_MATL.matl_id = CP_SALES_ORD_DTL.matl_id
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR                   						CP_MATL_CHAR --> GTIN Version Number
        on  CP_MATL_CHAR.HK_CP_MATL = CP_MATL.HK_CP_MATL
inner join  PROD_EMEA_CDH_DB.FOUNDATION.CP_MATL_UOM                        					CP_MATL_UOM --> GTIN
        on  CP_MATL_UOM.MATL_ID = CP_SALES_ORD_DTL.MATL_ID
        and CP_MATL_UOM.UOM_ID = CP_SALES_ORD_DTL.SALES_UOM_ID
--left join  (SELECT
--            MIN (CREATE_DT) AS CREATE_DT
--           ,MIN (CREATE_TIME) AS CREATE_TIME
--           ,MIN (CREATED_BY) AS CREATED_BY
--           ,SALES_ORD_ID
--           ,SALES_ORD_LN_NUM
--            FROM DEV_EMEA_CDH_DB.FOUNDATION.CP_BILL_DTL
--            GROUP BY SALES_ORD_ID,SALES_ORD_LN_NUM)                                 		CP_BILL_DTL --> Invoice / Billing info on line level
--        ON  CP_BILL_DTL.SALES_ORD_ID = CP_SALES_ORD_DTL.SALES_ORD_ID
--        AND CP_BILL_DTL.SALES_ORD_LN_NUM = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM
left join   (select
             CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY
            ,CP_SALES_ORD_DTL_CHG_LOG.OBJ_CLASS_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_NUM
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_TS
            ,CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
            ,CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.TBL_NM
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
            ,CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
            from    DEV_EMEA_CDH_DB.FOUNDATION.CP_SALES_ORD_DTL_CHG_LOG)                    CP_SALES_ORD_DTL_CHG_LOG --> CDPOS/CDHDR information which represents change log info 
        on          CP_SALES_ORD_DTL_CHG_LOG.SALES_ORD_ID = CP_SALES_ORD_DTL.SALES_ORD_ID
        and COALESCE(CAST(SUBSTR(CP_SALES_ORD_DTL_CHG_LOG.TBL_KEY, 14, 6) AS INT),'000000') = CP_SALES_ORD_DTL.SALES_ORD_LN_NUM 
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                                            BILL_BLK_OLD
        on  bill_blk_old.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_BILL_BLK                                            BILL_BLK_NEW
        on  bill_blk_new.BILL_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                                           DEL_BLK_OLD
        on  del_blk_old.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_BLK                                           DEL_BLK_NEW
        on  del_blk_new.DLVRY_BLK_ID = CP_SALES_ORD_DTL_CHG_LOG.VAL_NEW
left join   DEV_EMEA_RDH_DB.CUSTOMERCARE.PEARL_USER_CLASSIFICATION                          PEARL_USER_CLASS
        on  PEARL_USER_CLASS.SOURCE_CODE = CP_SALES_ORD_DTL_CHG_LOG.CHG_BY_USER_ID
        
where       CP_SALES_ORD_DTL.ITEM_CAT_ID        = 'KEN'
        and CP_SALES_ORD_DTL.CREATE_DT::DATE BETWEEN (CURRENT_DATE::DATE - INTERVAL '365 DAYS') AND CURRENT_DATE::DATE
        and RPT_LOC_HRCHY.HRCHY_LVL2_DESC       = 'Western Europe'
        and RPT_LOC_HRCHY.HRCHY_LVL1_DESC       = 'EMEA'
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD    <> ' '
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD    <> ''
        and CP_SALES_ORD_DTL_CHG_LOG.VAL_OLD    IS NOT NULL
        and ((CP_SALES_ORD_DTL_CHG_LOG.TBL_NM   = 'VBAP' and CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'FAKSP') 
        OR   (CP_SALES_ORD_DTL_CHG_LOG.TBL_NM   = 'VBEP' and CP_SALES_ORD_DTL_CHG_LOG.FIELD_NM = 'LIFSP'))
        --and CP_SALES_ORD_DTL.SALES_ORD_ID     = '6216036261'
        --and CP_CUST.CNTRY_ID                  = 'GB'
        --and CP_SALES_ORD_DTL.CREATE_DT        like '2023-06-21%'
        order by CP_SALES_ORD_DTL.CREATE_DT,CP_SALES_ORD_DTL.SALES_ORD_ID,CP_SALES_ORD_DTL.SALES_ORD_LN_NUM;