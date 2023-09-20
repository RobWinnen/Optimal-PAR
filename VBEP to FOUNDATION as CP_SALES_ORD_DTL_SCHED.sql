SELECT
 MD5(TRIM(NVL('CP', ''))||'~#~'|| TRIM (NVL(VBELN, '')))                                            AS HK_CP_SALES_ORD_HDR
,VBELN as SALES_ORD_ID              --Sales Document
,MD5(TRIM(NVL('CP', ''))||'~#~'|| TRIM (NVL(VBELN, ''))||'~#~'|| TRIM(NVL(TO_CHAR(POSNR), '')))     AS HK_CP_SALES_ORD_DTL
,POSNR as SALES_ORD_LN_NUM 	        --Sales Document Item
,ETENR as DLVRY_SCHED_LN_NUM        --Delivery Schedule Line Number
,ETTYP as SCHED_LN_CAT              --Schedule line category
,LFREL as DLVRY_RELEVANT            --Item is relevant for delivery
,EDATU as SCHED_LN_DT               --Schedule line date
,EZEIT as ARRIVE_TIME               --Arrival time
,WMENG as ORD_QTY                   --Order quantity in sales units
,BMENG as CONFIRM_QTY               --Confirmed Quantity
,VRKME as SALES_UOM                 --Sales unit
,LMENG as REQ_QTY                   --Required quantity for mat.management in stockkeeping units
,MEINS as BASE_UOM                  --Base Unit of Measure
,BDDAT as REQ_DT                    --Requirement date (deadline for procurement)
,BDART as REQ_TYP                   --Requirement type
,PLART as PLAN_TYP                  --Planning type
,VBELE as BUS_ORD_ID                --Business document number
,POSNE as BUS_LN_NUM                --Business item number
,ETENE as SCHED_LN                  --Schedule line
,RSDAT as FIRST_POSS_RSVN_DT        --Earliest possible reservation date
,IDNNR as MAINT_REQUEST             --Maintenance request
,BANFN as PURCH_REQN_NUM            --Purchase Requisition Number
,BSART as DOC_TYP                   --Order Type (Purchasing)
,BSTYP as PO_DOC_CAT                --Purchasing Document Category
,WEPOS as CONFIRM_STAT              --Confirmation status of schedule line (incl.ALE)
,REPOS as INVOICE_RCPT_IND          --Invoice Receipt Indicator
,LRGDT as RETURN_DATE               --Return date for returnable packaging
,PRGRS as DT_TYP                    --Date type (day, week, month, interval)
,TDDAT as TRANSP_PLAN_DT            --Transportation Planning Date
,MBDAT as MATL_STAGE_DT             --Material Staging/Availability Date
,LDDAT as LOAD_DT                   --Loading Date
,WADAT as GOOD_ISSUE_DT             --Goods Issue Date
,CMENG as CORRECT_QTY               --Corrected quantity in sales unit
,LIFSP as SCHED_LN_DEL_BLK          --Schedule line blocked for delivery
,GRSTR as GRP_DEFINE                --Group definition of structure data
,ABART as RELEASE_TYP               --Release type
,ABRUF as FCST_DLVRY_SCHED_NUM      --Forecast Delivery schedule number
,ROMS1 as COMMIT_QTY                --Committed_Quantity        
,ROMS2 as Size2                     --Size_2
,ROMS3 as Size_3                    --Size_3
,ROMEI as UOM_FOR_SIZE              --Unit of measure for sizes 1 to 3
,RFORM as FORMULA_KEY               --Formula key
,UMVKZ as NUMER                     --Numerator
,UMVKN as DENOM                     --Denominator
,VERFP as AVAIL_CONFIRM_AUTO        --Availability confirmed automatically
,BWART as MVMT_TYP                  --Movement Type (Inventory Management)
,BNFPO as PURCH_REQN_NUM            --Item Number of Purchase Requisition
,ETART as SCHED_LN_TYP_EDI          --Schedule line type EDI
,AUFNR as ORD_ID                    --Order Number
,PLNUM as PLAN_ORD_ID               --Planned order number
,SERNR as BOM_EXPLODE_NUM           --BOM explosion number
,AESKD as CUST_ENGINEER_CHG_STAT    --Customer Engineering Change Status
,ABGES as GUARANTEE                 --Guaranteed (factor between 0 and 1)
,MBUHR as MATL_STAGE_TIME           --Material Staging Time (Local, Relating to a Plant)
,TDUHR as TRANSP_PLAN_TIME          --Transp. Planning Time (Local, Relating to a Shipping Point)
,LDUHR as LOAD_TIME                 --Loading Time (Local Time Relating to a Shipping Point)
,WAUHR as GOODS_ISSUE_TIME          --Time of Goods Issue (Local, Relating to a Plant)
,AULWE as ROUTE_SCHED               --Route Schedule

FROM PROD_SDH_DB.CP.VBEP
