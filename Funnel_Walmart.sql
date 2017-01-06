SELECT
       period,
       m_name,                                                               
       COUNT(DISTINCT IF(prv_name_id=1 AND id IS NOT NULL,id,NULL))
       +  SUM(IF(id IS NULL,prv_name_id,0))                                         AS application_submitted,
       COUNT(DISTINCT IF(prv_res_id=1 AND id IS NOT NULL,id,NULL))
       +  SUM(IF(id IS NULL,prv_res_id,0))                                          AS application_passed_IDV,
       COUNT(DISTINCT IF(ida_count=1 AND id IS NOT NULL,id,NULL))                   AS application_decisioned,
       COUNT(DISTINCT IF(approved_count=1,id,NULL))                                 AS approved_count,
       COUNT(DISTINCT IF(completed_count=1,id,NULL))                                AS completed_count,
       COUNT(DISTINCT IF(cart_count=1 AND id IS NOT NULL,id,NULL))                  AS application_added_cart_items,
       COUNT(DISTINCT IF(agreed_to_term_count=1 AND id IS NOT NULL,id,NULL))        AS application_agreed_to_terms,
       COUNT(DISTINCT IF(entered_card_count=1 AND id IS NOT NULL,id,NULL))          AS application_swiped_card,
       COUNT(DISTINCT IF(debitcard_count=1 AND id IS NOT NULL,id,NULL))             AS application_passed_bin_filter,
       COUNT(DISTINCT IF(fraud_check_triggered=1 AND id IS NOT NULL,id,NULL))       AS application_triggered_KBA,
       COUNT(DISTINCT IF(fraud_check_passed=1 AND id IS NOT NULL,id,NULL))          AS application_passed_KBA,
       COUNT(DISTINCT IF(auth_count=1 AND id IS NOT NULL,id,NULL))                  AS application_successful_payment,
       COUNT(DISTINCT IF(vdc_funded=1 AND id IS NOT NULL,id,NULL))                  AS application_generated_VDC,
       COUNT(DISTINCT IF(vdc_charged=1 AND id IS NOT NULL,id,NULL))                 AS application_VDC_card_charged,
       COUNT(DISTINCT IF(returned_count=1 AND id IS NOT NULL,id,NULL))              AS total_returns,
       COUNT(DISTINCT IF(cut_off=15,id,NULL))                                       AS approved_15_months,
       COUNT(DISTINCT IF(cut_off=22,id,NULL))                                       AS approved_22_months,
       COUNT(DISTINCT IF(cut_off=24,id,NULL))                                       AS approved_24_months,
       COUNT(DISTINCT IF(installment=15,id,NULL))                                   AS completed_15_months,
       COUNT(DISTINCT IF(installment=22,id,NULL))                                   AS completed_22_months,
       COUNT(DISTINCT IF(installment=24,id,NULL))                                   AS completed_24_months,  
       IFNULL(SUM(credit_line)/SUM(approved_count),0)                               AS avg_approved_amount,
       IFNULL(SUM(amount)/SUM(completed_count),0)                                   AS avg_shopping_amount
