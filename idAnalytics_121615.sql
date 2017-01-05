SELECT 
       AccountLinkingKey,
       AccountNumber,
       SnapshotDate,
       SSN,
       FirstName,
       LastName,
       MiddleName,
       Suffix,
       Address,
       Zip,
       AddressIndicator,
       ResidenceCode,
       CountryCode,
       DOB,
       Phone_1,
       Phone_2,
       Phone_3,

       /* Need to ask about this */
       ECOACode,
       ConsumerTransactionType,
       AccountOpenDate,
       AccountCloseDate,
       CreditLine,
       CycleIdentifier,
       TermsDuration, 
       TermsFrequency, 
       OriginalChargeOffAmount,
       ChargeOffDate,
       LossAmount,
       DepositAmount,
       CreditClass,
       `FCRA Compliance/Date of First Delinquency`,
       ComplianceConditionCode,
       CorrectionIndicator,
       PortfolioType,
       AccountType,
       SpecialComment,
       PortfolioIndicator,
       K2CompanyName,
       CASE 
            WHEN l_state='completed'              THEN '13'
            WHEN l_state='written_off'            THEN '97'
            WHEN DaysOverDue='void'               THEN 'DA'
            WHEN collector_id BETWEEN 1  AND 10   THEN '93'
            WHEN DaysOverDue BETWEEN 0   AND 29   THEN '11'  
            WHEN DaysOverDue BETWEEN 30  AND 59   THEN '71'
            WHEN DaysOverDue BETWEEN 60  AND 89   THEN '78'
            WHEN DaysOverDue BETWEEN 90  AND 119  THEN '80'
            WHEN DaysOverDue BETWEEN 120 AND 149  THEN '82'
            WHEN DaysOverDue BETWEEN 150 AND 179  THEN '83'
            WHEN DaysOverDue >=180                THEN '84'
                                                  ELSE NULL 
      END                                                    AS AccountStatus, 
      CASE 
            WHEN l_state='written_off'            THEN 'L'
            WHEN collector_id BETWEEN 1  AND 10   THEN 'G'
            WHEN DaysOverDue BETWEEN 0   AND 29   THEN '0'  
            WHEN DaysOverDue BETWEEN 30  AND 59   THEN '1'
            WHEN DaysOverDue BETWEEN 60  AND 89   THEN '2'
            WHEN DaysOverDue BETWEEN 90  AND 119  THEN '3'
            WHEN DaysOverDue BETWEEN 120 AND 149  THEN '4'
            WHEN DaysOverDue BETWEEN 150 AND 179  THEN '5'
            WHEN DaysOverDue >=180                THEN '6'
                                                  ELSE NULL 
       END                                                   AS PaymentRating,  
       PaymentHistoryProfile,
       AmountPastDue,
       HighestCreditOrOriginalLoanAmount,
       ScheduledMonthlyPaymentAmount,
       DateOfLastPayment,
       IFNULL(ActualPaymentAmount,0)                         AS ActualPaymentAmount,
       IFNULL(CurrentBalance,0)                              AS CurrentBalance
