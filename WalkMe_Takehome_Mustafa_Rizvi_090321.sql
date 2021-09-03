
  # Sales Enablement benefits and impacts are multifaceted ranging from revenue driven to efficiency driven. 
   
   -- As from the Revenue-oriented perspective, following Sales Enablement impacts need to looked at most closely:
   
   -- Is the team delivering Improved "Win rates" (new customer acquisitions)?
   -- Is the reduction in Churn Rates happening?
   -- Are the Sales Cycle Times improving along with a fulfilling and smooth customers' buying journey?
   -- Targeting right customer profile at perfect time?
   
   -- As from the Efficiency standpoint, following impacts need to be looked at
   
   -- Reduce cost of selling attained?
   -- Is this the current enablement system delivering insights into Vantage point view of existing sales pipeline?
   -- Decrease the sales staff turnover rate due to overall positive impacts of a proper enabled system in place?
   -- Customers' purchase journey is more fruitful resulting in fulfilling cutsomer experience
   -- Results in higher selling time per salesperon happening across or not yet?
  

  # Some of the effective Sales Enablement Metrics are:
  
  -- Sales Lifecycle Time (Time from Lead start to close) - Shorter sales cycle equates to more lead conversion and increase bottomline 
  -- Lead to Sales Conversion Rates (This metric gives  more visiblity into how effectively the overall funnel is working)
  -- Sales Productivity (Total monthly sales over Total Sales people or individual sales rep to measure monthly sales quota)
  -- Sales Rep Onboarding Time (Average ramp up time for Sales Rep how quicly they are learing and using the sales best practices)
  -- Win / Loss Rate (Number of opportunies won / Total number of opportunites) -- Considered as the most important Sales Enablement Metric
  
  
 
SELECT 
      close_quarter                                                               AS `Quarter`,
      account_owner                                                               AS `Account Owner`,
      account_owner_segment                                                       AS `Account Owner Segment`,
      -- Safe divide function available in Google Big Query
      ROUND(100*SAFE_DIVIDE(total_closed_won,total_closed_won_and_closed_lost),2) AS `Close Rate`      
FROM
   (
    SELECT -- Truncate the "close date" to the quarterly level
      DATE_TRUNC(o.close_date,QUARTER)                                               AS close_quarter,
      a.account_owner,
      a.account_owner_segment,
      -- Counting the numerator and denominator for the "Close Rate" calculation
      SUM(CASE WHEN o.oppty_stage='Closed Won' THEN 1 ELSE 0 END)                    AS total_closed_won,
      SUM(CASE WHEN o.oppty_stage IN ('Closed Won','Closed Lost') THEN 1 ELSE 0 END) AS total_closed_won_and_closed_lost   
    FROM Account a 
    INNER JOIN Opportunities o ON (a.account_id = o.account_id)
    GROUP BY 1,
             2,
             3
    ) AS main 
