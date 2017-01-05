SELECT
       o.application_number,

       /* these three fields are Ubquity specific */

       /* Ubquity spcific fields */
       1014               AS group_id,
       1334               AS account_id,
       3230               AS location_id,
      /* Ubquity spcific fields */ 
      
       'smartpayleaseutility'  AS username,
       'ops@smartpaylease.com' AS password,

        -- Clark will encrypt these two
       u.first_name,
       u.last_name,

       u.date_of_birth,

       /* Clark will provide that from the vault*/
       NULL               AS social_secruity_number,  
       COALESCE(ph.number,
                ph_m.number
                )         AS phone,
       a.street           AS address1,
       a.apt_suite_number AS address2,
       a.city,
       a.`state`,
       a.zip,
       'N'                AS portfolio_type,
       'C5'               AS account_type,
       pfo.`type`         AS terms_frequency,
       CASE 
            WHEN lao.term IS NULL THEN 
                                    (SELECT term
                                       FROM loan_application_offers 
                                      WHERE loan_application_id=la.id
                                      LIMIT 1
                                     ) 
                              ELSE lao.term 
       END                 AS terms_duration,                       
       CASE 
           WHEN l.`state`='written_off' THEN '+'
           WHEN l.`state`='completed'   THEN '@'
           WHEN 
               ( 
               	--  l.`state`='active'  
                -- OR
                        IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  
                                               
                )  =0                    THEN '0'
           WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 1 AND 9 THEN  '1 - 9' 
             WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 10 AND 23 THEN  'A - N' 
            WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 24 AND 29 THEN  'P - U'
            WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 30 AND 59 THEN  'V'
              WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 60 AND 89 THEN  'W'
            WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 90 AND 119 THEN  'X'
            WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  BETWEEN 120 AND 149 THEN  'Y'
            WHEN  IFNULL(DATEDIFF(CURRENT_DATE,
                                         (SELECT MIN(DATE(original_due_date))
                                            FROM installments 
                                           WHERE loan_id=l.id 
                                             AND original_due_date < CURRENT_DATE
                                             AND (
                                                  (
                                                       actual_repayment_date IS NULL 
                                                    AND 
                                                       state <>'void'
                                                   )
                                                   OR 
                                                     (state='overdue')
                                                  )
                                           )    
                                         ),0
                               )  >=150              THEN 'Z'  
                                                     ELSE '?' -- No history available                                                            
       END                                                               AS payment_ratings,
       CURRENT_DATE                                                      AS account_information_date,
       DATE(l.originated_at)                                             AS account_opened,
       DATE(l.actual_repayment_date)                                     AS closed_date,
       ROUND(l.original_amount,0)                                        AS highest_credit,
       CASE 
            WHEN lao.id IS NOT NULL THEN 
                                          (
                                          	SELECT ROUND(original_amount,0) 
                                          	  FROM installments 
                                          	WHERE loan_id=l.id 
                                          	  AND `state`='scheduled'
                                          	ORDER BY id ASC
                                          	LIMIT 1
                                          )
                                    ELSE 
                                           (
                                             SELECT ROUND(original_amount,0) 
                                               FROM installments i 
                                              WHERE loan_id = l.id 
                                                AND id > (SELECT MIN(id)
                                                	        FROM installments 
                                                	       WHERE loan_id= i.loan_id
                                                	       )
                                                AND `state`='scheduled' 
                                             ORDER BY id ASC 
                                             LIMIT 1   
                                           	 )   
       END                                                                AS scheduled_payment,
       CASE 
            WHEN lao.id IS NOT NULL THEN 
                                          (
                                            SELECT ROUND(SUM(actual_repayment_amount),0) 
                                              FROM installments 
                                            WHERE loan_id=l.id 
                                              AND `state`='completed'
                                            -- ORDER BY id ASC
                                            -- LIMIT 1
                                          )
                                    ELSE 
                                           (
                                             SELECT ROUND(SUM(actual_repayment_amount),0) 
                                               FROM installments i 
                                              WHERE loan_id = l.id 
                                                AND id > (SELECT MIN(id)
                                                          FROM installments 
                                                         WHERE loan_id= i.loan_id
                                                         )
                                                AND `state`='completed' 
                                             -- ORDER BY id ASC 
                                             -- LIMIT 1   
                                             )   
       END                                                               AS actual_payment,
       (
        SELECT MAX(DATE(settled_on))
          FROM loan_payments 
         WHERE loan_id=l.id 
          AND  `state`='completed'
          AND  collateral_id IS NULL  -- Only the payments towards installments
       	)                                                                 AS last_payment_date,
       IFNULL((
        SELECT 
              SUM(ROUND(COALESCE(modified_amount,original_amount) + IFNULL(additional_fees,0),0))
        FROM installments 
        WHERE loan_id=l.id
          AND `state` IN ('scheduled','overdue')
       	),0)                                                               AS current_balance,
       IFNULL((SELECT SUM(original_amount)
                 FROM installments 
                WHERE loan_id=l.id 
                  AND original_due_date < CURRENT_DATE
                  AND (
                        (
                           actual_repayment_date IS NULL 
                        AND 
                          `state` <>'void'
                          )
                        OR 
                       (`state`='overdue') 
                       ) 
              ),0)                                                        AS amount_past_due,
        (SELECT MIN(DATE(original_due_date))
           FROM installments 
          WHERE loan_id=l.id 
            AND original_due_date < CURRENT_DATE
            AND (
                  (
                      actual_repayment_date IS NULL 
                   AND 
                      state <>'void'
                  )
                OR 
                  (state='overdue')
                 )
         )                                                                AS delinquency_date,
        NULL                                                              AS bank_account_number,
        NULL                                                              AS bank_routing_number,
        u.id                                                              AS customer_account_number,
        NULL                                                              AS change_indicator,
        NULL                                                              AS consumer_account_number_old,
        NULL                                                              AS xml_response_tracking_number,
        CASE 
            WHEN lao.id IS NOT NULL THEN 
                                          (
                                          	SELECT MIN(DATE(COALESCE(modified_due_date,original_due_date))) 
                                          	  FROM installments 
                                          	WHERE loan_id=l.id 
                                          )
                                    ELSE 
                                           (
                                             SELECT MIN(DATE(COALESCE(modified_due_date,original_due_date))) 
                                               FROM installments i 
                                              WHERE loan_id = l.id 
                                                AND id > (SELECT MIN(id)
                                                	        FROM installments 
                                                	       WHERE loan_id= i.loan_id
                                                	       )  
                                           	 )   
       END                                                                AS first_due_date,
       CASE 
            WHEN lao.id IS NOT NULL THEN 
                                          CASE 
                                              WHEN (
                                                      SELECT state 
                                                        FROM installments 
                                                       WHERE loan_id=l.id 
                                                       ORDER BY id ASC
                                                        LIMIT 1
                                                    ) = 'overdue' THEN 'true'
                                                                  ELSE 'false'
                                          END
                                    ELSE 
                                          CASE 
                                              WHEN  (
                                                     SELECT state 
                                                       FROM installments i 
                                                      WHERE loan_id = l.id 
                                                        AND id > (SELECT MIN(id)
                                                                    FROM installments 
                                                                   WHERE loan_id= i.loan_id
                                                                 ) 
                                                      ORDER BY id ASC 
                                                      LIMIT 1   
                                                    )  ='overdue' THEN 'true'
                                                                  ELSE 'false'
                                          END                          

       END                                                               AS first_payment_default
