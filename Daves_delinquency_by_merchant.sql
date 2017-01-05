SELECT
       merchant,
       loan_id,
       origination_year,
       origination_month,
       installment_number,
       cnt_loan,
       amount_due,
       ROUND((day_15_rate)*100,2)  AS day_15_delinquency_rate
FROM
(
SELECT
       origination_year,
       origination_month,
       installment_number,
       merchant,
       loan_id, 
       COUNT(DISTINCT loan_id)                 AS cnt_loan,
       SUM(installment_original_amount)        AS amount_due,
        ((1-(SUM(
         CASE
           WHEN loan_state='completed'                                                                   THEN installment_original_amount
           WHEN LEAST(amount_due_to_date,total_paid) <= (amount_due_to_date-installment_original_amount) THEN 0
           -- WHEN    (amount_due_to_date=total_paid)                                                       THEN NULL
           WHEN LEAST(amount_due_to_date,total_paid) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                         ELSE LEAST(amount_due_to_date,total_paid) - amount_due_to_date + installment_original_amount
         END
         ) / SUM(installment_original_amount))))     AS current_delinquency_rate_marginal,
       ((1-(SUM(
                    CASE
                        WHEN (LEAST(amount_due_to_date,IF(loan_state='completed',amount_due_to_date,total_paid)) - up_front_original_amount <0) THEN 0
                        ELSE  LEAST(amount_due_to_date,IF(loan_state='completed',amount_due_to_date,total_paid)) - up_front_original_amount
                   END
          )) / SUM(commulative_due_minus_upfront)))  AS current_delinquency_rate_cumulative,
       ((1-(SUM(
                                   CASE
                                       WHEN loan_state='completed'  AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)             THEN installment_original_amount
                                       WHEN LEAST(amount_due_to_date,total_paid_day_0) < (amount_due_to_date-installment_original_amount)  THEN 0
                                       WHEN LEAST(amount_due_to_date,total_paid_day_0) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                           ELSE LEAST(amount_due_to_date,total_paid_day_0) - amount_due_to_date + installment_original_amount
                                   END
                                   ) / SUM(installment_original_amount))))
                                                  AS day_0_rate,
        ((1-(SUM(
                                            CASE
                                                WHEN loan_state='completed'  AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)             THEN installment_original_amount
                                                WHEN LEAST(amount_due_to_date,total_paid_day_1) <  (amount_due_to_date-installment_original_amount) THEN 0
                                                WHEN LEAST(amount_due_to_date,total_paid_day_1) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                    ELSE LEAST(amount_due_to_date,total_paid_day_1) - amount_due_to_date + installment_original_amount
                                            END
                                    ) / SUM(installment_original_amount))))
                                                 AS day_1_rate,
      ((1-(SUM(
                                            CASE
                                                 WHEN loan_state='completed' AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)              THEN installment_original_amount
                                                 WHEN LEAST(amount_due_to_date,total_paid_day_7) <  (amount_due_to_date-installment_original_amount) THEN 0
                                                 WHEN LEAST(amount_due_to_date,total_paid_day_7) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                     ELSE LEAST(amount_due_to_date,total_paid_day_7) - amount_due_to_date + installment_original_amount
                                            END
                                    ) / SUM(installment_original_amount))))
                                                 AS day_7_rate,
        ((1-(SUM(
                                            CASE
                                                 WHEN loan_state='completed' AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)               THEN installment_original_amount
                                                 WHEN LEAST(amount_due_to_date,total_paid_day_15) <  (amount_due_to_date-installment_original_amount) THEN 0
                                                 WHEN LEAST(amount_due_to_date,total_paid_day_15) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                      ELSE LEAST(amount_due_to_date,total_paid_day_15) - amount_due_to_date + installment_original_amount
                                            END
                                   ) / SUM(installment_original_amount))))
                                                AS day_15_rate,
         ((1-(SUM(
                                           CASE
                                               WHEN loan_state='completed' AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)               THEN installment_original_amount
                                               WHEN LEAST(amount_due_to_date,total_paid_day_30) <  (amount_due_to_date-installment_original_amount) THEN 0
                                               WHEN LEAST(amount_due_to_date,total_paid_day_30) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                    ELSE LEAST(amount_due_to_date,total_paid_day_30) - amount_due_to_date + installment_original_amount
                                           END
                                   ) / SUM(installment_original_amount))))
                                                AS day_30_rate,
       ((1-(SUM(
                                           CASE
                                                WHEN loan_state='completed' AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)               THEN installment_original_amount
                                                WHEN LEAST(amount_due_to_date,total_paid_day_60) <  (amount_due_to_date-installment_original_amount) THEN 0
                                                WHEN LEAST(amount_due_to_date,total_paid_day_60) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                     ELSE LEAST(amount_due_to_date,total_paid_day_60) - amount_due_to_date + installment_original_amount
                                           END
                                  ) / SUM(installment_original_amount))))
                                                AS day_60_rate,
        ((1-(SUM(
                                           CASE
                                                WHEN loan_state='completed' AND DATE(actual_repayment_date) <= DATE(actual_repayment_date_i)               THEN installment_original_amount
                                                WHEN LEAST(amount_due_to_date,total_paid_day_90) <  (amount_due_to_date-installment_original_amount) THEN 0
                                                WHEN LEAST(amount_due_to_date,total_paid_day_90) >  amount_due_to_date                               THEN installment_original_amount
                                                                                                                                                     ELSE LEAST(amount_due_to_date,total_paid_day_90) - amount_due_to_date + installment_original_amount
                                           END
                                  ) / SUM(installment_original_amount))))
                                                 AS day_90_rate
                                               