FROM 
(
SELECT
       u.id                                                            AS AccountLinkingKey,  -- Required
       o.application_number                                            AS AccountNumber,      -- Required
       DATE(CURRENT_DATE)                                              AS SnapshotDate,       -- Required
       NULL                                                            AS SSN,                -- Required
       u.last_name                                                     AS LastName,           -- Required
       u.first_name                                                    AS FirstName,          -- Required
       u.middle_name                                                   AS MiddleName,
       NULL                                                            AS Suffix,
       a.street                                                        AS Address,            -- Required
       a.zip                                                           AS Zip,                -- Required
       NULL                                                            AS AddressIndicator,
       NULL                                                            AS ResidenceCode,
       NULL                                                            AS CountryCode,
       DATE(u.date_of_birth)                                           AS DOB,
       ph.number                                                       AS Phone_1,
       ph_m.number                                                     AS Phone_2,
       NULL                                                            AS Phone_3,

       /* Need to ask about this */
       NULL                                                            AS ECOACode,           -- Required
       NULL                                                            AS ConsumerTransactionType,
       DATE(l.originated_at)                                           AS AccountOpenDate,    -- Required
       DATE(l.actual_repayment_date)                                   AS AccountCloseDate,
       IFNULL(da.credit_line,0)                                        AS CreditLine,
       NULL                                                            AS CycleIdentifier,
       CASE 
            WHEN lao.term IS NULL THEN 
                                    (SELECT term
                                       FROM loan_application_offers 
                                      WHERE loan_application_id=la.id
                                      LIMIT 1
                                     ) 
                              ELSE lao.term 
       END                                                             AS TermsDuration, 
       CASE pfo.`type`
          WHEN 'MonthlyPaymentOption'    THEN 'M'
          WHEN 'BiMonthlyPaymentOption'  THEN 'B'
                                         ELSE NULL 
       END                                                             AS TermsFrequency, 
       NULL                                                            AS OriginalChargeOffAmount,
       NULL                                                            AS ChargeOffDate,
       NULL                                                            AS LossAmount,
       IFNULL(co.security_deposit_amount,0)                            AS DepositAmount,
       NULL                                                            AS CreditClass,
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
         )                                                             AS `FCRA Compliance/Date of First Delinquency`, -- Required
        NULL                                                           AS ComplianceConditionCode,                     -- Required
        NULL                                                           AS CorrectionIndicator,
        'C'                                                            AS PortfolioType,
        NULL                                                           AS AccountType,
        NULL                                                           AS SpecialComment,
        NULL                                                           AS PortfolioIndicator,
        NULL                                                           AS K2CompanyName,
        ( 
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
                                               
        )                                                               AS DaysOverDue,
        NULL                                                            AS PaymentHistoryProfile,
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
              ),0)                                                      AS AmountPastDue,
         ROUND(l.original_amount,0)                                     AS HighestCreditOrOriginalLoanAmount,
         CASE 
            WHEN lao.id IS NOT NULL THEN 
                                          (
                                            SELECT ROUND(original_amount,0) 
                                              FROM installments 
                                            WHERE loan_id=l.id 
                                              AND `state`='scheduled'
                                            -- ORDER BY id ASC
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
                                             -- ORDER BY id ASC 
                                             LIMIT 1   
                                             )   
        END                                                               AS ScheduledMonthlyPaymentAmount,
        (
        SELECT MAX(DATE(settled_on))
          FROM loan_payments 
         WHERE loan_id=l.id 
          AND  `state`='completed'
          AND  collateral_id IS NULL  -- Only the payments towards installments
        )                                                                 AS DateOfLastPayment,
         CASE 
             WHEN lao.id IS NOT NULL THEN -- This check is necessary to exclude the upfront payment amount
                                          (
                                            SELECT ROUND(SUM(actual_repayment_amount),0) 
                                              FROM installments 
                                            WHERE loan_id=l.id 
                                              AND `state`='completed'
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
                                             )   
        END                                                               AS ActualPaymentAmount,
        IFNULL((
        SELECT 
              SUM(ROUND(COALESCE(modified_amount,original_amount) + IFNULL(additional_fees,0),0))
        FROM installments 
        WHERE loan_id=l.id
          AND `state` IN ('scheduled','overdue')
        ),0)                                                              AS CurrentBalance,
        l.`state`                                                         AS l_state,
        l.collector_id                                                   
FROM loan_applications la 
INNER JOIN orders o                      ON (o.id   = la.order_id)
INNER JOIN users  u                      ON (u.id   = o.user_id)
INNER JOIN available_items ai            ON (ai.id  = o.available_item_id)
INNER JOIN locations       loc           ON (loc.id = ai.location_id)
INNER JOIN merchants       m             ON (m.id   = loc.merchant_id)
INNER JOIN outgoing_payments op          ON (la.id  = op.loan_application_id)
INNER JOIN decision_attempts       da    ON (da.id  = (SELECT MAX(id)
                                                         FROM decision_attempts 
                                                        WHERE loan_application_id=la.id  
                                                      )
                                            )
INNER JOIN loans                   l     ON (op.id  = l.outgoing_payment_id)
LEFT  JOIN payment_frequency_options pfo ON (pfo.id = la.current_payment_frequency_option_id)
LEFT  JOIN loan_application_offers lao   ON (   la.id  = lao.loan_application_id
                                            AND 
                                                 lao.equal_installments=0
                                            AND 
                                                 lao.upfront_installment_percent=0.0      
                                            )
LEFT  JOIN phone_numbers           ph    ON (ph.id  = u.current_phone_number_id)
LEFT  JOIN phone_numbers           ph_m  ON (ph_m.id  = u.current_mobile_phone_number_id)
LEFT  JOIN addresses               a     ON (a.id     = u.current_address_id)
LEFT  JOIN collaterals             co    ON (   la.id    = co.loan_application_id 
                                             AND
                                                co.`type`='CashDeposit' 
                                             AND 
                                                co.`status`='auth_success'   
                                            )
WHERE la.`type` IS NULL -- Smartypay loans
  AND l.created_at >= '2015-11-07' 
-- LIMIT 100 
-- Sample file size
) AS a 


