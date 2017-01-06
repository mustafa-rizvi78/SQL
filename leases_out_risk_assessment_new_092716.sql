SELECT  
      DATE_FORMAT(end_date,'%M %d')                                         AS display_text,
      total_active_leases                                                   AS count_active_leases,
      lease_out_of_risk_assessment                                          AS count_lease_out_of_risk,
      lease_into_risk_assessment + IFNULL(lease_out_of_risk_assessment,0)   AS lease_went_into_assessment
FROM         
(
SELECT 
      start_date,
      end_date,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_date IS NULL
                       AND 
                          loan_originated_at <=end_date  ,
                          loan_id,
                          NULL
                       )
           )                                   AS total_active_leases,
    
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                           first_delinquency_date IS NOT NULL
                        AND 
                           first_delinquency_date BETWEEN start_date AND end_date  
                         -- loan_originated_at <= '2016-08-31'  
                        ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment,  
      SUM(IF( TRUE,   
                 lease_out_of_risk_assessment,NULL
            )
          )                                                        AS lease_out_of_risk_assessment     
FROM                  
(
SELECT 
      m.`name`                           AS merchant_name,
      l.id                               AS loan_id,
      label,
      start_date,
      LAST_DAY(start_date)               AS end_date,
      MAX(l.originated_at)               AS loan_originated_at,
      MAX(IF(l.`state`='completed',1,0)) AS loan_state,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
         i.original_due_date <= CASE 
                                      WHEN MONTH(start_date) = MONTH(CURRENT_DATE) THEN DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY)
                                                                                   ELSE LAST_DAY(start_date)
                                END    
      -- AND 
      --    i.original_due_date > '2016-04-01'
      ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_date, 
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= start_date
             AND 
                  i.actual_repayment_date < LAST_DAY(start_date),
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment
FROM loan_applications la 
INNER JOIN orders           o      ON (o.id = la.order_id)
INNER JOIN carts            c      ON (la.id  = c.loan_application_id)
INNER JOIN cart_items       ci     ON (c.id   = ci.cart_id)
INNER JOIN available_items ai      ON (ai.id  = o.available_item_id)
INNER JOIN locations       loc     ON (loc.id = ai.location_id)
INNER JOIN merchants       m       ON (m.id   = loc.merchant_id)
INNER JOIN outgoing_payments op    ON (la.id = op.loan_application_id)
INNER JOIN loans             l     ON (op.id = l.outgoing_payment_id)
INNER JOIN installments      i     ON (   l.id  = i.loan_id
                                         AND 
                                       i.original_due_date <= DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)
                                       )
CROSS JOIN ( 

             SELECT 
                   DATE_FORMAT(`date`,'%m-%Y')                 AS label,
                   MAX(`month`)                                AS start_date
             FROM reporting_dates
             WHERE `date` BETWEEN '2015-03-01' AND CURRENT_DATE
             GROUP BY 1  
           ) AS display_label
WHERE la.`type` IS NULL
  AND l.`state` <> 'void' 
  AND op.`state` NOT IN ('void', 'return_in_progress')
  AND la.created_at >'2016-03-01'
  AND m.`name`='Walmart'
GROUP BY 1,
         2,
         3,
         4,
         5
) AS a 
GROUP BY 1,
         2
ORDER BY 1 DESC         
) AS b 



SELECT  
      DATE_FORMAT(end_date,'%M %d')                                         AS display_text,
      total_active_leases                                                   AS count_active_leases,
      lease_out_of_risk_assessment                                          AS count_lease_out_of_risk,
      lease_into_risk_assessment + IFNULL(lease_out_of_risk_assessment,0)   AS lease_went_into_assessment
FROM         
(
SELECT 
      start_date,
      end_date,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_date IS NULL
                       AND 
                          loan_originated_at <=end_date  ,
                          loan_id,
                          NULL
                       )
           )                                   AS total_active_leases,
    
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                           first_delinquency_date IS NOT NULL
                        AND 
                           first_delinquency_date BETWEEN start_date AND end_date,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment,  
      SUM(IF( TRUE,   
                 lease_out_of_risk_assessment,NULL
            )
          )                                                        AS lease_out_of_risk_assessment     
