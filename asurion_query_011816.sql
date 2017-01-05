SELECT 
      'record_type',
      'client_id',
      'lease_number',
      'lease_line_number',
      'purchase_date',
      'store_id',
      'customer_id',
      'first_name',
      'middle_name',
      'last_name',
      'address_line_1',
      'address_line_2',
      'customer_city',
      'customer_state',
      'customer_zip_code',
      'customer_country',
      'cell_phone_number',
      'alternate_phone_number',
      'email_address',
      'transaction_type'                    AS transaction_type,
      'due_date_for_subsequent_billing',
      'transaction_date',
      'product_sku',
      'product_description',
      'imei_esn_number',
      'product_price',
      'warranty_sku' 

UNION ALL

SELECT 
      record_type,
      client_id,
      lease_number,
      lease_line_number,
      purchase_date,
      store_id,
      customer_id,
      first_name,
      IFNULL(middle_name,'')                                AS middle_name,
      last_name,
      address_line_1,
      IFNULL(address_line_2,'')                             AS address_line_2,
      customer_city,
      customer_state,
      customer_zip_code,
      IFNULL(customer_country,'')                           AS customer_country,
      cell_phone_number,
      IFNULL(alternate_phone_number,'')                     AS alternate_phone_number,
      email_address,
      CASE 
           WHEN transact_type=1            THEN 'A' 
           WHEN transact_type IN (2,3,5)   THEN 'C'
           WHEN transact_type=4            THEN 'D'
           WHEN transact_type=6            THEN 'S'
           WHEN transact_type=7            THEN 'E'
                                           ELSE NULL 
      END                                                  AS transaction_type,
      IFNULL(due_date_for_subsequent_billing,'')           AS due_date_for_subsequent_billing,
      IFNULL(CASE 
                 WHEN transact_type=1            THEN purchase_date
                 WHEN transact_type=2            THEN return_date
                 WHEN transact_type=3            THEN application_create_date
                 WHEN transact_type=5            THEN buyout_date
                 WHEN transact_type=4            THEN delinquency_date
                 -- WHEN transact_type=6            THEN due_date_for_subsequent_billing
                 WHEN transact_type=7            THEN last_event_change_date
                                                 ELSE NULL 
             END,''
             )                                             AS transaction_date,
      product_sku,
      product_description,
      imei_esn_number,
      product_price,
      warranty_sku 