ORDER BY 1 DESC -- Sorting in the descending order of quarter

        /* ------------ Method 1 - 7 Days Rolling Rates With Window Function --------- */

        SELECT  
               DATE_TRUNC(created_date,MONTH)                                                                          AS lead_created_month,
               created_date,
               total_leads,
               total_lead_with_intro_calls,
               total_lead_turned_opportunities,
               ROUND(100*SAFE_DIVIDE(total_lead_with_intro_calls_7_day_rolling,total_leads_7_day_rolling),2)           AS lead_to_intro_rate_7_day_rolling,
               ROUND(100*SAFE_DIVIDE(total_total_lead_turned_opportunities_7_day_rolling,total_leads_7_day_rolling),2) AS lead_to_opportunity_rate_7_day_rolling               
        FROM 
          (
          SELECT 
              created_date,
              total_leads,
              total_lead_with_intro_calls,
              total_lead_turned_opportunities,
              SUM(total_leads)                     OVER(ORDER BY created_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS total_leads_7_day_rolling,
              SUM(total_lead_with_intro_calls)     OVER(ORDER BY created_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS total_lead_with_intro_calls_7_day_rolling,
              SUM(total_lead_turned_opportunities) OVER(ORDER BY created_date ASC ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS total_total_lead_turned_opportunities_7_day_rolling,   
          FROM (       
               SELECT
                  l.created_date             AS created_date,                                           
                  COUNT(DISTINCT l.lead_id)  AS total_leads,
                  COUNT(DISTINCT ic.lead_id) AS total_lead_with_intro_calls,
                  COUNT(DISTINCT o.lead_id)  AS total_lead_turned_opportunities
               FROM Leads l 
               LEFT JOIN Intro_call ic ON (l.lead_id  = ic.lead_id) -- left join since some leads may not be qualified to call
               LEFT JOIN Opportunity o ON (ic.lead_id = o.lead_id AND ic.intro_call_id = o.intro_call_id) -- left join since some leads not qualified opportunity
               GROUP BY 1
              ) AS temp1
          ) AS temp2 
         WHERE created_date >= DATE_SUB(CURRENT_DATE,INTERVAL EXTRACT(MONTH FROM CURRENT_DATE) -1) -- Since the start of the current month
           AND created_date = CURRENT_DATE -- only current date is good since window function will do the rolling sum and rates
         ORDER BY created_date ASC
         
              
     /* ------------ Method 2 - 7 Day Rates without Window Function --------- */         
      
     SELECT -- Truncate the date to monthly level
           DATE_TRUNC(created_date,MONTH)     AS lead_created_month,
           ROUND(100*SAFE_DIVIDE(SUM(total_lead_with_intro_calls),
                                 SUM(total_leads)
                                 ),2
                )                             AS lead_to_intro_rate_7_day, -- Denominator is total leads
           ROUND(100*SAFE_DIVIDE(SUM(total_lead_turned_opportunities),
                                 SUM(total_leads)
                                ),2
                )                             AS lead_to_opportunity_rate_7_day -- Denomintaor is total leads   
     FROM 
         (
          SELECT 
             created_date,
             total_leads,
             total_lead_with_intro_calls,
             total_lead_turned_opportunities,
             RANK() OVER(ORDER BY created_date DESC) AS rank_date_descending -- rank dates in descending order
          FROM (       
               SELECT
                  CASE -- only considering the current month if it has reached at least 7 days OR all full earlier months are included  
                     WHEN (  (     EXTRACT(MONTH FROM CURRENT_DATE) = EXTRACT(MONTH FROM l.created_date)
                              AND  EXTRACT(DAY FROM CURRENT_DATE) >=7
                             )                                    
                          OR   (EXTRACT(MONTH FROM l.created_date) < EXTRACT(MONTH FROM CURRENT_DATE))
                          )                                      THEN l.created_date 
                                                                 ELSE CAST(NULL AS DATE)
                  END                        AS created_date                                             
                  COUNT(DISTINCT l.lead_id)  AS total_leads,
                  COUNT(DISTINCT ic.lead_id) AS total_lead_with_intro_calls,
                  COUNT(DISTINCT o.lead_id)  AS total_lead_turned_opportunities
               FROM Leads l 
               LEFT JOIN Intro_call ic ON (l.lead_id  = ic.lead_id) -- left join since some leads may not be qualified to call
               LEFT JOIN Opportunity o ON (ic.lead_id = o.lead_id AND ic.intro_call_id = o.intro_call_id) -- left join since some leads not qualified opportunity
               GROUP BY 1
              ) AS temp1 
           WHERE created_date IS NOT NULL  -- Show current month only if 7 days have been passed
         ) AS temp2 
     WHERE rank_date_descening <=7 -- Filtering only recent 7 days of the month reached at least 7 day maturity
     GROUP BY 1 
     
     -- Here are the ways to measure the root cause:
     
     /*
     -- To investigate any issues with existing report or process is to reserse engineer the whole process and see where the potential gaps and anamolies are (if there any exists any)
     
     -- Second approach will be looking at the overall funnel volume which is interdependent multi-stage process. 
        Looking at the monthly volume of total incoming leads and see if there is signficant drop of change in overall volume. 
        If that looks fine, then looking at the intro call volume and look for potential cues for drop in rates.
        Lastly, the opportunity creation volume from the intro call process will give vital clues as to what is broken in the funnel process.
     
     */
     
    -- Time series line graphs depicting volume at the monthly levels are always helpful and easier to understand and interpret for general audience
    -- Funnel graph with actual volume and percentage at each of the funnel will also present a clearer visibility into the sales funnel process.
     



 -- Exploratory Data Analysis (EDA) would be a good starting point to do the high level impact analysis   
 -- It is important to look at different dimensions and see various trends that are the most impacted by the lost opportunities.
 -- Both in terms of ARR and assocaited Volume. 
 
 -- Looking at top 10 accounts with the most account lost in terms of volume and ARR, vital trend to look at
 
 WITH top_ten_accounts_lost_opportunity_volume AS (
      SELECT 
             a.account_id,
             COUNT(DISTINCT o.opportunity_id)             AS total_opportunity_lost,
             SUM(o.arr_usd)                               AS total_ARR_lost,
             AVG(o.arr_usd)                               AS avg_ARR_lost,
             APPROX_QUANTILES(o.arr_usd, 100)[OFFSET(50)] AS median_ARR_lost, 
             MAX(o.arr_usd)                               AS max_ARR_lost,
             MIN(o.arr_usd)                               AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)             AS range_ARR_lost
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as Closed Lost
             )  
        GROUP BY a.account_id
        ORDER BY 2 DESC -- By lost volume 
        LIMIT 10  -- limit to top ten 
      ) ,  top_ten_accounts_lost_opportunity_ARR AS (
                                                          SELECT 
                                                             a.account_id,
                                                             COUNT(DISTINCT o.opportunity_id)             AS total_opportunity_lost,
                                                             SUM(o.arr_usd)                               AS total_ARR_lost,
                                                             AVG(o.arr_usd)                               AS avg_ARR_lost,
                                                             APPROX_QUANTILES(o.arr_usd, 100)[OFFSET(50)] AS median_ARR_lost,
                                                             MAX(o.arr_usd)                               AS max_ARR_lost,
                                                             MIN(o.arr_usd)                               AS min_ARR_lost,
                                                             MAX(o.arr_usd)  - MIN(o.arr_usd)             AS range_ARR_lost
                                                         FROM Account a 
                                                         INNER JOIN Opportunity o ON (a.account_id = o.account_id)
                                                         WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
                                                                OR
                                                                  o.stage ='Closed Lost' -- Secondly, anything that is already marked as Closed Lost
                                                                )  
                                                         GROUP BY a.account_id
                                                         ORDER BY 3 DESC -- By lost ARR 
                                                         LIMIT 10  
                                                  )  
   SELECT 
         'top_ten_accounts_lost_opportunity_Volume' AS label,
         account_id,
         total_opportunity_lost,
         total_ARR_lost,
         avg_ARR_lost,
         median_ARR_lost,
         max_ARR_lost,
         min_ARR_lost,
         range_ARR_lost
   FROM  top_ten_accounts_lost_opportunity_volume      
   
   UNION ALL 
   
   SELECT 
         'top_ten_accounts_lost_opportunity_ARR' AS label,
         account_id,
         total_opportunity_lost,
         total_ARR_lost,
         avg_ARR_lost,
         median_ARR_lost,
         max_ARR_lost,
         min_ARR_lost,
         range_ARR_lost
   FROM  top_ten_accounts_lost_opportunity_ARR 
   
   
   
   
 -- Dimenison-wise break-down of trends                                                      
 
 SELECT
       region,
       total_opportunity_lost,
       -- % distribution of each region - highlight where the maximum impact is
       ROUND(100*SAFE_DIVIDE(total_opportunity_lost, 
                             SUM(total_opportunity_lost) OVER()),2) AS percentage_distribution_opportunity_lost,
       total_opportunity_lost,
       total_ARR_lost,
       lost_ARR_per_opportunity,
       max_ARR_lost,
       min_ARR_lost,
       range_ARR_lost
 FROM (
       SELECT 
             a.region,
             COUNT(DISTINCT o.opportunity_id)    AS total_opportunity_lost,
             SUM(o.arr_usd)                      AS total_ARR_lost,
             AVG(o.arr_usd)                      AS avg_ARR_lost,
             MAX(o.arr_usd)                      AS max_ARR_lost,
             MIN(o.arr_usd)                      AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)    AS range_ARR_lost                  
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as Closed Lost
             )  
        GROUP BY a.region
      )  AS main 
  
 -- It is important to see any particular industry has been impacted by the Churn
 
 SELECT
       industry,
       total_opportunity_lost,
       -- % distribution of each industry - highlight where the maximum impact is
       ROUND(100*SAFE_DIVIDE(total_opportunity_lost, 
                             SUM(total_opportunity_lost) OVER()),2) AS percentage_distribution_opportunity_lost,
       total_opportunity_lost,
       total_ARR_lost,
       lost_ARR_per_opportunity,
       max_ARR_lost,
       min_ARR_lost,
       range_ARR_lost
 FROM (
       SELECT 
             a.industry,
             COUNT(DISTINCT o.opportunity_id)    AS total_opportunity_lost,
             SUM(o.arr_usd)                      AS total_ARR_lost,
             AVG(o.arr_usd)                      AS avg_ARR_lost,
             MAX(o.arr_usd)                      AS max_ARR_lost,
             MIN(o.arr_usd)                      AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)    AS range_ARR_lost 
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as "Closed Lost"
             )  
        GROUP BY a.industry
      )  AS main            
  
      
      
  -- It is important to see any particular Segment has been impacted by the Churn
 
 SELECT
       segment,
       total_opportunity_lost,
       -- % distribution of each segment - highlight where the maximum impact is
       ROUND(100*SAFE_DIVIDE(total_opportunity_lost, 
                             SUM(total_opportunity_lost) OVER()),2) AS percentage_distribution_opportunity_lost,
       total_opportunity_lost,
       total_ARR_lost,
       lost_ARR_per_opportunity,
       max_ARR_lost,
       min_ARR_lost,
       range_ARR_lost
 FROM (
       SELECT 
             a.segment,
             COUNT(DISTINCT o.opportunity_id)    AS total_opportunity_lost,
             SUM(o.arr_usd)                      AS total_ARR_lost,
             AVG(o.arr_usd)                      AS avg_ARR_lost,
             MAX(o.arr_usd)                      AS max_ARR_lost,
             MIN(o.arr_usd)                      AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)    AS range_ARR_lost 
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as "Closed Lost"
             )  
        GROUP BY a.segment
      )  AS main       
      
      
 -- By Account activation / cohort month
      
 SELECT
       action_month,
       total_opportunity_lost,
       -- % distribution of each action month cohort - highlight where the maximum impact is
       ROUND(100*SAFE_DIVIDE(total_opportunity_lost, 
                             SUM(total_opportunity_lost) OVER()),2) AS percentage_distribution_opportunity_lost,
       total_opportunity_lost,
       total_ARR_lost,
       lost_ARR_per_opportunity,
       max_ARR_lost,
       min_ARR_lost,
       range_ARR_lost
 FROM (
       SELECT 
             DATE_TRUNC(a.action_date,MONTH)     AS activation_month,
             COUNT(DISTINCT o.opportunity_id)    AS total_opportunity_lost,
             SUM(o.arr_usd)                      AS total_ARR_lost,
             AVG(o.arr_usd)                      AS avg_ARR_lost,
             MAX(o.arr_usd)                      AS max_ARR_lost,
             MIN(o.arr_usd)                      AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)    AS range_ARR_lost 
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as "Closed Lost"
             )  
        GROUP BY 1
      )  AS main            
      
  -- By Business Lost Reason
      
 SELECT
       business_lost_reason,
       total_opportunity_lost,
       -- % distribution of each business lost reason - highlight where the maximum impact is
       ROUND(100*SAFE_DIVIDE(total_opportunity_lost, 
                             SUM(total_opportunity_lost) OVER()),2) AS percentage_distribution_opportunity_lost,
       total_opportunity_lost,
       total_ARR_lost,
       lost_ARR_per_opportunity,
       max_ARR_lost,
       min_ARR_lost,
       range_ARR_lost
 FROM (
       SELECT 
             o.business_lost_reason,
             COUNT(DISTINCT o.opportunity_id)    AS total_opportunity_lost,
             SUM(o.arr_usd)                      AS total_ARR_lost,
             AVG(o.arr_usd)                      AS avg_ARR_lost,
             MAX(o.arr_usd)                      AS max_ARR_lost,
             MIN(o.arr_usd)                      AS min_ARR_lost,
             MAX(o.arr_usd)  - MIN(o.arr_usd)    AS range_ARR_lost 
       FROM Account a 
       INNER JOIN Opportunity o ON (a.account_id = o.account_id)
       WHERE (  o.renewal_date < DATE_SUB(CURRENT_DATE,INTERVAL 15 DAY) -- Firstly, 15 days grace period after the renewal period ends after which point the opportunity will automatically be clsoed lost
              OR
                o.stage ='Closed Lost' -- Secondly, anything that is already marked as "Closed Lost"
             )  
        GROUP BY o.business_lost_reason
      )  AS main
      
  -- Ideally, more information such as "Grace period" when the renewal period ends would have surely helped. It would be important to know incorporate more robust data filter along with stage
  -- Close date would have also helped. Sometimes, Renewal or Close date can be used interchangeably, however more data transparency would have helped.
  
  

