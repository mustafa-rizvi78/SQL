SELECT 
       main.`Period`,
       IF(main.`Merchant Group`='Retail',
          'SmartPay Retail',
          main.`Merchant Group`
          )                                                     AS `Merchant Group`,
       /*
       CASE main.`Merchant Group`
           WHEN 'All'                 THEN 1 
           WHEN 'Retail'              THEN 2
           WHEN 'SmartpayPlus Online' THEN 3
           WHEN 'SmartpayPlus Retail' THEN 4 
       END                                                       AS `Sort Order`  
       */   
       `Total Applications` + IFNULL(online_main.`Total Apps`,0) AS `Total Applications`,
       `Total Application IDA Passed`,
       `Total Approved`,
       `Total Transaction`,
       `Total Transaction MTD`,
       `Transaction Amount`,
       `Avg Transaction Amount`,
       CASE main.`Merchant Group`
           WHEN 'All' THEN  CONCAT(ROUND(100*(`Total Application IDA Passed`/(`Total Applications` + IFNULL(online_main.`Total Apps`,0))),0), ' %')
                      ELSE  CONCAT(ROUND(100*(`Total Application IDA Passed`/(`Total Applications` + IFNULL(online_main.`Total Apps`,0))),0), ' %')
       END                   AS  `IDA Approval Rate`,
       CASE main.`Merchant Group`
           WHEN 'All' THEN      CONCAT(IF(  `Total Approved`=0 
                                        OR 
                                         `Total Application IDA Passed`=0,0, 
                                                                  ROUND(100*(`Total Approved`/`Total Application IDA Passed`),0)
                                   ), ' %')
                      ELSE `Approval Rate`
       END                   AS  `Approval Rate`,
        CASE main.`Merchant Group`
           WHEN 'All' THEN      CONCAT(IF(  `Total Transaction`=0 
                                           OR 
                                           `Total Application IDA Passed`=0,0, 
                                                                  ROUND(100*(`Total Transaction`/`Total Application IDA Passed`),0)
                                   ), ' %')
                      ELSE `Completion Rate`
       END                   AS `Completion Rate`