FROM loan_applications la 
INNER JOIN orders o                      ON (o.id   = la.order_id)
INNER JOIN users  u                      ON (u.id   = o.user_id)
INNER JOIN available_items ai            ON (ai.id  = o.available_item_id)
INNER JOIN locations       loc           ON (loc.id = ai.location_id)
INNER JOIN merchants       m             ON (m.id   = loc.merchant_id)
INNER JOIN outgoing_payments op          ON (la.id  = op.loan_application_id)
INNER JOIN loans                   l     ON (op.id  = l.outgoing_payment_id)
INNER JOIN installments           i_min  ON (i_min.id = (SELECT MIN(id)
                                                         FROM installments 
                                                         WHERE loan_id=l.id
                                                         )
                                            )
LEFT  JOIN payment_frequency_options pfo ON (pfo.id = la.current_payment_frequency_option_id)
LEFT  JOIN loan_application_offers lao   ON (   la.id  = lao.loan_application_id
                                            AND 
                                                 lao.equal_installments=0
                                            AND 
                                                 lao.upfront_installment_percent=0.0      
                                            )
LEFT  JOIN phone_numbers           ph    ON (ph.id  = u.current_phone_number_id)
LEFT  JOIN phone_numbers           ph_m  ON (ph_m.id  = u.current_mobile_phone_number_id)
LEFT  JOIN addresses               a     ON (a.id   = u.current_address_id)
-- LEFT  JOIN funding_sources         fs    ON (fs.id  = la.funding_source_id)
-- LEFT  JOIN bank_routing_numbers    brn   ON (brn.id = fs.bank_routing_number_id)

WHERE la.`type` IS NULL -- Smartypay loans
  AND l.originated_at >= '2015-11-07' 
LIMIT 100 -- Sample file size


 