FROM 
(
SELECT 
     'D'                                                       AS record_type,
     237836367                                                 AS client_id,
     o.application_number                                      AS lease_number,
     ci.id                                                     AS lease_line_number,
     DATE(l.originated_at)                                     AS purchase_date,
     'WMT01'                                                   AS store_id,
     u.external_id                                             AS customer_id,
     /* u.first_name */ 'test1'                                AS first_name,
     u.middle_name                                             AS middle_name,
     /* u.last_name */ 'test1'                                 AS last_name,
     ad.street                                                 AS address_line_1,
     ad.apt_suite_number                                       AS address_line_2,
     ad.city                                                   AS customer_city,
     ad.state                                                  AS customer_state,
     ad.zip                                                    AS customer_zip_code,
     NULL                                                      AS customer_country,
     ph_m.`number`                                             AS cell_phone_number,
     ph.`number`                                               AS alternate_phone_number,
     (
      SELECT email_address 
        FROM emails 
       WHERE user_id=u.id
       ORDER BY id DESC
       LIMIT 1
      )                                                        AS email_address,
     'A'                                                       AS transaction_type,
     CASE 
         WHEN transact_type=6 THEN DATE(lp.initiated_on)
                                  /*
                                  (SELECT MAX(initiated_on)
                                     FROM loan_payments 
                                    WHERE loan_id=l.id 
                                      AND `state`='completed'
                                      AND collateral_id IS NULL
                                      AND initiated_on BETWEEN IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY)) 
                                      AND                      IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY)) 
                                  )
                                 */ 
                              ELSE NULL 
     END                                                       AS due_date_for_subsequent_billing,
     DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY)                     AS transaction_date,
     ci.sku                                                    AS product_sku,
     IF(ci.kind='device',ci.description,NULL)                  AS product_description,
     IF(ci.kind='device',ci.device_id,NULL)                    AS imei_esn_number,
     IF(ci.kind='device',ci.price_without_tax,NULL)            AS product_price,
     CASE 
         WHEN ci.price_without_tax BETWEEN 0   AND 199 THEN CONCAT(lao.term,'WMT','1')
         WHEN ci.price_without_tax BETWEEN 200 AND 349 THEN CONCAT(lao.term,'WMT','2') 
         WHEN ci.price_without_tax BETWEEN 350 AND 999 THEN CONCAT(lao.term,'WMT','3')
                                                       ELSE NULL 
     END                                                       AS warranty_sku,
     DATE(rp.created_at)                                       AS return_date,
     (SELECT MIN(DATE(original_due_date))
           FROM installments 
          WHERE loan_id=l.id 
            AND original_due_date < CURRENT_DATE
            AND (
                  (
                      actual_repayment_date IS NULL 
                   AND 
                      `state` NOT IN ('void','scheduled')
                   AND 
                       original_due_date >= DATE_ADD(l.originated_at,INTERVAL 30 DAY)      
                  )
              OR  
                 (  
                     (
                           id=i.id 
                       AND 
                           state='overdue'
                       AND 
                          original_due_date >= DATE_ADD(l.originated_at,INTERVAL 30 DAY)  
                      )
                  OR 
                     (
                         id <> i.id 
                      AND   
                         state='overdue' 
                     )
                  )  
                )
         )                                                     AS delinquency_date,
    (SELECT MAX(DATE(settled_on))
      FROM loan_payments 
      WHERE loan_id=l.id 
        AND create_reason IN('OE','RB','EB','OB','ES','OS')
        AND loan_payments.`state`='completed'
    )                                                          AS buyout_date,
    DATE(la.created_at)                                        AS application_create_date,
    (    SELECT MAX(DATE(created_at))
          FROM events 
         WHERE loan_id=l.id 
           AND `type`='StateChangeEvent'
           AND loan_id IS NOT NULL
           AND (     old_state='overdue'
                 AND 
                     new_state IN ('active','behind')
               )
    )                                                          AS last_event_change_date,         
    IF(la.cancel_reason_code='void_with_auth_reversal',1,0)    AS cancel_flag,
    transact_type
FROM loan_applications la 
INNER JOIN orders            o            ON (o.id    = la.order_id)
INNER JOIN users             u            ON (u.id    = o.user_id)
INNER JOIN available_items   ai           ON (ai.id   = o.available_item_id)
INNER JOIN locations         loc          ON (loc.id  = ai.location_id)
INNER JOIN merchants         m            ON (m.id    = loc.merchant_id)
INNER JOIN carts             c            ON (la.id   = c.loan_application_id)
INNER JOIN cart_items        ci           ON (    c.id    = ci.cart_id
                                              AND 
                                                  ci.kind ='device'
                                             )
INNER JOIN outgoing_payments op           ON (la.id   = op.loan_application_id)
INNER JOIN loans             l            ON (op.id   = l.outgoing_payment_id)
INNER JOIN payment_frequency_options pfo  ON (pfo.id  = la.current_payment_frequency_option_id)
INNER JOIN loan_application_offers   lao  ON (la.id   = lao.loan_application_id)
INNER JOIN addresses                 ad   ON (ad.id   = u.current_address_id)
INNER JOIN installments              i    ON (i.id    = (SELECT MIN(id)
                                                           FROM installments 
                                                          WHERE loan_id=l.id 
                                                        )
                                             )
LEFT  JOIN phone_numbers             ph   ON (ph.id   = u.current_phone_number_id)
LEFT  JOIN phone_numbers             ph_m ON (ph_m.id = u.current_mobile_phone_number_id)
LEFT  JOIN returns                   r    ON (op.id   = r.outgoing_payment_id)
LEFT  JOIN return_payments           rp   ON (  r.id    = rp.return_id
                                              AND 
                                                rp.type <>'ConsumerReturnPayment'
                                             )