FROM
(

SELECT
           period,
           NULL            AS id,
           NULL            AS la_id,
           email_leads,
           prv_name_id,
           prv_res_id,
           0               AS ida_count,
           0               AS approved_count,
           0               AS decision_error,
           0               AS cart_count,
           0               AS entered_card_count,
           0               AS debitcard_count,
           0               AS auth_count,
           0               AS completed_count,
           0               AS shipped_count,
           0               AS avs_count,
           0               AS agreed_to_term_count,
           0               AS fraud_check_triggered,
           0               AS fraud_check_passed,
           0               AS returned_count,
           0               AS vdc_funded,
           0               AS ach_transfer_initiated,
           0               AS vdc_charged,
           0               AS ach_transfer_completed,
           0               AS credit_line,
           0               AS amount,
           NULL            AS installment,
           NULL            AS cut_off,
           loc_name,
           principal_id,
           m_name,
           login_id,
           us_state,
           city,
           NULL            AS f_name,
           store_type,
           loc_id,
           street,
           apt_suite_number,
           zip,
           phone_number,
           current_disbursement,
           last_4_number
  FROM (
                                    SELECT
                                               CASE
                                                    WHEN period_filter=1  THEN rd.`date`
                                                    WHEN period_filter=2  THEN rd.`week`
                                                    WHEN period_filter=3  THEN rd.`month`
                                               END                                               AS period,
                                               m_name,
                                               login_id,
                                               street,
                                               apt_suite_number,
                                               us_state,
                                               city,
                                               zip,
                                               loc_name,
                                               loc_id,
                                               phone_number,
                                               principal_id,
                                               store_type,
                                               metro_market,
                                               current_disbursement,
                                               last_4_number,
                                               CASE
                                                   WHEN days_appeared > 1                   THEN COUNT(DISTINCT
                                                                                                                IF(max_event_day=max_from_event_list,
                                                                                                                  a.email_leads,
                                                                                                                  NULL
                                                                                                                  )
                                                                                                      )
                                                                                            ELSE COUNT(DISTINCT a.email_leads)
                                               END                                                                            AS email_leads,
                                               CASE
                                                   WHEN days_appeared > 1  THEN     COUNT(DISTINCT
                                                                                              IF(FIND_IN_SET('submit_button_first_page',event_list) >0
                                                                                                AND max_event_day=max_from_event_list,
                                                                                                a.email_leads,
                                                                                                NULL
                                                                                                )
                                                                                      )
                                                                            ELSE   COUNT(DISTINCT
                                                                                              IF(FIND_IN_SET('submit_button_first_page',event_list) >0
                                                                                                ,
                                                                                                a.email_leads,
                                                                                                NULL
                                                                                                )
                                                                                        )
                                                END
                                                                                                                                 AS prv_name_id,
                                                CASE
                                                   WHEN days_appeared > 1  THEN     COUNT(DISTINCT
                                                                                              IF(FIND_IN_SET('submit_button_second_page',event_list) >0
                                                                                                AND max_event_day=max_from_event_list,
                                                                                                a.email_leads,
                                                                                                NULL
                                                                                                )
                                                                                      )
                                                                            ELSE   COUNT(DISTINCT
                                                                                              IF(FIND_IN_SET('submit_button_second_page',event_list) >0
                                                                                                ,
                                                                                                a.email_leads,
                                                                                                NULL
                                                                                                )
                                                                                         )
                                                END                                                                               AS prv_res_id
                                        FROM
                                             (
                                                  SELECT
                                                         IF(el.location_id IS NOT NULL,el.email,NULL)             AS email_leads,
                                                         DATE(COALESCE(fe.created_at,el.created_at))              AS period,
                                                         loc.name                                                 AS loc_name,
                                                         m.name                                                   AS m_name,
                                                         sl.login_id,
                                                         a.state                                                  AS us_state,
                                                         a.city,
                                                         a.street,
                                                         a.apt_suite_number,
                                                         a.zip,
                                                         loc.id                                                   AS loc_id,
                                                         loc.business_phone                                       AS phone_number,
                                                         loc.principal_id,
                                                         IF(pu.belongs_to_merchant = 1,'corporate','independent') AS store_type,
                                                         NULL                                                     AS metro_market,
                                                         CASE WHEN dm2.type = 'DebitCardDisbursementMechanism' THEN 'VDC'
                                                              WHEN dm2.type = 'AchDisbursementMechanism'       THEN 'ACH'
                                                         END                                                      AS current_disbursement,
                                                         IF(dm2.type = 'AchDisbursementMechanism',
                                                            mfs.last_numbers,
                                                            NULL
                                                            )                                                     AS last_4_number,
                                                         GROUP_CONCAT(fe.target)                                  AS event_list,
                                                         COUNT(DISTINCT fe.target)                                AS max_event_day,
                                                         MAX(period_filter)                                       AS period_filter
                                                  FROM email_leads el
                                                  LEFT  JOIN funnel_events fe                   ON (el.id    = fe.email_lead_id)
                                                  LEFT  JOIN emails        e                    ON (el.email = e.email_address)
                                                  INNER JOIN locations     loc                  ON (loc.id   = el.location_id)
                                                  INNER JOIN merchants      m                   ON (m.id     = loc.merchant_id)
                                                  INNER JOIN addresses      a                   ON (a.id     = loc.current_address_id)
                                                  INNER JOIN store_logins  sl                   ON (sl.id    = (
                                                                                                                SELECT MAX(id)
                                                                                                                  FROM store_logins
                                                                                                                 WHERE location_id=loc.id
                                                                                                              )
                                                                                                   )
                                                  LEFT JOIN portal_users pu                     ON (pu.id=loc.principal_id)
                                                  LEFT JOIN merchant_funding_sources mfs        ON (mfs.id = loc.default_merchant_funding_source_id)
                                                  LEFT JOIN locations loc2                      ON (pu.location_id = loc2.id)
                                                  LEFT JOIN  disbursement_mechanisms dm2        ON (loc2.disbursement_mechanism_id = dm2.id)
                                                  CROSS JOIN (SELECT 1 AS period_filter) AS per_fil
                                                  WHERE
                                                     (
                                                       (
                                                            fe.product_line='smartpay'
                                                        AND fe.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
                                                        AND fe.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
                                                        AND fe.target IN ('submit_button_first_page','submit_button_second_page')
                                                       )
                                                    OR
                                                       (
                                                            fe.id IS NULL
                                                        AND el.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
                                                        AND el.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
                                                       )
                                                     )
                                                  AND e.id IS NULL
                                                  AND m.name  = 'Walmart'
                                                  GROUP BY 1,
                                                           2,
                                                           loc.name,
                                                           m.name,
                                                           sl.login_id,
                                                           a.state,
                                                           a.city,
                                                           a.street,
                                                           a.apt_suite_number,
                                                           a.zip,
                                                           loc.id,
                                                           loc.business_phone,
                                                           loc.principal_id,
                                                           14,
                                                           15,
                                                           16,
                                                           17
                                                  ORDER BY 4  DESC
                                              ) AS a LEFT JOIN reporting_dates rd ON (period = rd.`date`)
                                                     LEFT JOIN (
                                                                SELECT
                                                                     el.email,
                                                                     COUNT(DISTINCT fe.target)                                    AS max_from_event_list,
                                                                     COUNT(DISTINCT DATE(COALESCE(fe.created_at,el.created_at)))  AS days_appeared
                                                                FROM email_leads el
                                                                LEFT  JOIN funnel_events fe   ON (el.id    = fe.email_lead_id)
                                                                LEFT  JOIN emails        e    ON (el.email = e.email_address)
                                                                WHERE
                                                                     (
                                                                         (
                                                                               fe.product_line='smartpay'
                                                                          AND  fe.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
                                                                          AND fe.created_at  <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
                                                                          AND fe.target IN ('submit_button_first_page','submit_button_second_page')
                                                                         )
                                                                      OR
                                                                         (
                                                                               fe.id IS NULL
                                                                           AND el.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
                                                                           AND el.created_at <  IFNULL(NULL,DATE_ADD(CURRENT_DATE,INTERVAL 0 DAY))
                                                                          )
                                                                      )
                                                                   AND    e.id IS NULL
                                                                 GROUP BY el.email
                                                                ) AS user_furthest ON (a.email_leads = user_furthest.email)
                                              GROUP BY 1,
                                                       m_name,
                                                       login_id,
                                                       street,
                                                       apt_suite_number,
                                                       us_state,
                                                       city,
                                                       zip,
                                                       loc_name,
                                                       loc_id,
                                                       phone_number,
                                                       principal_id,
                                                       store_type,
                                                       metro_market,
                                                       current_disbursement,
                                                       last_4_number
  ) AS pre_funnel


UNION ALL


SELECT
      period,
      id,
      la_id,
      email_leads,
      prv_name_id,
      prv_res_id,
      ida_count,
      -- IFNULL(auto_decline,0)                                        AS auto_decline,
      IFNULL(approved_count,0)                                      AS approved_count,
      IFNULL(decision_error,0)                                      AS decision_error,
      IFNULL(cart_count,0)                                          AS cart_count,
      IFNULL(entered_card_count,0)                                  AS entered_card_count,
      IFNULL(debitcard_count,0)                                     AS debitcard_count,
      IFNULL(auth_count,0)                                          AS auth_count,
      IFNULL(completed_count,0)                                     AS completed_count,
      IFNULL(shipped_count,0)                                       AS shipped_count,
      IFNULL(avs_count,0)                                           AS avs_count,
      IFNULL(agreed_to_term_count,0)                                AS agreed_to_term_count,
      IFNULL(fraud_check_triggered,0)                               AS fraud_check_triggered,
      IFNULL(fraud_check_passed,0)                                  AS fraud_check_passed,
      IFNULL(return_flag,0)                                         AS returned_count,
      IF(    dm_type='DebitCardDisbursementMechanism'
         AND
             completed_count=1
         AND
             FIND_IN_SET('sent_to_recipient',recorded_states) > 0,
         1,
         0
        )                                                           AS vdc_funded,
      IF(    dm_type='AchDisbursementMechanism'
         AND
             completed_count=1
         AND
             FIND_IN_SET('sent_to_recipient',recorded_states) > 0,
         1,
         0
        )                                                           AS ach_transfer_initiated,
      IF(    dm_type='DebitCardDisbursementMechanism'
         AND
             completed_count=1
         AND
             FIND_IN_SET('bill_paid',recorded_states) > 0,
         1,
         0
        )                                                           AS vdc_charged,
      IF(    dm_type='AchDisbursementMechanism'
         AND
             completed_count=1
         AND
             FIND_IN_SET('bill_paid',recorded_states) > 0,
         1,
         0
        )                                                           AS ach_transfer_completed,
      -- password_still_pending,
      IF(approved_count,credit_line,0)                              AS credit_line,
      IF(completed_count,op_amount,0)                               AS amount,
      IF(completed_count,installment,0)                             AS installment,
      CASE
          WHEN (
                 IFNULL(approved_count,0)=0
               OR
                 (
                  -- IFNULL(approved_count,0)=0
                 -- AND
                   credit_line IS NULL
                 )
              )                           THEN 0
                                          ELSE lo_term
      END                                                             AS cut_off,
      loc_name,
      principal_id,
      m_name,
      login_id,
      us_state,
      city,
      f_name,
      store_type,
      loc_id,
      street,
      apt_suite_number,
      zip,
      business_phone                                                  AS phone_number,
      current_disbursement,
      last_4_number
FROM
(
 SELECT
     rd_dates.date_of_reporting                           AS period,
     1                                                    AS email_leads,
     1                                                    AS prv_name_id,
     1                                                    AS prv_res_id,
     1                                                    AS ida_count,
     (
       (
           DATE(la.created_at) <=> DATE(da.created_at)
       AND
           DATE(la.created_at) <= date_of_reporting
       )
       AND
         IFNULL(da.internal_decline_code,'') IN ('AP1','HS1','HS3','HS4','HS5','HS6','HS7')
     )                                                    AS auto_decline,
      (
       (
           DATE(la.created_at) <=> DATE(fc.created_at)
       AND
           DATE(la.created_at) <= date_of_reporting
       )
     )                                                    AS fraud_check_triggered,
      (
       (
           DATE(la.created_at) <=> DATE(fc.created_at)
       AND
           DATE(la.created_at) <= date_of_reporting
       AND 
           fc.`status`='approved'    
       )
     )                                                    AS fraud_check_passed, 
     (
         DATE(la.created_at) = DATE(op.created_at)
      OR
         (    op.id IS NOT NULL
          AND
              DATE(op.created_at) = date_of_reporting
         )
      OR
         (
              da.approved=1
          AND
             DATE(la.created_at) <= date_of_reporting
          AND
             DATE(da.created_at)  <= date_of_reporting
         )
      OR
         (
            op.id IS NULL
         AND
            DATE(co.updated_at) <= date_of_reporting
         )
      OR
         (
              DATE(ca.created_at) = date_of_reporting
         AND
             (ca.reason IS NULL AND ca.id IS NOT NULL)
         AND
             co.id      IS NULL
         AND
            (    la.funding_source_id IS NOT NULL
             AND
                 la.agreed_to_partial_offer_page=1
            )
         )
      OR
         (
              DATE(ca.created_at) = date_of_reporting
           AND
              (ca.reason IS NULL AND ca.id IS NOT NULL)
           AND
              (    la.funding_source_id IS NULL
               AND
                   la.agreed_to_partial_offer_page=0
              )
          )
      OR
         (
              DATE(c.created_at) = date_of_reporting
          AND
              c.total_purchase_amount > 0
          AND
              ca.id IS NULL
          )
      )                                                   AS approved_count,
      (
        DATE(la.created_at) = date_of_reporting
      AND
        DATE(da.created_at) = date_of_reporting
      AND
        (
          da.id IS NULL
        OR
          da.approved=0
        OR
          da.approved IS NULL
        )
      )                                                   AS decision_error,
       (
        DATE(la.created_at) = date_of_reporting
      )                                                   AS avs_count,
      (
         (
          DATE(la.created_at) = DATE(op.created_at)
         )
      OR
         (    op.id IS NOT NULL
          AND
              DATE(op.created_at) = date_of_reporting
         )
      OR
        (
              da.approved=1
          AND
             DATE(la.created_at)  = date_of_reporting
          AND
            (
              (
                   m.`name`='RadioShack'
               AND
                  (
                      DATE(co.updated_at) >= DATE(c.created_at)
                  OR
                      DATE(ca.updated_at) >= DATE(c.created_at)
                  )
               )
            OR
              (
                   m.`name` <> 'RadioShack'
               AND
                  (
                   DATE(c.created_at)   =  DATE(ca.updated_at)
                  )
              )
            )
          AND
             (    c.id IS NOT NULL
               OR
                  c.total_purchase_amount >0
            )
        )
      OR
         (DATE(co.updated_at)  <= date_of_reporting)
      )                                                  AS cart_count,
      (
          DATE(la.created_at) = DATE(op.created_at)
      OR
         (
              DATE(ca.created_at) = date_of_reporting
          AND
             (ca.reason IS NULL AND ca.id IS NOT NULL)
          AND
             co.id      IS NULL
          AND
            (    la.funding_source_id IS NOT NULL
             AND
                 la.agreed_to_partial_offer_page=1
            )
         )
      OR
        (
              DATE(ca.created_at) <= date_of_reporting
           AND
              (ca.reason IS NULL AND ca.id IS NOT NULL)
           AND
              (    la.funding_source_id IS NULL
               AND
                   la.agreed_to_partial_offer_page=0
              )
        )
      OR
         (
          la.is_web_checkout=0
        AND
          (
            DATE(la.created_at) = DATE(op.created_at)
           OR
           (    op.id IS NOT NULL
            AND
               DATE(op.created_at) = date_of_reporting
           )
          )
        )
      OR
        (
          la.is_web_checkout=1
        AND
          (
             DATE(la.created_at) = DATE(co.updated_at)
           OR
            (
             DATE(co.created_at) <= date_of_reporting
            )
          )
        )
      )                                                  AS entered_card_count,
      (
         DATE(la.created_at) = DATE(op.created_at)
      OR
         (
              DATE(ca.created_at) = date_of_reporting
          AND
             (ca.reason IS NULL AND ca.id IS NOT NULL)
          AND
             co.id      IS NULL
          AND
            (    la.funding_source_id IS NOT NULL
             AND
                 la.agreed_to_partial_offer_page=1
            )
         )
      OR
       (
          la.is_web_checkout=0
        AND
          (
            DATE(la.created_at) = DATE(op.created_at)
           OR
           (    op.id IS NOT NULL
            AND
               DATE(op.created_at) = date_of_reporting
           )
          )
        )
      OR
        (
          la.is_web_checkout=1
        AND
          (
             DATE(la.created_at) = DATE(co.updated_at)
           OR
            (
             DATE(co.created_at) = date_of_reporting
            )
          )
        )
      )                                                 AS debitcard_count,
      (
        (
          la.is_web_checkout=0
        AND
          (
            DATE(la.created_at) = DATE(op.created_at)
           OR
           (    op.id IS NOT NULL
            AND
               DATE(op.created_at) = date_of_reporting
           )
          )
        )
      OR
        (
          la.is_web_checkout=1
        AND
          (
             DATE(la.created_at) = DATE(co.updated_at)
           OR
            (
             DATE(co.created_at) = date_of_reporting
            )
          )
        )
      OR
         (
          (DATE(co.updated_at)   <= date_of_reporting)
         )
      )                                                   AS auth_count,
      (
        (
          la.is_web_checkout=0
        AND
          (
            DATE(la.created_at) = DATE(op.created_at)
           OR
           (    op.id IS NOT NULL
            AND
               DATE(op.created_at) = date_of_reporting
           )
          )
        )
      OR
        (
          la.is_web_checkout=1
        AND
          (
             DATE(la.created_at) = DATE(co.updated_at)
           OR
            (
             DATE(co.created_at) = date_of_reporting
            )
          )
        )
      )                                                   AS completed_count,
      (
          la.is_web_checkout=1
        AND
          (
            (
                  DATE(la.created_at) = DATE(co.updated_at)
              AND
                 op.id IS NOT NULL
            )
          OR
            (
                op.id IS NOT NULL
            AND
                DATE(co.updated_at) = date_of_reporting
            )
          )
      )                                                  AS shipped_count,
      (
        ( 
              DATE(date_of_reporting) <=> DATE(la.created_at)
          AND 
              la.cancel_reason_code='void_with_auth_reversal'
         )
      OR 
         (
            DATE(date_of_reporting) <=> DATE(r.created_at) 
          )        
      )                                                  AS return_flag,
      (  
                 la.funding_source_id IS NOT NULL
             AND
                 la.agreed_to_partial_offer_page=1
      )                                                  AS agreed_to_term_count,
      (
       SELECT GROUP_CONCAT(recorded_state)
       FROM histories
       WHERE outgoing_payment_id=op.id
       )                                                 AS recorded_states,
      dm.type                                            AS dm_type,
      u.password_still_pending,
      loc.`name`                                         AS loc_name,
      loc.id                                             AS loc_id,
      loc.principal_id,
      loc.business_phone,
      m.name                                             AS m_name,
      sl.login_id,
      a.state                                            AS us_state,
      a.city,
      a.zip,
      a.street,
      a.apt_suite_number,
      f.`name`                                           AS f_name,
      pu.belongs_to_merchant,
      lao.term                                           AS lo_term,
      IF(pu.belongs_to_merchant = 1,
         'corporate',
         'independent'
         )                                               AS store_type,
      IF(da.id=dal.id,da.credit_line,NULL)               AS credit_line,
      CASE
          WHEN pfo.type ='MonthlyPaymentOption'   THEN pr.installment_count
          WHEN pfo.type ='BimonthlyPaymentOption' THEN CAST(CEIL(pr.installment_count/2) AS SIGNED)
                                                  ELSE pr.installment_count
      END                                                AS installment,
      IF(da.id=dal.id,DATE(da.created_at),NULL)          AS da_created_at_max,
      COALESCE(op.amount,c.total_purchase_amount)        AS op_amount,
      CASE WHEN dm2.type = 'DebitCardDisbursementMechanism' THEN 'VDC'
           WHEN dm2.type = 'AchDisbursementMechanism'       THEN 'ACH'
      END                                                AS current_disbursement,
      IF(dm2.type = 'AchDisbursementMechanism',
         mfs.last_numbers,
         NULL
         )                                               AS last_4_number,
      la.id                                              AS la_id,
      u.id,
      DATE(la.created_at)                                AS la_create_dt,
      DATE(da.created_at)                                AS da_create_dt,
      DATE(c.created_at)                                 AS c_create_dt,
      DATE(co.created_at)                                AS co_create_dt,
      DATE(ca.created_at)                                AS ca_create_dt,
      DATE(ca.updated_at)                                AS ca_update_at,
      DATE(op.created_at)                                AS op_create_dt,
      DATE(co.updated_at)                                AS co_updated_dt
FROM loan_applications la
INNER JOIN orders o                      ON (o.id  = la.order_id)
INNER JOIN users             u           ON (u.id  = o.user_id)
INNER JOIN emails e                      ON (u.id  = e.user_id)
INNER JOIN email_leads el                ON (el.email = e.email_address)
LEFT  JOIN available_items   ai          ON (ai.id = o.available_item_id)
LEFT  JOIN locations         loc         ON (loc.id = ai.location_id)
INNER JOIN merchants         m           ON (m.id   = loc.merchant_id)
LEFT  JOIN payment_frequency_options pfo ON (     pfo.loan_application_id = la.id
                                             AND  pfo.id = la.current_payment_frequency_option_id
                                             )
LEFT  JOIN funders           f           ON (f.id  = la.funder_id)
LEFT  JOIN addresses         a           ON (a.id  = loc.current_address_id)
LEFT  JOIN outgoing_payments op          ON (la.id = op.loan_application_id)
LEFT  JOIN carts  c                      ON (la.id = c.loan_application_id)
LEFT  JOIN collaterals       co          ON (la.id = co.loan_application_id AND co.status='auth_success' AND co.type='CashDeposit')
LEFT  JOIN decision_attempts da          ON (la.id = da.loan_application_id)
LEFT  JOIN card_artifacts    ca          ON (ca.id = (
                                                      SELECT MAX(id)
                                                        FROM card_artifacts
                                                       WHERE user_id=o.user_id
                                                     )
                                            )
LEFT JOIN disbursement_mechanisms dm     ON (dm.id = op.disbursement_mechanism_id)
LEFT JOIN portal_users            pu     ON (pu.id = loc.principal_id)
LEFT JOIN store_logins            sl     ON (sl.id = (
                                                       SELECT MAX(id)
                                                         FROM store_logins
                                                        WHERE location_id = loc.id
                                                     )
                                            )
LEFT JOIN loan_application_offers lao    ON (lao.id = (
                                                        SELECT MAX(id)
                                                         FROM loan_application_offers
                                                        WHERE loan_application_id = la.id
                                                      )
                                            )
LEFT JOIN merchant_funding_sources mfs   ON (mfs.id = loc.default_merchant_funding_source_id)
LEFT JOIN decision_attempts       dal    ON (dal.id = (
                                                        SELECT MAX(id)
                                                          FROM decision_attempts
                                                         WHERE loan_application_id = la.id
                                                           AND approved=1
                                                      )
                                            )
LEFT JOIN fraud_checks            fc    ON (fc.id = (
                                                        SELECT MAX(id)
                                                          FROM fraud_checks
                                                         WHERE loan_application_id = la.id
                                                           AND `type`='KbaDecisioningFraudCheck'
                                                      )
                                            )
LEFT  JOIN pricing_histories pr          ON (pr.id= (
                                                      SELECT MAX(id)
                                                        FROM pricing_histories
                                                       WHERE loan_application_id = la.id
                                                    )
                                            )
LEFT JOIN  returns      r               ON (   op.id   = r.outgoing_payment_id
                                            AND
                                                r.`type` <> 'Adjustment'
                                            AND
                                                (  r.returned_to IS NULL
                                                 OR
                                                  r.returned_to='in_store'
                                                ) 
                                           )
LEFT  JOIN return_payments         rp   ON (    r.id = rp.return_id
                                            AND
                                                rp.type <> 'ConsumerReturnPayment'
                                           )     
LEFT JOIN  locations    loc2            ON (loc2.id = pu.location_id)
LEFT JOIN  disbursement_mechanisms dm2  ON (dm2.id  = loc2.disbursement_mechanism_id)
CROSS JOIN ( SELECT `date` AS date_of_reporting
               FROM reporting_dates
              WHERE `date` BETWEEN IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 30 DAY))
                AND                IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 1 DAY))
           ) rd_dates