FROM
(
SELECT
       loan_id,
       DATE_FORMAT(application_dt,'%Y')        AS origination_year,
       DATE_FORMAT(application_dt,'%m')        AS origination_month,
       -- IF(lao_id IS NOT NULL,rank,(rank - 1))  AS installment_number,
       CASE
           WHEN lease_frequency_type='MonthlyPaymentOption'    THEN IF(lao_id IS NOT NULL,rank,(rank - 1))
           WHEN lease_frequency_type='BimonthlyPaymentOption'  THEN
                                                               CASE
                                                                    WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) <=8   THEN
                                                                                                                            CASE
                                                                                                                                 WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (1,2) THEN 1
                                                                                                                                 WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (3,4) THEN 2
                                                                                                                                 WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (5,6) THEN 3
                                                                                                                                 WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (7,8) THEN 4
                                                                                                                            END
                                                                    WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 8   THEN
                                                                                                                            CASE
                                                                                                                                  WHEN product_terms='6 months'   THEN 5
                                                                                                                                  WHEN product_terms='8 months'   THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 12       THEN 7
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END
                                                                                                                                  WHEN product_terms='9 months'   THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (13,14) THEN 7
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 14       THEN 8
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END

                                                                                                                                  WHEN product_terms='10 months'  THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (13,14) THEN 7
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (15,16) THEN 8
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 16       THEN 9
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END
                                                                                                                                  WHEN product_terms='12 months'  THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (13,14) THEN 7
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (15,16) THEN 8
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (17,18) THEN 9
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (19,20) THEN 10
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 20       THEN 11
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END
                                                                                                                                  WHEN product_terms='18 months'  THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (13,14) THEN 7
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (15,16) THEN 8
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (17,18) THEN 9
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (19,20) THEN 10
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (21,22) THEN 11
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (23,24) THEN 12
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (25,26) THEN 13
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (27,28) THEN 14
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (29,30) THEN 15
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (31,32) THEN 16
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 32       THEN 17
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END
                                                                                                                                  WHEN product_terms='24 months'  THEN
                                                                                                                                                                          CASE
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (9,10)  THEN 5
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (11,12) THEN 6
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (13,14) THEN 7
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (15,16) THEN 8
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (17,18) THEN 9
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (19,20) THEN 10
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (21,22) THEN 11
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (23,24) THEN 12
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (25,26) THEN 13
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (27,28) THEN 14
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (29,30) THEN 15
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (31,32) THEN 16
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (33,34) THEN 17
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (35,36) THEN 18
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (37,38) THEN 19
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (39,40) THEN 20
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (41,42) THEN 21
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) IN (43,44) THEN 22
                                                                                                                                                                               WHEN IF(lao_id IS NOT NULL,rank,(rank - 1)) > 44       THEN 23
                                                                                                                                                                               -- ELSE IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                                                                                                                                          END
                                                                                                                            END
                                                                                                                      ELSE  IF(lao_id IS NOT NULL,rank,(rank - 1))
                                                            END
                                                      ELSE  NULL -- it shoud never get here
       END                                     AS installment_number,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(commulative_due_minus_upfront)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(commulative_due_minus_upfront)
       END                                     AS commulative_due_minus_upfront,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(amount_due_to_date)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(amount_due_to_date)
       END                                     AS amount_due_to_date,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid)
       END                                     AS total_paid,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_0)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_0)
       END                                     AS total_paid_day_0,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_1)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_1)
       END                                     AS total_paid_day_1,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_7)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_7)
       END                                     AS total_paid_day_7,
       CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_15)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_15)
       END                                     AS total_paid_day_15,
        CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_30)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_30)
       END                                     AS total_paid_day_30,
        CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_60)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_60)
       END                                     AS total_paid_day_60,
        CASE
            WHEN lease_frequency_type='MonthlyPaymentOption'   THEN SUM(total_paid_day_90)
            WHEN lease_frequency_type='BimonthlyPaymentOption' THEN MAX(total_paid_day_90)
       END                                     AS total_paid_day_90,
       SUM(installment_original_amount)        AS installment_original_amount,
       MAX(up_front_original_amount)           AS up_front_original_amount,
       MAX(loan_state)                         AS loan_state,
       SUM(installment_original_amount)        AS amount_due,
       MAX(DATE(actual_repayment_date))        AS actual_repayment_date,
       MAX(DATE(actual_repayment_date_i))      AS actual_repayment_date_i,
       MAX(merchant)                           AS merchant
