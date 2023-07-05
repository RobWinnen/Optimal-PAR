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
,ord_hdr.SALES_OFFICE_ID                                    AS Sales_Office
,ord_hdr.SOLD_TO_CUST_ID                                    AS SoldTo_Number
,soldto_cust.CUST_NM                                        AS SoldTo_Customer
,ord_hdr.SHIP_TO_CUST_ID                                    AS ShipTo_Number
,shipto_cust.CUST_NM                                        AS ShipTo_Customer
,shipto_cust.CITY_NM                                        AS ShipTo_City
,shipto_cust.CNTRY_ID                                       AS ShipTo_Country_ID
,shipto_cust.CNTRY_NM                                       AS ShipTo_Country_Name
,vbap.LPRIO                                                 AS Delivery_Prio
,CAST (vbep.edatu as date)                                  AS Requested_Delivery_Date
,ord_hdr.SALES_ORD_ID                                       AS Sales_Order
,ord_dtl.SALES_ORD_LN_NUM                                   AS Sales_Orderline
,CONCAT(ord_hdr.SALES_ORD_ID,ord_dtl.SALES_ORD_LN_NUM)      AS Unique_Line_Value
,matl.OU_HRCHY_OU_DESC                                      AS Operating_Unit -->Added on 27-06-2023 as additional requirement
,matl.OU_HRCHY_IOU_LONG                                     AS Sub_Operating_Unit -->Added on 03-07-2023 as additional requirement
,ord_dtl.MPG_ID                                             AS MPG
,mpg.mpg_desc                                               AS MPG_Description    
,COALESCE(matl.CFN_id,'')                                   AS CFN
,COALESCE(marm.EAN11,'')                                    AS GTIN
,COALESCE(matl_char.version_number,'')                      AS Version_Number
,ord_dtl.MATL_ID                                            AS Material
,CAST(ord_dtl.ORD_QTY as INT)                               AS Order_Qty
,COALESCE(CAST(vbep.BMENG as INT),'0')                      AS Confirmed_Qty
,ord_dtl.SALES_UOM_ID                                       AS UOM --> Commented on 27-06-2023 as it does not seem to be required
,COALESCE(ord_dtl.ln_dlvry_blk_id,'')                       AS Delivery_Block
,COALESCE(ord_dtl.reject_reasn_id,'')                       AS Current_Rejection_Reason
,COALESCE(cd.value_old,'')                                  AS Previous_PAR_Rejection
,COALESCE(cd.value_new,'')                                  AS Updated_PAR_Rejection
,COALESCE(cd.UDATE,'')                                      AS PAR_Rejection_Update_Date
,COALESCE(cd.UTIME,'')                                      AS PAR_Rejection_Update_Time
,COALESCE(cd.USERNAME,'')                                   AS PAR_Rejection_Updated_By
,CASE
    WHEN TRIM(COALESCE(ord_dtl.reject_reasn_id,'')) = ''   THEN 'Released'
    WHEN ord_dtl.reject_reasn_id = '97'  THEN 'Rejected'
                                         ELSE 'Different Rejection Reason'
END                                                         AS Released_Check
,VBAP.ZOTC_SREPCODE                                         AS Sales_Rep
,sales_rep.CUST_NM                                          AS Sales_Rep_Name
,vbap.zotc_level3                                           AS Region
,vbap.zotc_level4                                           AS District
,vbap.zotc_tertry                                           AS Territory
,vbap.zotc_sforce                                           AS Sales_Force_ID
,sforce.SFORCE_DESC                                         AS Sales_Force_Description
--,cd.*

from        PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_DTL           ord_dtl-- Order Line Information
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORD_HDR           ord_hdr-- Order Header Information 
        on  ord_hdr.HK_CP_SALES_ORD_HDR = ord_dtl.HK_CP_SALES_ORD_HDR
left join  PROD_EMEA_CDH_DB.UNIFIED.CLNDR                      clndr --> Calendar Info
        on  current_date = clndr.FIRST_DAY
left join  (select VBELN, POSNR, max(EDATU) as EDATU, sum(BMENG) as BMENG
             from PROD_SDH_DB.CP.VBEP
             group by vbeln, posnr)                             vbep --> Schedueled Line Info
        on  ord_dtl.SALES_ORD_ID = vbep.vbeln
        and ord_dtl.SALES_ORD_LN_NUM = vbep.posnr
