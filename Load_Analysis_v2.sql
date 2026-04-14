SELECT 
--SELECTING THE COLUMNS THAT WILL BE NEEDED FOR ANALYSIS.  I SUSPECT SOME OF THESE WILL GET REMOVED.
    lh.ord_hdrnumber AS Load_Number, 
    oh.ord_billto AS Bill_To, 
    lh.lgh_driver1 AS Driver, 
    lh.lgh_rstartcty_nmstct AS Order_Origin, 
    lh.lgh_rendcty_nmstct AS Order_Destination, 
    oh.ord_startdate AS Order_start_date, 
    lh.lgh_startdate, 
    lh.lgh_enddate,
    oh.ord_totalmiles AS Revenue_Miles,
    lh.lgh_miles AS Total_Miles,  
    lh.lgh_ord_charge AS Linehaul_Revenue, 
    lh.lgh_linehaul AS Total_Revenue,
--NEEDED TO ESTABLISH A COUNT OF EACH ORIGIN-TO-DESTINATION COMBINATION
    COUNT(*) OVER (
        PARTITION BY 
            oh.ord_billto,
            lh.lgh_rstartcty_nmstct,
            lh.lgh_rendcty_nmstct
    ) AS BillTo_Orig_Dest_Count

FROM legheader AS lh
JOIN orderheader AS oh
    ON lh.ord_hdrnumber = oh.ord_number
--OH.ORD_STATUS = 'CMP' SELECTS ONLY ORDERS THAT HAVE BEEN COMPLETED.  IT FILTERS OUT ORDERS THAT HAVE BEEN CANCELLED OR THAT ARE STILL IN PROGRESS.
WHERE oh.ord_status = 'CMP'
--oh.ord_revtype1 = 'FLAT'.  FLAT WAS THE ONLY DIVISION TO BE ANALYZED
  AND oh.ord_revtype1 = 'FLAT'
--lh.lgh_driver1 <> 'CLAHAR'.  CLAHAR IS A DRIVER THAT IS ON A DEDICATED RUN AND WAS TO BE EXCLUDED FROM THE ANALYSIS.
  AND lh.lgh_driver1 <> 'CLAHAR'
--TIME SCOPE OF THE ANALYSIS WAS 2025
  AND oh.ord_startdate BETWEEN '2025-01-01 00:00' AND '2025-12-31 23:59'
ORDER BY 
    lh.lgh_rstartcty_nmstct,
    lh.lgh_rendcty_nmstct