FROM
(
SELECT
       rank,
       loan_id,
       application_dt,
       up_front_install_id,
       IF(lao_id IS NOT NULL,0,up_front_original_amount)                 AS up_front_original_amount,
       up_front_install_state,
       amount_due_to_date,
       IF(lao_id IS NOT NULL,
          amount_due_to_date,
         (amount_due_to_date - up_front_original_amount)
         )                                                               AS commulative_due_minus_upfront,
       installment_original_amount,
       installment_state,
       installment_due_date,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= installment_due_date
             AND state='completed'),0)                                    AS total_paid_day_0,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 1 DAY)
             AND state='completed'),0)                                    AS total_paid_day_1,
        COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 7 DAY)
             AND state='completed'),0)                                    AS total_paid_day_7,
        COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 15 DAY)
             AND state='completed'),0)                                    AS total_paid_day_15,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 30 DAY)
             AND state='completed'),0)                                    AS total_paid_day_30,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 60 DAY)
             AND state='completed'),0)                                    AS total_paid_day_60,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND settled_on <= DATE_ADD(installment_due_date,INTERVAL 90 DAY)
             AND state='completed'),0)                                    AS total_paid_day_90,
       COALESCE(
        (SELECT SUM(amount)
           FROM  loan_payments
           WHERE loan_id=c.loan_id
             AND state='completed'),0)                                    AS total_paid,
       installment_id,
       flag_first_install_id,
       installment_count,
       loan_state,
       lao_id,
       product_terms,
       lease_frequency_type,
       la_type,
       actual_repayment_date,
       actual_repayment_date_i,
       merchant