WHERE la.type IS NULL
  AND m.`name`='Walmart'
  AND sl.login_id IS NOT NULL
  AND
    (
        (
              DATE(la.created_at) = DATE(op.created_at)
         AND
             rd_dates.date_of_reporting = DATE(la.created_at)
        )
    OR
       (
          (
              DATE(la.created_at) <> DATE(op.created_at)
           AND
             (
               rd_dates.date_of_reporting = DATE(op.created_at)
              )
          )
        OR
          (
              DATE(la.created_at) <> DATE(da.created_at)
           AND
             (
               rd_dates.date_of_reporting = DATE(da.created_at)
              )
           AND
              (
                 (
                     op.id IS NOT NULL
                AND
                     DATE(op.created_at) >= DATE(da.created_at)
                 )
               OR
                 (
                  IF(op.id IS NULL,1,0)
                 )
              )
          )
        OR
          (
              DATE(la.created_at) <> DATE(ca.created_at)
           AND
             (
               rd_dates.date_of_reporting = DATE(ca.created_at)
              )
           AND DATE(la.created_at) >= DATE(ca.created_at)
          )
        OR
          (
              DATE(la.created_at) <> DATE(co.created_at)
           AND
             (
               rd_dates.date_of_reporting = DATE(co.created_at)
              )
          )
        OR
          (
              DATE(la.created_at) <> DATE(co.updated_at)
           AND
             (
               rd_dates.date_of_reporting = DATE(co.updated_at)
              )
          )
        OR
          (
             (
               rd_dates.date_of_reporting = DATE(la.created_at)
             )
          )
        OR
          (
             (
               rd_dates.date_of_reporting = DATE(fc.created_at)
             )
          ) 
        OR
          (
             (
               rd_dates.date_of_reporting = DATE(r.created_at)
             )
          )   

        )
    )
) AS a
) AS b
GROUP BY
       period,
       m_name