FROM                  
(
SELECT 
      m.`name`                           AS merchant_name,
      l.id                               AS loan_id,
      label,
      start_date,
      CASE 
                 WHEN MONTH(start_date) = MONTH(CURRENT_DATE) THEN DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY)
                                                              ELSE LAST_DAY(start_date)
      END                                AS end_date,
      MAX(l.originated_at)               AS loan_originated_at,
      MAX(IF(l.`state`='completed',1,0)) AS loan_state,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
         i.original_due_date <= CASE 
                                      WHEN MONTH(start_date) = MONTH(CURRENT_DATE) THEN DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)
                                                                                   ELSE LAST_DAY(start_date)
                                END,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_date, 
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= start_date
             AND 
                  i.actual_repayment_date < LAST_DAY(start_date),
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment
FROM loan_applications la 
INNER JOIN orders           o      ON (o.id = la.order_id)
INNER JOIN carts            c      ON (la.id  = c.loan_application_id)
INNER JOIN cart_items       ci     ON (c.id   = ci.cart_id)
INNER JOIN available_items ai      ON (ai.id  = o.available_item_id)
INNER JOIN locations       loc     ON (loc.id = ai.location_id)
INNER JOIN merchants       m       ON (m.id   = loc.merchant_id)
INNER JOIN outgoing_payments op    ON (la.id = op.loan_application_id)
INNER JOIN loans             l     ON (op.id = l.outgoing_payment_id)
INNER JOIN installments      i     ON (   l.id  = i.loan_id
                                         AND 
                                       i.original_due_date <= DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)
                                       )
CROSS JOIN ( 
                 SELECT 
                   DATE_FORMAT(`date`,'%m-%Y')    AS label,
                   MAX(`month`)                                  AS start_date
             FROM reporting_dates
             WHERE `date` BETWEEN '2016-03-01' AND DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)
             GROUP BY 1 
           ) AS display_label
WHERE la.`type` IS NULL
  AND l.`state` <> 'void' 
  AND op.`state` NOT IN ('void', 'return_in_progress')
  AND la.created_at >'2016-03-01'
  AND m.`name`='Walmart'
GROUP BY 1,
         2,
         3,
         4,
         5
) AS a 
GROUP BY 1,
         2
ORDER BY 2 DESC         
) AS b






SELECT 
      CAST(DATE_FORMAT(`date`,'%m') AS UNSIGNED)  AS label,
      MAX(`month`)                                AS start_date
FROM reporting_dates
WHERE `date` BETWEEN '2016-03-01' AND CURRENT_DATE
GROUP BY 1       


SELECT  
      CASE display_label.label
          WHEN 1 THEN 'September 30'
          WHEN 2 THEN 'August 31'
          WHEN 3 THEN 'July 31'
          WHEN 4 THEN 'June 30'
          WHEN 5 THEN 'May 31'
          WHEN 6 THEN 'April 30'
          WHEN 7 THEN 'March 31'
                 ELSE NULL 
      END                         AS display_text,
      CASE display_label.label 
           WHEN 1 THEN  `Total Active as of Sep 16th`
           WHEN 2 THEN  `Total Active as of Aug 16th`
           WHEN 3 THEN  `Total Active as of Jul 16th`
           WHEN 4 THEN  `Total Active as of June 16th` 
           WHEN 5 THEN  `Total Active as of May 16th`
           WHEN 6 THEN  `Total Active as of April 16th`
           WHEN 7 THEN  `Total Active as of March 16th`
                  ELSE  NULL 
      END                         AS count_active_leases,
      CASE display_label.label
           WHEN 1 THEN  lease_out_of_risk_assessment_september
           WHEN 2 THEN  lease_out_of_risk_assessment_august
           WHEN 3 THEN  lease_out_of_risk_assessment_july
           WHEN 4 THEN  lease_out_of_risk_assessment_june 
           WHEN 5 THEN  lease_out_of_risk_assessment_may
           WHEN 6 THEN  lease_out_of_risk_assessment_april
           WHEN 7 THEN  lease_out_of_risk_assessment_march
                  ELSE  NULL 
      END                         AS count_lease_out_of_risk,
      CASE display_label.label 
           WHEN 1 THEN  lease_into_risk_assessment_september   + IFNULL(lease_out_of_risk_assessment_september,0)
           WHEN 2 THEN  lease_into_risk_assessment_august      + IFNULL(lease_out_of_risk_assessment_august,0)
           WHEN 3 THEN  lease_into_risk_assessment_july        + IFNULL(lease_out_of_risk_assessment_july,0)
           WHEN 4 THEN  lease_into_risk_assessment_june        + IFNULL(lease_out_of_risk_assessment_june,0)
           WHEN 5 THEN  lease_into_risk_assessment_may         + IFNULL(lease_out_of_risk_assessment_may,0)
           WHEN 6 THEN  lease_into_risk_assessment_april       + IFNULL(lease_out_of_risk_assessment_april,0)
           WHEN 7 THEN  lease_into_risk_assessment_march       + IFNULL(lease_out_of_risk_assessment_march,0)
                  ELSE  NULL  
      END                         AS lease_went_into_assessment