FROM
(
SELECT
       @curr_loan_id:=loan_id,
       loan_id,
       application_dt,
       up_front_install_id,
       up_front_original_amount,
       up_front_install_state,
       IF(@curr_loan_id=@prev_loan_id,
          @rnk:=@rnk + 1,
          @rnk:=1
        )                                                                 AS rank,
       IF(@curr_loan_id=@prev_loan_id,
          @sum_loan_amount:=installment_original_amount + @sum_loan_amount,
          @sum_loan_amount:=installment_original_amount
        )                                                                 AS amount_due_to_date,
       @prev_loan_id:=@curr_loan_id,
       installment_original_amount                                        AS installment_original_amount,
       installment_due_date,
       installment_id,
       installment_state,
       loan_state,
       IF(installment_id=up_front_install_id AND lao_id IS NULL,NULL,installment_id)         AS flag_first_install_id,
       installment_count,
       lao_id,
       product_terms,
       lease_frequency_type,
       la_type,
       actual_repayment_date,
       actual_repayment_date_i,
       merchant
FROM
(
SELECT
      CASE
           WHEN
                 la.is_web_checkout=1
              AND
                 co.type='CashDeposit'
              AND
                 co.status='auth_success'   THEN DATE(co.updated_at)
           WHEN
                    la.is_web_checkout=0
                AND
                    op.id IS NOT NULL       THEN DATE(op.created_at)
      END                      AS application_dt,
      min_i.id                 AS up_front_install_id,
      min_i.original_amount    AS up_front_original_amount,
      min_i.state              AS up_front_install_state,
      i.id                     AS installment_id,
      i.original_amount        AS installment_original_amount,
      i.original_due_date      AS installment_due_date,
      i.state                  AS installment_state,
      l.id                     AS loan_id,
      l.state                  AS loan_state,
      co.id,
      security_deposit_amount,
      ph.installment_count,
      lao.id                   AS lao_id,
      l.actual_repayment_date,
      i.actual_repayment_date  AS actual_repayment_date_i,
      CASE
                     WHEN
                              pfo.type='MonthlyPaymentOption' THEN
                                                                                                   CASE
                                                                                                       WHEN  ph.installment_count <=6                THEN '6 months'
                                                                                                       WHEN  (ph.installment_count BETWEEN 7 AND 8)  THEN '8 months'
                                                                                                       WHEN  ph.installment_count =9                 THEN '9 months'
                                                                                                       WHEN  ph.installment_count =10                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =12                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '24 months'
                                                                                                   END
                     WHEN
                                                                pfo.type='BimonthlyPaymentOption' THEN
                                                                                                    CASE
                                                                                                       WHEN  ph.installment_count =12                THEN '6 months'
                                                                                                       WHEN  ph.installment_count =16                THEN '8 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '9 months'
                                                                                                       WHEN  ph.installment_count =20                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =36                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =48                THEN '24 months'
                                                                                                   END
                                                                                                   ELSE ph.installment_count
    END                 AS product_terms,
    la.`type`           AS la_type,
    pfo.type            AS lease_frequency_type,
    m.`name`            AS merchant
FROM loan_applications la
INNER JOIN payment_frequency_options pfo   ON (pfo.id = la.current_payment_frequency_option_id)
INNER JOIN collaterals               co    ON (la.id  = co.loan_application_id)
INNER JOIN outgoing_payments         op    ON (la.id  = op.loan_application_id)
INNER JOIN loans                     l     ON (op.id  = l.outgoing_payment_id AND l.state !='void')
INNER JOIN orders o                        ON (o.id   = la.order_id)
INNER JOIN available_items           ai    ON (o.available_item_id = ai.id)
INNER JOIN locations                 loc   ON (loc.id              = ai.location_id)
INNER JOIN merchants                 m     ON (m.id                = loc.merchant_id)
LEFT  JOIN installments              min_i ON (min_i.id = (SELECT MIN(id)
                                                         FROM installments
                                                         WHERE loan_id = l.id
                                                         )
                                              )
INNER JOIN installments               i    ON (l.id         = i.loan_id)
INNER JOIN funders                    f    ON (la.funder_id = f.id)
LEFT  JOIN pricing_histories          ph   ON (ph.id=(SELECT MAX(id)
                                                      FROM  pricing_histories
                                                      WHERE loan_application_id=la.id
                                                      )
                                              )
LEFT  JOIN loan_application_offers    lao  ON (   la.id = lao.loan_application_id
                                               AND
                                                  lao.equal_installments=0
                                               AND
                                                  upfront_installment_percent=0.0
                                              )
WHERE
    i.original_due_date <= CURRENT_DATE
AND la.type IS NULL
AND ('All'         =  'All' OR f.name   = 'All')
AND (' All' =  ' All'       OR pfo.type = ' All')
AND (' All'       =  ' All' OR m.name   = ' All')
AND ('All'       =   'All' OR 'All' = CASE
                                                      WHEN lao.id IS NOT NULL THEN 'Yes'
                                                      WHEN lao.id IS NULL     THEN 'No'
                                                                              ELSE 'All'
                                                  END
    )
AND ('12 months'    =  0      OR '12 months' = CASE
                                                          WHEN
                                                               pfo.type='MonthlyPaymentOption' THEN
                                                                                                   CASE
                                                                                                       WHEN  ph.installment_count <=6                THEN '6 months'
                                                                                                       WHEN  (ph.installment_count BETWEEN 7 AND 8)  THEN '8 months'
                                                                                                       WHEN  ph.installment_count =9                 THEN '9 months'
                                                                                                       WHEN  ph.installment_count =10                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =12                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '24 months'
                                                                                                   END
                                                           WHEN
                                                                pfo.type='BimonthlyPaymentOption' THEN
                                                                                                    CASE
                                                                                                       WHEN  ph.installment_count =12                THEN '6 months'
                                                                                                       WHEN  ph.installment_count =16                THEN '8 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '9 months'
                                                                                                       WHEN  ph.installment_count =20                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =36                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =48                THEN '24 months'
                                                                                                   END
                                                                                                   ELSE ph.installment_count
                                                        END
      )
AND
    (
      (
            la.is_web_checkout=1
        AND
            co.type='CashDeposit'
        AND
            co.status='auth_success'
        AND
            co.updated_at >=  IFNULL('2015-10-01',IF(DAY(CURRENT_DATE)=1,
                                                       DATE_SUB(CURRENT_DATE,INTERVAL 12 MONTH),
                                                       DATE_SUB(DATE_SUB(CURRENT_DATE,INTERVAL (DAY(CURRENT_DATE)-1) DAY),INTERVAL 12 MONTH)
                                                      )
                                     )
                                      AND co.updated_at < IFNULL(DATE_ADD(DATE('2015-10-31'),INTERVAL 1 DAY),DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
        )
     OR
        (
           la.is_web_checkout=0
         AND
            op.created_at >= IFNULL('2015-10-01',IF(DAY(CURRENT_DATE)=1,
                                                       DATE_SUB(CURRENT_DATE,INTERVAL 12 MONTH),
                                                       DATE_SUB(DATE_SUB(CURRENT_DATE,INTERVAL (DAY(CURRENT_DATE)-1) DAY),INTERVAL 12 MONTH)
                                                      )
                                     )  AND op.created_at < IFNULL(DATE_ADD(DATE('2015-10-31'),INTERVAL 1 DAY),DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
         AND

            co.type='CashDeposit'
         AND
            co.status='auth_success'
        )
     )
ORDER BY loan_id,
         i.id  ASC
) AS a CROSS JOIN ( SELECT @curr_loan_id:=NULL,
                           @prev_loan_id:=NULL,
                           @sum_loan_amount:=0,
                           @rnk:=0
                  ) AS b
) AS c
) AS main
WHERE flag_first_install_id IS NOT NULL
-- AND
  /*
   (
     (
       la_type='MobileApplication'
     AND
       product_terms NOT IN ('18 months','24 months')
     )
   OR
     (
         la_type IS NULL
      AND
         1=1
     )
   )
*/
GROUP BY  1,
          2,
          3,
          4
) AS main_11
GROUP BY
       origination_year,
       origination_month,
       installment_number,
       merchant,
       loan_id
) AS main_1
LEFT JOIN           (
                                          SELECT
                                                DATE_FORMAT(application_dt,'%Y') AS dt_year,
                                                DATE_FORMAT(application_dt,'%m') AS dt_month,
                                                COUNT(DISTINCT id)               AS total_cnt_loans,
                                                payment_frequency_option
                                            FROM
                                               (
                                                  SELECT
                                                         CASE
                                                              WHEN
                                                                   la.is_web_checkout=1
                                                                AND
                                                                   co.type='CashDeposit'
                                                                AND
                                                                   co.status='auth_success'   THEN DATE(co.updated_at)
                                                             WHEN
                                                                   la.is_web_checkout=0
                                                                AND
                                                                   op.id IS NOT NULL       THEN DATE(op.created_at)
                                                        END     AS application_dt,
                                                        l.id,
                                                        CASE
                                                             WHEN
                                                                  pfo.type='MonthlyPaymentOption' THEN
                                                                                                    CASE
                                                                                                       WHEN  ph.installment_count <=6                THEN '6 months'
                                                                                                       WHEN  (ph.installment_count BETWEEN 7 AND 8)  THEN '8 months'
                                                                                                       WHEN  ph.installment_count =9                 THEN '9 months'
                                                                                                       WHEN  ph.installment_count =10                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =12                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '24 months'
                                                                                                   END
                                                              WHEN
                                                                  pfo.type='BimonthlyPaymentOption' THEN
                                                                                                    CASE
                                                                                                       WHEN  ph.installment_count =12                THEN '6 months'
                                                                                                       WHEN  ph.installment_count =16                THEN '8 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '9 months'
                                                                                                       WHEN  ph.installment_count =20                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =36                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =48                THEN '24 months'
                                                                                                   END
                                                                                                   ELSE ph.installment_count
                                                        END       AS product_terms,
                                                        la.`type` AS la_type,
                                                        payment_frequency_option
                                                   FROM loan_applications la
                                                   INNER JOIN payment_frequency_options pfo   ON (pfo.id = la.current_payment_frequency_option_id)
                                                   INNER JOIN collaterals               co    ON (la.id  = co.loan_application_id)
                                                   INNER JOIN outgoing_payments         op    ON (la.id  = op.loan_application_id)
                                                   INNER JOIN loans                     l     ON (op.id  = l.outgoing_payment_id AND l.state !='void')
                                                   INNER JOIN orders o                        ON (o.id   = la.order_id)
                                                   INNER JOIN available_items           ai    ON (o.available_item_id = ai.id)
                                                   INNER JOIN locations                 loc   ON (loc.id              = ai.location_id)
                                                   INNER JOIN merchants                 m     ON (m.id                = loc.merchant_id)
                                                   LEFT  JOIN installments              min_i ON (min_i.id = (SELECT MIN(id)
                                                                                                                FROM installments
                                                                                                               WHERE loan_id = l.id
                                                                                                              )
                                                                                                 )
                                                    INNER JOIN installments               i    ON (l.id         = i.loan_id)
                                                    INNER JOIN funders                    f    ON (la.funder_id = f.id)
                                                    LEFT  JOIN loan_application_offers    lao  ON (   la.id = lao.loan_application_id
                                                                                                   AND
                                                                                                      lao.equal_installments=0
                                                                                                   AND
                                                                                                      lao.upfront_installment_percent=0.0
                                                                                                 )
                                                    LEFT  JOIN pricing_histories          ph   ON (ph.id=(SELECT MAX(id)
                                                                                                            FROM  pricing_histories
                                                                                                           WHERE loan_application_id=la.id
                                                                                                          )
                                                                                                  )
                                                    CROSS JOIN (SELECT 'All' AS payment_frequency_option) AS freq_opt
                                                        WHERE
                                                             la.type IS NULL
                                                           AND ('All'         =  'All' OR f.name   = 'All')
                                                           AND (' All' =  ' All'       OR pfo.type  = ' All')
                                                           AND (' All'       =  ' All' OR m.name   = ' All')
                                                           AND ('All'      =   'All'  OR 'All' = CASE
                                                      WHEN lao.id IS NOT NULL THEN 'Yes'
                                                      WHEN lao.id IS NULL     THEN 'No'
                                                                              ELSE 'All'
                                                  END
    )
                                                           AND ('12 months'    =  0      OR '12 months' = CASE
                                                          WHEN
                                                               pfo.type='MonthlyPaymentOption' THEN
                                                                                                   CASE
                                                                                                       WHEN  ph.installment_count <=6                THEN '6 months'
                                                                                                       WHEN  (ph.installment_count BETWEEN 7 AND 8)  THEN '8 months'
                                                                                                       WHEN  ph.installment_count =9                 THEN '9 months'
                                                                                                       WHEN  ph.installment_count =10                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =12                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '24 months'
                                                                                                   END
                                                           WHEN
                                                                pfo.type='BimonthlyPaymentOption' THEN
                                                                                                    CASE
                                                                                                       WHEN  ph.installment_count =12                THEN '6 months'
                                                                                                       WHEN  ph.installment_count =16                THEN '8 months'
                                                                                                       WHEN  ph.installment_count =18                THEN '9 months'
                                                                                                       WHEN  ph.installment_count =20                THEN '10 months'
                                                                                                       WHEN  ph.installment_count =24                THEN '12 months'
                                                                                                       WHEN  ph.installment_count =36                THEN '18 months'
                                                                                                       WHEN  ph.installment_count =48                THEN '24 months'
                                                                                                   END
                                                                                                   ELSE ph.installment_count
                                                        END
                                                               )
                                                           AND
                                                              (
                                                                (
                                                                     la.is_web_checkout=1
                                                                  AND
                                                                     co.type='CashDeposit'
                                                                  AND
                                                                     co.status='auth_success'
                                                                  AND
                                                                     co.updated_at >= IFNULL('2015-10-01',IF(DAY(CURRENT_DATE)=1,
                                                                                                               DATE_SUB(CURRENT_DATE,INTERVAL 12 MONTH),
                                                                                                               DATE_SUB(DATE_SUB(CURRENT_DATE,INTERVAL (DAY(CURRENT_DATE)-1) DAY),INTERVAL 12 MONTH)
                                                                                                              )
                                                                                             )  AND co.updated_at < IFNULL(DATE_ADD(DATE('2015-10-31'),INTERVAL 1 DAY),DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                                                                )
                                                             OR
                                                               (
                                                                   la.is_web_checkout=0
                                                                AND
                                                                   op.created_at >= IFNULL('2015-10-01',IF(DAY(CURRENT_DATE)=1,
                                                                                                               DATE_SUB(CURRENT_DATE,INTERVAL 12 MONTH),
                                                                                                               DATE_SUB(DATE_SUB(CURRENT_DATE,INTERVAL (DAY(CURRENT_DATE)-1) DAY),INTERVAL 12 MONTH)
                                                                                                              )
                                                                                             ) AND op.created_at < IFNULL(DATE_ADD(DATE('2015-10-31'),INTERVAL 1 DAY),DATE_ADD(CURRENT_DATE,INTERVAL 1 DAY))
                                                                AND
                                                                   co.type='CashDeposit'
                                                               AND
                                                                  co.status='auth_success'
                                                               )
                                                             )
                                                ) AS a
                                               WHERE la_type IS NULL
                                                /*
                                                WHERE (
                                                        (
                                                             la_type='MobileApplication'
                                                         AND
                                                              product_terms NOT IN ('18 months','24 months')
                                                        )
                                                      OR
                                                        (
                                                              la_type IS NULL
                                                         AND
                                                              1=1
                                                        )
                                                      )
                                                */
                                                GROUP BY 1,
                                                         2
                                  ) AS total_loans_cnt ON (
                                                             total_loans_cnt.dt_year  = main_1.origination_year
                                                         AND
                                                             total_loans_cnt.dt_month = main_1.origination_month
                                                         )
WHERE
     installment_number=1
  AND 
      (
         (
          --   payment_frequency_option='BimonthlyPaymentOption'
         -- AND
             1=1
         )
      OR
        (
       --     payment_frequency_option <> 'BimonthlyPaymentOption'   -- IN ('MonthlyPaymentOption','All', ' All')
       -- AND
          ( 1=1
         --    cnt_loan >=1000
         -- OR
          --   cnt_loan = total_cnt_loans
          )
        )
      )

ORDER BY merchant,
         origination_year,
         origination_month

    
         
