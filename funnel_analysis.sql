SELECT
       transaction_date,
       term,
       email,
       SUBSTRING_INDEX(GROUP_CONCAT(updated_at SEPARATOR ','),',',1)                               AS updated_at,
       REPLACE(
               REPLACE(SUBSTRING_INDEX(GROUP_CONCAT(store_login_id SEPARATOR ':'),':',1),'"',''),
               ',',''
              )                                                                                    AS store_login_id,
       SUM(credit_line)                                                                            AS credit_line,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_full_application',event_list) >0,email,NULL))    AS full_application,
       /*
       COUNT(DISTINCT IF(   FIND_IN_SET('api_walmart_status_application',event_list) >0
       	                 AND
       	                    FIND_IN_SET('1',is_successful_decision) > 0,email,NULL))               AS decision_approved,
       */
       -- COUNT(DISTINCT IF(SUBSTRING(is_approved_list,1,3)='[0]',email,NULL))                        AS decision_approved,
       COUNT(DISTINCT IF(FIND_IN_SET('[0]',is_approved_list) >0,email,NULL))                       AS decision_approved,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_cart_information',event_list) >0,email,NULL))    AS cart_information,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_lease_agreement_get',event_list) >0,email,NULL)) AS lease_agreement_get,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_lease_agreement',event_list) >0,email,NULL))     AS lease_agreement,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_add_payment_card',event_list) >0,email,NULL))    AS add_payment_card_attempts,
       COUNT(DISTINCT IF(   FIND_IN_SET('api_walmart_status_payment',event_list) >0
       	                 AND
       	                    FIND_IN_SET('0',is_add_payment_success) > 0,email,NULL))               AS add_payment_card_successfully,
       COUNT(DISTINCT IF(   FIND_IN_SET('api_walmart_status_payment',event_list) >0,email,NULL))   AS status_payment_attempts,
       COUNT(DISTINCT IF(   FIND_IN_SET('api_walmart_status_payment',event_list) >0
       	                 AND
       	                    FIND_IN_SET('1',is_successful_payment) > 0,email,NULL))                AS status_payment,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_merchant_vpc_get',event_list) >0,email,NULL))    AS merchant_vpc_get,
       COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_process_return',event_list) >0,email,NULL))      AS process_return,
       IF(COUNT(DISTINCT IF(FIND_IN_SET('api_walmart_merchant_vpc_get',event_list) >0,email,NULL))=1,wex_card_charged,0) AS vpc_charged
FROM
(
SELECT
      transaction_date,
      email,
      GROUP_CONCAT(updated_at ORDER BY id DESC SEPARATOR ',')          AS updated_at,
      MAX(credit_line)                                                 AS credit_line,
      MAX(term)                                                        AS term,
      MAX(IF(user_id IS NOT NULL,1,0))                                 AS is_become_user,
      GROUP_CONCAT(store_login_id SEPARATOR ':')                       AS store_login_id,
      GROUP_CONCAT(event SEPARATOR ',')                                AS event_list,
      GROUP_CONCAT(IF(    event='api_walmart_status_payment'
      	              AND response_status_for_payment='success',1,0)
                  )                                                    AS is_successful_payment,
      GROUP_CONCAT(IF(    event='api_walmart_status_application'
      	              AND response_status_for_application ='success',1,0)
                  )                                                    AS is_successful_decision,
      GROUP_CONCAT(response_codes_application_status
      	           ORDER BY funnel_event_id DESC SEPARATOR ','
      	           )                                                   AS is_approved_list,
      GROUP_CONCAT(IF(    event='api_walmart_add_payment_card'
      	              AND response_codes_add_payment_card ='[0]',1,0)
                  )                                                    AS is_add_payment_success,
      MAX(wex_card_charged)                                            AS wex_card_charged
FROM
(
SELECT
       DATE(fe.created_at)                                       AS transaction_date,
       fe.updated_at,
       fe.id                                                     AS funnel_event_id,
       el.id,
       u.id                                                      AS user_id,
       el.email,
       fe.event,
       lao.term,
       da.credit_line,
       SUBSTRING(fe.description,
                 LOCATE('"store_login_id":"',fe.description)
                   +LENGTH('"store_login_id":"'),13
                )                                               AS store_login_id,
       IF(fe.event='api_walmart_status_payment',SUBSTRING(fe.description,
                    LOCATE('"response_status":"',fe.description)
                   +LENGTH('"response_status":"'),7
                   ),NULL)                                       AS response_status_for_payment,
       IF(fe.event='api_walmart_status_application',SUBSTRING(fe.description,
                    LOCATE('"response_status":"',fe.description)
                   +LENGTH('"response_status":"'),7
                   ),NULL)                                       AS response_status_for_application,
       IF(fe.event='api_walmart_status_application',SUBSTRING(fe.description,
                    LOCATE('"response_codes":',fe.description)
                   +LENGTH('"response_codes":'),3
                   ),NULL)                                       AS response_codes_application_status,
       IF(fe.event='api_walmart_add_payment_card',SUBSTRING(fe.description,
                    LOCATE('"response_codes":',fe.description)
                   +LENGTH('"response_codes":'),4
                   ),NULL)                                       AS response_codes_add_payment_card,
       IF((select 1 from wex_vpc_auth_responses w where w.outgoing_payment_id = op.id and response='Approval' limit 1)=1,1,0) AS wex_card_charged
FROM funnel_events fe
LEFT JOIN email_leads el              ON (el.id = fe.email_lead_id)
LEFT JOIN emails      e               ON (el.email = e.email_address)
LEFT JOIN users       u               ON (u.id     = e.user_id)
LEFT JOIN orders      o               ON (u.id     = o.user_id)
LEFT JOIN loan_applications la        ON (o.id     = la.order_id)
LEFT JOIN outgoing_payments op        ON (la.id    = op.loan_application_id)
LEFT JOIN decision_attempts da        ON (da.id    = (SELECT MAX(id)
                                                        FROM decision_attempts
                                                       WHERE loan_application_id=la.id
                                                     )
                                         )
LEFT JOIN loan_application_offers lao ON (la.id = lao.loan_application_id)
WHERE fe.event LIKE '%walmart%'
  AND fe.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
  AND fe.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
) AS a
GROUP BY transaction_date,
         email
) AS b
GROUP BY transaction_date,
         term,
         email
ORDER BY updated_at DESC