FROM         
(
SELECT 
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_aug_16 IS NULL
                       AND 
                          loan_originated_at <='2016-09-30'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of Sep 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_aug_16 IS NULL
                       AND 
                          loan_originated_at <='2016-08-31'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of Aug 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_jul_16 IS NULL
                       AND 
                          loan_originated_at <='2016-07-31'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of Jul 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_june_16 IS NULL
                       AND 
                         loan_originated_at <='2016-06-30'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of June 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_may_16 IS NULL
                        AND 
                          loan_originated_at <= '2016-05-31'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of May 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_apr_16 IS NULL
                        AND 
                         loan_originated_at <='2016-04-30'  ,
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of April 16th`,
       COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_mar_16 IS NULL
                        AND 
                         loan_originated_at <='2016-03-31',
                          loan_id,
                          NULL
                       )
           )                                   AS `Total Active as of March 16th`,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                           first_delinquency_before_aug_16 IS NOT NULL
                        AND 
                           first_delinquency_before_aug_16 BETWEEN '2016-09-01' AND '2016-09-30'  
                         -- loan_originated_at <= '2016-08-31'  
                        ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_september,  
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                           first_delinquency_before_aug_16 IS NOT NULL
                        AND 
                           first_delinquency_before_aug_16 BETWEEN '2016-08-01' AND '2016-08-31'  
                         -- loan_originated_at <= '2016-08-31'  
                        ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_august, 
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                           first_delinquency_before_jul_16 IS NOT NULL
                        AND 
                            first_delinquency_before_jul_16 BETWEEN '2016-07-01' AND '2016-07-31'  
                         --  loan_originated_at <= '2016-07-31'  
                        ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_july,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_june_16 IS NOT NULL
                        AND 
                           first_delinquency_before_june_16 BETWEEN '2016-06-01' AND '2016-06-30' 
                         --    loan_originated_at <= '2016-06-30'  
                        ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_june,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_may_16 IS NOT NULL
                       AND 
                           first_delinquency_before_may_16 BETWEEN '2016-05-01' AND '2016-05-31'  
                         -- loan_originated_at <= '2016-05-31'
                          ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_may,
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_apr_16 IS NOT NULL
                       AND 
                          first_delinquency_before_apr_16 BETWEEN '2016-04-01' AND '2016-04-30'  
                         -- loan_originated_at <= '2016-04-30'
                          ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_april,   
      COUNT(DISTINCT IF(    loan_state <> 1 
                        AND 
                          first_delinquency_before_mar_16 IS NOT NULL
                       AND 
                           first_delinquency_before_mar_16 BETWEEN '2016-03-01' AND '2016-03-31'  
                          -- loan_originated_at <='2016-03-31'  
                          ,
                          loan_id,
                          NULL
                       )
           )                                    AS lease_into_risk_assessment_march,
      SUM(IF( TRUE,   
                 lease_out_of_risk_assessment_march,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_march,            
      SUM(IF( TRUE,   
                 lease_out_of_risk_assessment_april,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_april,
      SUM(IF(TRUE,  
                 lease_out_of_risk_assessment_may,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_may,
      SUM(IF(TRUE,  
                 lease_out_of_risk_assessment_june,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_june,
      SUM(IF(TRUE,
                 lease_out_of_risk_assessment_july,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_july,
      SUM(IF(TRUE,
                 lease_out_of_risk_assessment_august,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_august,
      SUM(IF(TRUE,
                 lease_out_of_risk_assessment_september,NULL
            )
          )                                                      AS lease_out_of_risk_assessment_september
FROM 
(
SELECT 
      m.`name`                           AS merchant_name,
      l.id                               AS loan_id,
      MAX(l.originated_at)               AS loan_originated_at,
      MAX(IF(l.`state`='completed',1,0)) AS loan_state,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
         i.original_due_date <= '2016-03-31'   
      -- AND 
      --    i.original_due_date > '2016-04-01'
      ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_mar_16,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
         i.original_due_date <= '2016-04-30'   
      -- AND 
      --    i.original_due_date > '2016-04-01'
      ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_apr_16,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
         i.original_due_date <= '2016-05-31'
      -- AND 
      --    i.original_due_date > '2016-05-01'
      ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_may_16,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
        i.original_due_date <= '2016-06-30'
     -- AND 
     --     i.original_due_date > '2016-06-01'
     ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_june_16,
      MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
          i.original_due_date <= '2016-07-31'
    --  AND 
    --     i.original_due_date > '2016-07-01'
     ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_jul_16,
       MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
          i.original_due_date < CASE 
                                      WHEN MONTH('2016-08-31') = MONTH(CURRENT_DATE) THEN DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY)
                                                                 ELSE LAST_DAY(CURRENT_DATE)
                                END                                 
    --  AND 
    --     i.original_due_date > '2016-07-01'
     ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_aug_16,
       MIN(IF(
          ( 
             i.`state`='overdue'
          OR 
             (              
                   i.actual_repayment_date IS NULL 
              AND 
                   i.`state` <> 'void'
              )
          ) 
      AND 
          i.original_due_date < CASE 
                                      WHEN MONTH('2016-09-30') = MONTH(CURRENT_DATE) THEN DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY)
                                                                 ELSE LAST_DAY(CURRENT_DATE)
                                END                                 
    --  AND 
    --     i.original_due_date > '2016-07-01'
     ,
          COALESCE(i.original_due_date,i.original_due_date),
          NULL    
        ))                                                          AS first_delinquency_before_sep_16, 
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-03-01'
             AND 
                  i.actual_repayment_date < '2016-04-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_march,
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-04-01'
             AND 
                  i.actual_repayment_date < '2016-05-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_april,
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-05-01' 
             AND 
                  i.actual_repayment_date < '2016-06-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_may,
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-06-01'
             AND 
                  i.actual_repayment_date < '2016-07-01'     ,
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_june,
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-07-01'
             AND  
                  i.actual_repayment_date < '2016-08-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_july,
      COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-08-01'
             AND  
                  i.actual_repayment_date < '2016-09-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_august,
       COUNT(DISTINCT IF(    i.index_number >1 
             AND 
                  i.actual_repayment_date >= DATE_ADD(i.original_due_date,INTERVAL 1 DAY)
             AND 
                  i.actual_repayment_date >= '2016-09-01'
             AND  
                  i.actual_repayment_date < '2016-10-01',
                i.`id`,
                NULL           
               )
         )                                                          AS lease_out_of_risk_assessment_september
FROM loan_applications la 
INNER JOIN orders           o      ON (o.id = la.order_id)
INNER JOIN carts            c      ON (la.id  = c.loan_application_id)
INNER JOIN cart_items       ci     ON (c.id   = ci.cart_id)
INNER JOIN available_items ai      ON (ai.id  = o.available_item_id)
INNER JOIN locations       loc     ON (loc.id = ai.location_id)
INNER JOIN merchants       m       ON (m.id   = loc.merchant_id)
INNER JOIN outgoing_payments op    ON (la.id = op.loan_application_id)
INNER JOIN loans             l     ON (op.id = l.outgoing_payment_id)
INNER JOIN installments      i     ON (   l.id  = i.loan_id
                                         AND 
                                       i.original_due_date <= DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)
                                       )
WHERE la.`type` IS NULL
  AND l.`state` <> 'void' 
  AND op.`state` NOT IN ('void', 'return_in_progress')
  AND la.created_at >'2016-03-01'
  AND m.`name`='Walmart'
GROUP BY 1,
         2
) AS a 
) AS b CROSS JOIN ( 
                   SELECT 1  AS label 
                   UNION ALL 
                   SELECT 2 
                   UNION ALL 
                   SELECT 3
                   UNION ALL 
                   SELECT 4
                   UNION ALL 
                   SELECT 5
                   UNION ALL 
                   SELECT 6
                   UNION ALL 
                   SELECT 7
                  ) AS display_label