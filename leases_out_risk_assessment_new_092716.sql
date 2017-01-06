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
