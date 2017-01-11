SELECT
            transaction_date,
            SUM(IF(processed_pending_flag=1,transaction_amount,0))            AS total_processed_amount,
            COUNT(DISTINCT IF(processed_pending_flag=1,transaction_id,NULL))  AS total_processed,
            SUM(IF(processed_pending_flag=2,transaction_amount,0))            AS total_pending_amount,
            COUNT(DISTINCT IF(processed_pending_flag=2,transaction_id,NULL))  AS total_pending
      FROM
      (
      SELECT
            CASE WHEN dm.type = 'DebitCardDisbursementMechanism' THEN 'VDC'
                 WHEN dm.type = 'AchDisbursementMechanism'       THEN 'ACH'
            END                                                             AS disbursement_method,
            CASE
                WHEN dm.`type`='DebitCardDisbursementMechanism' THEN
                                                                    CASE
                                                                          WHEN   op.`state` IN ('new','on_hold_for_fraud')  THEN 2 -- for pending
                                                                          WHEN
                                                                              (  op.`state` IN ('bill_paid','sent_to_recipient')
                                                                               AND
                                                                                 r_in.id IS NULL  -- only the instore returns with billpaid state
                                                                              )
                                                                             OR
                                                                               (
                                                                                   (r_sp.id IS NOT NULL) -- smartpay returns are considered processed regardless
                                                                                OR
                                                                                   (
                                                                                      r_in.id IS NOT NULL
                                                                                   AND
                                                                                     op.`state` IN (
                                                                                                    'partial_return_in_progress',
                                                                                                    'return_in_progress',
                                                                                                    'partially_returned'
                                                                                                   )
                                                                                    )
                                                                               )                                          THEN 1    -- 1 for processed
                                                                                                                          ELSE NULL -- defaults to NULL
                                                                    END
                WHEN dm.type = 'AchDisbursementMechanism'       THEN
                                                                    CASE
                                                                        WHEN
                                                                              (
                                                                                op.`state` IN (
                                                                                              'new',
                                                                                              'on_hold_for_fraud'
                                                                                              'transmitter_returned',
                                                                                              'transmission_error'
                                                                                              )
                                                                              )
                                                                           OR
                                                                               ( op.id IS NULL AND co.id IS NOT NULL AND ch.`type` = 'OnlineChannel')        THEN 2 -- for pending
                                                                        WHEN
                                                                             (
                                                                                 op.`state` IN ('bill_paid','sent_to_recipient')
                                                                              AND
                                                                                (
                                                                                     COALESCE(r_in.id,r_sp.id) IS NULL  -- make sure both in-store and smartpay returns are not present
                                                                                 OR
                                                                                     COALESCE(r_in.`type`,r_sp.`type`)='PartialReturn' -- checking both in-store and smartpay patrial returns along with the bill paid op state
                                                                                )
                                                                              )
                                                                                               THEN 1 -- for processed
                                                                        ELSE NULL -- defaults to NULL
                                                                    END
                                                                  ELSE NULL -- It should never go here
            END                                                              AS processed_pending_flag,
            op.id                                                            AS transaction_id,
            op.`amount`                                                      AS transaction_amount,
            loc.id                                                           AS store_id,
            DATE(op.created_at)                                              AS transaction_date,
            op.state
      FROM loan_applications la
      INNER JOIN orders          o               ON (o.id   = la.order_id)
      INNER JOIN users           u               ON (u.id   = o.user_id)
      INNER JOIN available_items ai              ON (ai.id  = o.available_item_id)
      INNER JOIN locations       loc             ON (loc.id = ai.location_id)
      INNER JOIN merchants       m               ON (m.id   = loc.merchant_id)
      INNER JOIN channels                 ch     ON (ch.id  = m.channel_id)
      INNER JOIN outgoing_payments op            ON (la.id  = op.loan_application_id)
      INNER JOIN disbursement_mechanisms  dm     ON (dm.id  = op.disbursement_mechanism_id)
      INNER JOIN portal_users             pu     ON (pu.id  = loc.principal_id)
      INNER JOIN dashboard_users           du    ON (pu.id  = du.portal_user_id)
      INNER JOIN dashboard_users_locations dul   ON (du.id = dul.dashboard_user_id AND dul.location_id = loc.id)
      LEFT  JOIN smartpay_settlements     ss     ON (ss.id  = op.smartpay_settlement_id)
      LEFT  JOIN collaterals       co            ON (   la.id  = co.loan_application_id
                                                     AND
                                                        co.`type`='CashDeposit'
                                                     AND
                                                        co.`status`='auth_success'
                                                    )
      LEFT  JOIN returns           r_in          ON (   op.id  = r_in.outgoing_payment_id
                                                     AND /* filtering out only the smartpay return */
                                                         r_in.`type` <> 'Adjustment'
                                                     AND
                                                          (  r_in.returned_to IS NULL
                                                           OR
                                                             r_in.returned_to='in_store'
                                                           )
                                                    )
      LEFT  JOIN returns           r_sp          ON (    op.id  = r_sp.outgoing_payment_id
                                                     AND
                                                         r_sp.returned_to='smartpay'
                                                    )
      WHERE la.`type` IS NULL
        AND du.id = #{ self.id }
        AND op.created_at >= IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 7 DAY))
        AND op.created_at <  IFNULL(NULL,DATE_SUB(CURRENT_DATE,INTERVAL 0 DAY))
      ) AS a
      GROUP BY 1;