FROM 
(
SELECT 
        `Period`,
        CASE merchant_group 
           WHEN 1 THEN 'All'
           WHEN 2 THEN `Merchant Group`
        END                                     AS `Merchant Group`,
        SUM(`Total Applications`)               AS `Total Applications`,
        SUM(`Total Application IDA Passed`)     AS `Total Application IDA Passed`,
        SUM(`Total Approved`)                   AS `Total Approved`,
        SUM(`Total Transaction`)                AS `Total Transaction`,
        SUM(`Total Transaction MTD`)            AS `Total Transaction MTD`,
        SUM('Total Declines')                   AS 'Total Declines',
        MAX(`IDA Approval Rate`)                AS `IDA Approval Rate`,
        MAX(`Approval Rate`)                    AS `Approval Rate`,
        MAX(`Completion Rate`)                  AS `Completion Rate`,
        SUM(`Transaction Amount`)               AS `Transaction Amount`, 
        AVG(`Avg Transaction Amount`)           AS `Avg Transaction Amount`     
FROM 
(
SELECT 
        `Period`,
        `Merchant Group`,
        `Total Applications`,
        `Total Application IDA Passed`,
        `Total Approved`,
        `Total Transaction`,
        ROUND(`Transaction Amount`,0)                                       AS `Transaction Amount`,
        ROUND(`Avg Transaction Amount`,0)                                   AS `Avg Transaction Amount`,
        `Total Transaction MTD`,
         CONCAT(ROUND(100*(`Total Application IDA Passed`/`Total Applications`),0), ' %') AS `IDA Approval Rate`,
        CONCAT(`Approval Rate`, ' %')               AS `Approval Rate`,
        CONCAT(`Completion Rate`, ' %')             AS `Completion Rate`,
        `Total Declines`
FROM 
(
SELECT 
      IF(`Period` IS NULL,CURRENT_DATE,`Period`)              AS `Period`,
      `Merchant Group`,
       SUM(IF(`Period` IS NULL,0,`Total Applications`))   /* + 
      ((SELECT 
          COUNT(DISTINCT el.email)         
       FROM email_leads el 
       LEFT JOIN emails e ON (el.email = e.email_address)
       LEFT JOIN users u  ON (e.id = u.primary_email_id)
       WHERE el.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
         AND el.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
         AND u.id IS NULL
      )) */                                                   AS `Total Applications`,
      SUM(IF(`Period` IS NULL,0,`Total Applications`))        AS `Total Application IDA Passed`,
      SUM(IF(`Period` IS NULL,`Total Declines`,0))            AS `Total Declines`,
      SUM(IF(`Period` IS NULL,0,`Total Approved`))            AS `Total Approved`,
      SUM(IF(`Period` IS NULL,0,`Total Transaction`))         AS `Total Transaction`,
      SUM(IF(`Period` IS NULL,0,`Transaction Amount`))        AS `Transaction Amount`,
      SUM(IF(`Period` IS NULL,0,`Avg Transaction Amount`))    AS `Avg Transaction Amount`,
      SUM(IF(`Period` IS NULL,`Total Transaction MTD`,0))     AS `Total Transaction MTD`,
      CASE 
         WHEN 
             SUM(IF(`Period` IS NULL,0,`Total Approved`)) =0 
          OR 
            (SUM(IF(`Period` IS NULL,0,`Total Applications`)) - 
             SUM(IF(`Period` IS NULL,0,`Total Declines`))
            )                                              =0 THEN 0 
                                                              ELSE ROUND(100*(SUM(IF(`Period` IS NULL,0,`Total Approved`))/
                                                                             (SUM(IF(`Period` IS NULL,0,`Total Applications`)) - 
                                                                              SUM(IF(`Period` IS NULL,0,`Total Declines`))
                                                                             )),0
                                                                       )
      END                                                 AS `Approval Rate`,
      CASE 
        WHEN
            SUM(IF(`Period` IS NULL,0,`Total Transaction`)) =0 
          OR 
           SUM(IF(`Period` IS NULL,0,`Total Applications`))=0 THEN 0 
                                                               ELSE ROUND(100*(SUM(IF(`Period` IS NULL,0,`Total Transaction`))/
                                                                             SUM(IF(`Period` IS NULL,0,`Total Applications`))
                                                                             ),0
                                                                       )
      END                                                 AS `Completion Rate`
FROM 
(
SELECT
      CASE 
           WHEN   ch.`type`='RetailChannel'
               AND
                  m.`name` IN ('Walmart','Tracfone')    THEN 'SmartPayPlus Retail'
           WHEN ch.`type`='RetailChannel'
               AND          
                  m.`name` NOT IN ('Walmart','Tracfone') THEN 'Retail'
           WHEN 
                 ch.`type`='OnlineChannel' 
                                                        THEN 'SmartPayPlus Online'
                                                        -- ELSE ch.`type`
      END                                          AS `Merchant Group`,               
      CASE transaction_type
          WHEN 1 THEN DATE(la.created_at)
          WHEN 2 THEN DATE(op.created_at)
          WHEN 3 THEN DATE(co.created_at)
      END                                           AS `Period`,
      COUNT(DISTINCT IF(transaction_type=1,
                        la.id,
                        NULL
                        )
            )                                       AS `Total Applications`,
      COUNT(DISTINCT IF(da.approved=1 AND 
        transaction_type=1,la.id,NULL
      ))  AS `Total Approved`,                         
      COUNT(DISTINCT 
                   CASE 
                     WHEN transaction_type=2 THEN op.id
                     WHEN transaction_type=3 THEN co.id
                                             ELSE NULL 
                  END
           )                                        AS  `Total Transaction`,
      SUM( 
                   CASE 
                     WHEN transaction_type=2 THEN op.amount
                     WHEN transaction_type=3 THEN IF(op.id IS NOT NULL,op.amount,c.total_purchase_amount)
                                             ELSE 0 
                  END
           )                                        AS  `Transaction Amount`,
      AVG( 
                   CASE 
                     WHEN transaction_type=2 THEN op.amount
                     WHEN transaction_type=3 THEN IF(op.id IS NOT NULL,op.amount,c.total_purchase_amount)
                                                       ELSE NULL 
                  END
           )                                        AS  `Avg Transaction Amount`,
       COUNT(DISTINCT 
                   CASE 
                     WHEN transaction_type=2 
                        AND 
                          da.internal_decline_code IN ('AP1','HS1','HS3','HS4','HS5','HS6','HS7') THEN op.id
                     WHEN transaction_type=3
                        AND 
                          da.internal_decline_code IN ('AP1','HS1','HS3','HS4','HS5','HS6','HS7') THEN co.id
                                             ELSE NULL 
                  END
           )                                        AS `Total Declines`,
       COUNT(DISTINCT 
                   CASE 
                     WHEN transaction_type=4 THEN IF(is_web_checkout=1,co.id,op.id)
                                              ELSE NULL 
                  END
           )                                        AS  `Total Transaction MTD`                                  

FROM  loan_applications la 
INNER JOIN orders             o ON (o.id   = la.order_id)
INNER JOIN users              u ON (u.id   = o.user_id)
INNER JOIN available_items   ai ON (ai.id  = o.available_item_id)
INNER JOIN carts             c  ON (la.id  = c.loan_application_id)
INNER JOIN locations     loc    ON (loc.id = ai.location_id)
INNER JOIN merchants          m ON (m.id   = loc.merchant_id)
INNER JOIN channels         ch  ON (ch.id  = m.channel_id)
INNER JOIN emails             e ON (e.id   = u.primary_email_id)
LEFT  JOIN outgoing_payments op ON (la.id = op.loan_application_id)
LEFT  JOIN collaterals       co ON (    la.id = co.loan_application_id
                                    AND 
                                       co.`type`='CashDeposit'
                                    AND 
                                       co.`status`='auth_success'
                                   ) 
LEFT  JOIN decision_attempts  da ON (da.id = (SELECT MAX(id)
                                               FROM decision_attempts
                                               WHERE loan_application_id=la.id 
                                               )
                                    )
LEFT  JOIN feature_configs    fc ON (   m.`name` = fc.merchant_name
                                     AND
                                        fc.`name`='RecurringServicePlan' 
                                     )
CROSS JOIN ( SELECT 1 AS transaction_type
             UNION ALL 
             SELECT 2
             UNION ALL 
             SELECT 3
             UNION ALL 
             SELECT 4 
           ) AS a 
WHERE CASE transaction_type
            WHEN 1 THEN
                               la.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
                           AND la.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
            WHEN 2 THEN        op.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
                           AND op.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                           AND la.is_web_checkout=0
                           -- AND op.`state`='bill_paid'
            WHEN 3 THEN        co.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
                           AND co.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                           AND la.is_web_checkout=1  
                           -- AND op.`state`='bill_paid' 
            WHEN 4 THEN
                       (   
                          (
                               co.created_at >= DATE_SUB(CURRENT_DATE,INTERVAL DAY(CURRENT_DATE)-1 DAY)
                           AND co.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                           AND la.is_web_checkout=1  
                           ) 
                           -- AND op.`state`='bill_paid'   
                         OR
                           (
                               op.created_at >= DATE_SUB(CURRENT_DATE,INTERVAL DAY(CURRENT_DATE)-1 DAY)
                           AND op.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                           AND la.is_web_checkout=0  
                           )
                         )   
      END
 AND da.source NOT IN ('engagement_email','engagement_sms') -- IN ('retail','online','smartpaylease.com','smartpaylease.co')    
GROUP BY 1,
         2  
)   AS a 
GROUP BY 1,
         2
) AS b 
) AS c CROSS JOIN (
                   SELECT 1 AS merchant_group
                   UNION ALL 
                   SELECT 2 
                   )  AS d 
GROUP BY 1,
         2
) AS main INNER JOIN ( SELECT 
        `Period`,
        CASE merchant_group
           WHEN 1 THEN 'All'
           WHEN 2 THEN `Merchant Group`
        END                            AS `Merchant Group`,   
        SUM(`Total Apps`)              AS `Total Apps`   
FROM
(
  SELECT 
        period                                                         AS `Period`,
        CASE 
            WHEN merchant_list='Walmart'                   THEN 'SmartPayPlus Retail'
            WHEN merchant_list IS NULL 
                OR 
                 merchant_list IN ('MetroPCS','T-Mobile')  THEN 'Retail'
            WHEN merchant_list LIKE '%Web%'                THEN 'SmartPayPlus Online'
        END                                                            AS `Merchant Group`,
        SUM(total_count)                                               AS `Total Apps`
  FROM 
  (
      SELECT 
          DATE(fe.created_at)                    AS period,
          CASE 
              WHEN (  fe.event LIKE '%Walmart%' 
                    OR 
                      fe.event='TracfoneStore' 
                    )                        THEN 'Walmart'
              WHEN fe.event='store'          THEN 'Store'
                                             ELSE IF(fe.event IN ('provided_email','submitted_form_provided_email'),REPLACE(SUBSTRING_INDEX(SUBSTRING(fe.description,
                                                      LOCATE('"merchant":',fe.description)+LENGTH('"merchant":'),30),',',1),'"',""),
                                                      REPLACE(SUBSTRING_INDEX(SUBSTRING(fe.description,
                                                      LOCATE('"merchant":',fe.description)+LENGTH('"merchant":'),30),',',1),'"',"")
                                                    )
          END                                     AS merchant_list,                                                      
          COUNT(DISTINCT el.email)                AS total_count         
       FROM funnel_events fe
       LEFT JOIN email_leads el ON (el.id = fe.email_lead_id)
       LEFT JOIN emails e       ON (el.email = e.email_address)
       LEFT JOIN users u        ON (e.id = u.primary_email_id)
       WHERE fe.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
         AND fe.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
         AND u.id IS NULL
      GROUP BY 1,
               2
  ) AS a 
 GROUP BY 1,
          2
) AS b CROSS JOIN ( 
                   SELECT 1 AS merchant_group
                   UNION ALL 
                   SELECT 2
                   ) AS c                          
GROUP BY 1,
         2           
) AS online_main ON (    main.`Period`         = online_main.`Period`
                     AND 
                         main.`Merchant Group` = online_main.`Merchant Group` 
                    )
