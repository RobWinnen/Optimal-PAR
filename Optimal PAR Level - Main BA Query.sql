select
 current_date                                               AS Report_Date
,clndr.DAY_NM                                               AS Report_Date_Day_Name
,clndr.FIS_WK                                               AS Report_Date_Fiscal_Week
,clndr.FIS_MTH                                              AS Report_Date_Fiscal_Month
,clndr.FIS_QTR                                              AS Report_Date_Fiscal_Quarter
,clndr.FIS_YR                                               AS Report_Date_Fiscal_Year
,ord_hdr.ORD_CREATE_DT                                      AS PAR_Create_Date
,ord_dtl.PLANT_ID                                           AS Plant
,ord_dtl.STOR_LOC_ID                                        AS Storage_Location
,CONCAT (org.SALES_ORG_DESC,' (',ord_hdr.SALES_ORG_ID,')')  AS Sales_Organization
,ord_hdr.DIST_CHAN_ID                                       AS Distribution_Channel
,ord_hdr.SALES_OFFICE_ID                                    AS Sales_Office
,ord_hdr.SOLD_TO_CUST_ID                                    AS SoldTo_Number
,ord_hdr.SHIP_TO_CUST_ID                                    AS ShipTo_Number
,cust.CUST_NM                                               AS ShipTo_Customer
,cust.CITY_NM                                               AS ShipTo_City
,cust.CNTRY_ID                                              AS ShipTo_Country_ID
,cust.CNTRY_NM                                              AS ShipTo_Country_Name
,del_hdr.DLVRY_PRIORITY                                     AS Delivery_Prio
,del_hdr.PLND_GOODS_ISSUE_DT                                AS Requested_Delivery_Date
,ord_hdr.sales_doc_typ_id                                   AS Sales_Order_Type
,ord_hdr.SALES_ORD_ID                                       AS Sales_Order
,ord_dtl.SALES_ORD_LN_NUM                                   AS Sales_Orderline
,ord_dtl.DIV_ID                                             AS Division
,ord_dtl.MPG_ID                                             AS MPG
,mpg.mpg_desc                                               AS MPG_Description    
,COALESCE(matl.CFN_id,'')                                   AS CFN
,del_dtl.GTIN_ID                                            AS GTIN
,COALESCE(matl_char.version_number,'')                      AS Version_Number
,ord_dtl.MATL_ID                                            AS Material
,CAST(ord_dtl.ORD_QTY as INT)                               AS Order_Qty
,CAST(del_dtl.DLVRY_DTL_QTY as INT)                         AS Confirmed_Qty
,del_dtl.SALES_UOM_ID                                       AS Sales_UOM
,COALESCE (ord_dtl.ln_dlvry_blk_id,'')                      AS Delivery_Block
,COALESCE (ord_dtl.reject_reasn_id,'')                      AS Rejection_Reason
,xref.CUST_ID_SALES_REP                                     AS Sales_Rep
,sales_rep.CUST_NM                                          AS Sales_Rep_Name
,acct.DISTRICT_ID                                           AS District
,acct.REGION_ID                                             AS Region
,acct.TERR_ID                                               AS Territory
,acct.SFORCE_ID                                             AS Sales_Force_ID
,acct.SFORCE_DESC                                           AS Sales_Force_Description

from        PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL           ord_dtl--
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           ord_hdr--
        on  ord_hdr.HK_CP_SALES_ORD_HDR = ord_dtl.HK_CP_SALES_ORD_HDR
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    cust--
        on  cust.HK_CP_CUST = ord_hdr.HK_CP_SHIP_TO_CUST
left join   (select
              HK_CP_DLVRY_HDR
             ,ref_doc_id
             ,ref_doc_dtl_id
             ,DIST_CHAN_ID
             ,REC_PLANT_ID
             ,STOR_LOC_ID
             ,plant_id
             ,matl_id
             ,GTIN_ID
             ,SALES_UOM_ID
             ,sum (DLVRY_DTL_QTY) as DLVRY_DTL_QTY
             from       PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_DTL   del_dtl--
             where      dlvry_ln_num like '9000%'
             group by   HK_CP_DLVRY_HDR, ref_doc_id, ref_doc_dtl_id, plant_id, matl_id, GTIN_ID, SALES_UOM_ID,STOR_LOC_ID,REC_PLANT_ID,DIST_CHAN_ID) del_dtl   
        on  del_dtl.REF_DOC_ID = ord_dtl.sales_ord_id
        and del_dtl.REF_DOC_DTL_ID = ord_dtl.sales_ord_ln_num      
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_DLVRY_HDR               del_hdr--
        on  del_hdr.HK_CP_DLVRY_HDR = del_dtl.HK_CP_DLVRY_HDR
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL                    matl--
        on  matl.matl_id = ord_dtl.matl_id
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR               matl_char--
        on  matl_char.HK_CP_MATL = matl.HK_CP_MATL
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_MPG                     mpg--
        on  mpg.mpg_id = ord_dtl.mpg_id 
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORG               org--
        on  org.sales_org_id = ord_hdr.SALES_ORG_ID
inner join  (select distinct
              HK_CP_CUST_OWNER
             ,HK_CP_MATL
             ,MATL_ID
             ,CUST_ID_SHIP_TO
             from PROD_EMEA_CDH_DB.UNIFIED.CP_EQUIP)            equip--
        on  del_dtl.matl_id                 = equip.MATL_ID
        and del_hdr.SHIP_TO_CUST_ID         = equip.CUST_ID_SHIP_TO
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_EQUIP_SALES_ACCT_XREF   xref--
        on  equip.HK_CP_CUST_OWNER          = xref.HK_CP_CUST_OWNER
        and equip.HK_CP_MATL                = xref.HK_CP_MATL
inner join  (select distinct
              ENT_HRCHY_ID_L5
             ,HK_CP_CUST_SALES_REP
             ,PRIM_REP_FLAG
             ,DEL_FLAG
             ,SALES_ACCT_STAT_CD
             ,DISTRICT_ID
             ,REGION_ID
             ,TERR_ID
             ,END_DT
             ,MPG_ID
             ,JOB_FUNC_CD
             ,SFORCE_ID
             ,SFORCE_DESC 
             from PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ACCT)       acct--
       on  xref.HK_CP_CUST_SALES_REP       = acct.HK_CP_CUST_SALES_REP
       and xref.ENT_HRCHY_ID_L5            = acct.ENT_HRCHY_ID_L5
       and mpg.mpg_id                      = acct.mpg_id
inner join  PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    sales_rep--
        on  sales_rep.CUST_ID = xref.CUST_ID_SALES_REP 
inner join  PROD_EMEA_CDH_DB.UNIFIED.CLNDR                      clndr--
        on  current_date = clndr.FIRST_DAY
where ord_hdr.sales_ord_id = '6213138152'