CROSS JOIN (
              SELECT 1 AS transact_type -- Sales 
              UNION ALL 
              SELECT 2  -- Returns
              UNION ALL 
              SELECT 3  -- Cancel
              UNION ALL 
              SELECT 4  -- Delinquency
              UNION ALL 
              SELECT 5  -- Buyout
              UNION ALL 
              SELECT 6  -- Subsequent billing
              UNION ALL 
              SELECT 7  -- Reactivated
           ) AS trans_type
LEFT JOIN loan_payments              lp   ON (   l.id = lp.loan_id 
                                             AND 
                                                lp.`state`='completed'
                                             AND 
                                                lp.collateral_id IS NULL
                                             AND 
                                                CASE 
                                                     WHEN transact_type=6 THEN 1 
                                                                          ELSE 0
                                                END                              
                                            )
WHERE m.`name`='Walmart'
  AND (
         CASE transact_type
             WHEN 1 THEN     op.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                         AND op.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
             WHEN 2 THEN     rp.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                         AND rp.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))                                 
             WHEN 3 THEN     la.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                         AND la.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
                         AND la.cancel_reason_code='void_with_auth_reversal'
             WHEN 4 THEN   (SELECT MIN(DATE(original_due_date))
                              FROM installments 
                             WHERE loan_id=l.id 
                               AND original_due_date < CURRENT_DATE
                               AND (
                                     (
                                        actual_repayment_date IS NULL 
                                     AND 
                                        state NOT IN ('void','scheduled')
                                     AND 
                                        original_due_date >= DATE_ADD(l.originated_at,INTERVAL 30 DAY)   
                                     )
                                   OR 
                                     (  
                                       (
                                           id=i.id 
                                       AND 
                                           state='overdue'
                                       AND 
                                          original_due_date >= DATE_ADD(l.originated_at,INTERVAL 30 DAY)  
                                       )
                                     OR 
                                       (
                                            id <> i.id 
                                        AND   
                                            state='overdue' 
                                      )
                                     )  
                                   )
                             ) BETWEEN IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)) AND IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
            WHEN 5  THEN  (SELECT MAX(DATE(settled_on))
                             FROM loan_payments 
                            WHERE loan_id=l.id 
                              AND create_reason IN ('OE','RB','EB','OB','ES','OS')
                              AND loan_payments.`state`='completed'
                          ) BETWEEN IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)) AND IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
            WHEN 6 THEN EXISTS (
                                SELECT *
                                 FROM loan_payments 
                                WHERE loan_id=l.id 
                                  AND `state`='completed'
                                  AND initiated_on BETWEEN IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY)) 
                                  AND IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                                  AND collateral_id IS NULL 
                               )
                         AND (
                                 l.`state` IN ('active','behind')
                              OR 
                               EXISTS (  SELECT *
                                         FROM events 
                                        WHERE loan_id=l.id 
                                          AND `type`='StateChangeEvent'
                                          AND loan_id IS NOT NULL
                                          AND (    old_state='overdue'
                                          AND 
                                                 new_state IN ('active','behind')
                                              )
                                         AND created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                                         AND created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))  
                                         ORDER BY id DESC 
                                      LIMIT 1 
                                    )  
                              )
            WHEN 7 THEN EXISTS (
                                 SELECT *
                                 FROM events 
                                 WHERE loan_id=l.id 
                                   AND `type`='StateChangeEvent'
                                   AND loan_id IS NOT NULL
                                   AND (    old_state='overdue'
                                        AND 
                                            new_state IN ('active','behind')
                                       )
                                  AND created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
                                  AND created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))  
                                ORDER BY id DESC 
                                LIMIT 1 
                                 )   
                  ELSE NULL -- should never get here                    
         END                  
       )  
 AND transact_type IN (2,3,5)  /* This is where you are going to make changes to filter out and generate the files 
                              
                              For type A (active sales happened yesterday), you would need to put 1
                              For type C (return, cancel and buyouts), you would need to put (2,3,5)
                              For type D (delinquency), you need to put (4)
                              For type S (subsequent billing), you would need to put 6
                              For type E (reactivation), you would need to put 7

                           */   

) AS a 