ORDER BY CASE main.`Merchant Group`
           WHEN 'All'                 THEN 1 
           WHEN 'Retail'              THEN 2
           WHEN 'SmartPayPlus Online' THEN 3
           WHEN 'SmartPayPlus Retail' THEN 4 
         END ASC


  
 


SELECT 
             IF(la.is_web_checkout=1,
                DATE(co.created_at),
                DATE(op.created_at)
              )
                                       AS `Transaction Date`,
             COUNT(DISTINCT op.id)     AS `Total Transactions`,
             SUM(op.amount)            AS `Transaction Amount`
     FROM loan_applications la
     LEFT JOIN outgoing_payments         op    ON (la.id  = op.loan_application_id)
     INNER JOIN loans                     l    ON (op.id  = l.outgoing_payment_id)
     INNER JOIN orders o                       ON (o.id   = la.order_id)  
     LEFT  JOIN collaterals              co    ON (la.id  = co.loan_application_id
                                                   AND 
                                                      co.type='CashDeposit'
                                                   AND
                                                     co.status='auth_success'
                                                  ) 
     GROUP BY 1 
     ORDER BY 2 DESC LIMIT 20;






cat("\n")
if (is.element("progress",installed.packages())) {
  print("Progress package already installed, skipping download")
  library(progress)
} else { 
  install.packages("progress",repos="http://cran.us.r-project.org")
  library(progress)
}
cat("\n")
args=commandArgs(trailingOnly = TRUE)
if (length(args)==0) {
  print ("Missing filename")
  quit()
}
raw_data = readLines(args[1])
#raw_data = readLines("49030.htm")
extract = data.frame("ID"=character(),"First_name"=character(),"Last_name"=character(),"Email"=character(),"Course_ID"=character()) 
student_id = vector()
f_name = vector()
l_name = vector()
student_email = vector()
section = character()
crn = vector()
student_index = grep("\\d{9}$",raw_data,value=FALSE)
last_index = grep("End item listing",raw_data,value=FALSE,ignore.case=TRUE)
student_index = append(student_index,last_index,length(student_index))
diff=42
id_pattern = "\\d{9}$"
email_pattern ="[-_a-z0-9]+(\\.[-_a-z0-9]+)?@[-_a-z0-9]+\\.[a-z]+"
crn_pattern = "(CRN)-\\d{5}-\\d{6}"
i = 1
pb = progress_bar$new(total=length(student_index)-1,format="  extracting records [:bar] :percent",clear=FALSE)
system.time({ 
  while (i < length(student_index)) {
    x = student_index[i]
    i=i+1
    section = raw_data[x:(x+(diff))]
    name_section = grep("</td>",section,value=FALSE)
    student_id = append(student_id,gsub("\\s","",grep(id_pattern,section,value=TRUE)),length(student_id))
    #checking if student_email exist, if not append "N/A"
    temp = regmatches(section,regexpr(email_pattern,section,ignore.case=TRUE))
    if (identical (temp,character(0))) { 
      student_email = append(student_email,"N/A",length(student_email))  
    } else {
      student_email = append(student_email,regmatches(section,regexpr(email_pattern,section,ignore.case=TRUE)),length(student_email))
    }
    f_name = append(f_name,gsub("</td>","",(gsub("\\s","",section[name_section[1]]))),length(f_name))
    l_name = append(l_name,gsub("</td>","",(gsub("\\s","",section[name_section[2]]))),length(l_name))
    if (is.na(pmatch("XLIST",unlist(strsplit(grep("<title>",raw_data,value=TRUE)," ")))) == FALSE) {
      crn = append(crn,regmatches(section,regexpr(crn_pattern,section)),length(crn))
    } else {
      crn = regmatches(raw_data,regexpr(crn_pattern,raw_data))
      crn = crn[1]
    }
    pb$tick()
    #Sys.sleep(1/100)
  }
   extract = data.frame("ID"=student_id,"First_name"=f_name,"Last_name"=l_name,"Email"=student_email,"Course_ID"=crn)
   cat("\n")
   cat(paste("Total student records found: ",nrow(extract),"\n",sep=""))
   write.csv(extract,paste(args[1],".csv",sep=""),row.names=FALSE)
   cat(paste(args[1],".csv"," is created","\n",sep=""))

})