left join  PROD_SDH_DB.CP.VBAP                                 vbap --> Orderline info which is not in ORD_DTL
        on  ord_dtl.SALES_ORD_ID = vbap.vbeln
        and ord_dtl.SALES_ORD_LN_NUM = vbap.posnr
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL                    matl --> Material Information
        on  matl.matl_id = ord_dtl.matl_id
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_MATL_CHAR               matl_char --> GTIN Version Number
        on  matl_char.HK_CP_MATL = matl.HK_CP_MATL
left join   PROD_SDH_DB.CP.MARM                                marm --> GTIN
        on  marm.MATNR = ord_dtl.MATL_ID
        and marm.MEINH = ord_dtl.SALES_UOM_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_MPG                     mpg --> Material Pricing Group Description
        on  mpg.mpg_id = ord_dtl.mpg_id 
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_SALES_ORG               org --> Sales Organization Name
        on  org.sales_org_id = ord_hdr.SALES_ORG_ID
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    shipto_cust --> Ship To Name
        on  shipto_cust.HK_CP_CUST = ord_hdr.HK_CP_SHIP_TO_CUST
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    soldto_cust --> Sold To Name
        on  soldto_cust.HK_CP_CUST = ord_hdr.HK_CP_SOLD_TO_CUST
left join   PROD_EMEA_CDH_DB.UNIFIED.CP_CUST                    sales_rep --> Sales Rep Name
        on  sales_rep.CUST_ID = VBAP.ZOTC_SREPCODE 
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_SFORCE                  sforce --> Sales Force Description
        on  sforce.SFORCE_ID = vbap.zotc_sforce
left join  PROD_EMEA_CDH_DB.UNIFIED.CP_GEO_ISO                 geo --> Country Geo info used in filter
        ON  shipto_cust.CNTRY_ID = geo.GEO_ISO_ID
left join   (SELECT
             HK_CP_ENTITY
            ,HRCHY_NM
            ,HRCHY_LVL1_DESC
            ,HRCHY_LVL2_DESC
            FROM PROD_EMEA_CDH_DB.UNIFIED.RPT_LOC_HRCHY
            WHERE HRCHY_NM = 'WWR_ENTITY')                      loc_hrchy --> Country Finance Hierarchy info used in filter
        ON  geo.HK_CP_ENTITY = loc_hrchy.HK_CP_ENTITY       
left join   (SELECT
              max(cdhdr.UDATE) as UDATE
             ,max(cdhdr.UTIME) as UTIME
             ,cdhdr.USERNAME
             ,cdpos.objectid
             ,cdpos.tabkey
             ,cdpos.value_old
             ,cdpos.value_new
             FROM           PROD_SDH_DB.CP.CDPOS cdpos
             INNER JOIN     PROD_SDH_DB.CP.CDHDR cdhdr
                    ON      cdhdr.OBJECTID   = cdpos.OBJECTID
                    AND     cdhdr.OBJECTCLAS = cdpos.OBJECTCLAS
                    AND     cdhdr.CHANGENR   = cdpos.CHANGENR
             WHERE TABNAME IN ('VBAP') AND FNAME IN ('ABGRU')
             AND (cdpos.value_old = '97' or cdpos.value_new = '97')
             AND UDATE >= 20230628
             group by USERNAME,cdpos.objectid,tabkey,value_old,value_new) cd --> SAP Change Data
        on  cd.objectid             = ord_dtl.SALES_ORD_ID
        and RIGHT(cd.TABKEY, 6)     = ord_dtl.SALES_ORD_LN_NUM
where   ord_hdr.sales_doc_typ_id    = 'KB'
    and loc_hrchy.HRCHY_LVL1_DESC   = 'EMEA'
    and shipto_cust.CNTRY_ID        IN ('FR','PT','IT','GB','SE','ES','NO','FI','AT','IE','DK','CH','BE','ZA')
    --and ord_dtl.SALES_ORD_ID        = '6216268224'
    --and ord_hdr.ORD_CREATE_DT       >= '2023-06-28'
order by unique_line_value