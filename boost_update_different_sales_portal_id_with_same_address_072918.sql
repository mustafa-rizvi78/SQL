
SELECT *
FROM 
(
SELECT 
        a.sales_portal_id,
        b.sales_portal_id sales_portal_id_new,
        IF(a.account_id   <=> b.account_id   OR b.account_id IS  NULL ,0,1)   AS is_change_account,
        IF(a.account_id_1 <=> b.account_id_1 OR b.account_id_1 IS NULL ,0,1) AS is_change_account_1,
        IF(a.retailer_acc <=> b.retailer_acc OR b.retailer_acc IS NULL ,0,1) AS is_change_retailer_acc,
        IF(a.terminal_id <=> b.terminal_id   OR  b.terminal_id IS NULL,0,1)   AS is_change_terminal_id,
        IF(a.agent_code  <=> b.agent_code    OR b.agent_code IS  NULL ,0,1)   AS is_change_agent_code ,
        IF(a.prepaid_area  <=> b.prepaid_area OR b.prepaid_area IS  NULL  ,0,1)   AS is_change_prepaid_area,
        IF(a.prepaid_market  <=> b.prepaid_market OR b.prepaid_market IS NULL  ,0,1)   AS is_change_prepaid_market,
        IF(a.prepaid_region  <=> b.prepaid_region OR b.prepaid_region IS NULL  ,0,1)   AS is_change_prepaid_region,
        IF(a.ism  <=> b.ism OR b.ism IS NULL ,0,1)   AS is_changed_ism,
        IF(a.account_owner  <=> b.account_owner OR b.account_owner IS NULL ,0,1)   AS is_changed_account_owner,
        IF(a.parent_account   <=> b.parent_account OR b.parent_account IS NULL ,0,1)   AS is_changed_parent_account,
        IF(a.account_id_2    <=> b.account_id_2 OR b.account_id_2 IS NULL  ,0,1)   AS is_changed_account_id_2,
        IF(a.prepaid_door_type    <=> b.prepaid_door_type OR b.prepaid_door_type IS NULL   ,0,1)   AS is_changed_prepaid_door_type,
        IF(a.account_name      <=> b.account_name   OR b.account_name IS  NULL  ,0,1)   AS is_changed_account_name,
        IF(a.account_address      <=> b.account_address OR b.account_address IS NULL     ,0,1)   AS is_changed_account_address,
        IF(a.account_city      <=> b.account_city OR b.account_city IS NULL    ,0,1)   AS is_changed_account_city,
        IF(a.acccount_state_province      <=> b.acccount_state_province OR b.acccount_state_province IS NULL    ,0,1)   AS is_changed_acccount_state_province,
        IF(a.account_zip_postal_code      <=> b.account_zip_postal_code OR b.account_zip_postal_code IS NULL    ,0,1)   AS is_changed_account_zip_postal_code,
        IF(a.phone_number      <=> b.phone_number    OR b.phone_number IS NULL ,0,1)   AS is_changed_phone_number,
        IF(a.prepaid_status      <=> b.prepaid_status OR b.prepaid_status IS NULL    ,0,1)   AS is_changed_prepaid_status,
        IF(a.prepaid_open_date      <=> b.prepaid_open_date OR b.prepaid_open_date IS NULL    ,0,1)   AS is_changed_prepaid_open_date,
        IF(a.dealer_profile_id       <=> b.dealer_profile_id OR b.dealer_profile_id IS NULL     ,0,1)   AS is_changed_dealer_profile_id,
        IF(a.location_name       <=> b.location_name OR b.location_name IS NULL     ,0,1)   AS is_changed_location_name,
        IF(a.sales_channel       <=> b.sales_channel OR b.sales_channel IS NULL    ,0,1)   AS is_changed_sales_channel,
        IF(a.status_text        <=> b.status_text    OR b.status_text IS NULL     ,0,1)   AS is_changed_status_text,
        IF(a.date_onboarded        <=> b.date_onboarded OR b.date_onboarded IS NULL       ,0,1)   AS is_changed_date_onboarded
FROM boost_dealer_data a
INNER JOIN boost_dealer_data_new b ON (a.sales_portal_id = b.sales_portal_id)
-- WHERE a.sales_portal_id=40384
) AS a 
WHERE 
    is_change_account =1
    /* 
AND is_change_account_1 = 0
AND is_change_retailer_acc=0
AND is_change_terminal_id=0
AND is_change_agent_code=0
AND is_change_prepaid_area=0
AND is_change_prepaid_market=0
AND is_change_prepaid_region=0
AND is_changed_ism=0
AND is_changed_account_owner=0
AND is_changed_parent_account=0
AND is_changed_account_id_2=0
AND is_changed_prepaid_door_type=0
AND is_changed_account_name=0
AND is_changed_account_address=0
AND is_changed_account_city=0
AND is_changed_acccount_state_province=0
AND is_changed_account_zip_postal_code=0
AND is_changed_phone_number=0
AND is_changed_prepaid_status=0
AND is_changed_prepaid_open_date=0
AND is_changed_dealer_profile_id=0
AND is_changed_dealer_profile_id=0
AND is_changed_sales_channel=0
AND is_changed_status_text=0
AND is_changed_date_onboarded=0
*/


SELECT *
FROM 
(
SELECT 
        a.sales_portal_id,
        b.sales_portal_id,
        IF(a.account_id   <=> b.account_id   AND b.account_id IS  NULL ,0,1)   AS is_change_account,
        IF(a.account_id_1 <=> b.account_id_1 AND b.account_id_1 IS NULL ,0,1) AS is_change_account_1,
        IF(a.retailer_acc <=> b.retailer_acc AND b.retailer_acc IS NULL ,0,1) AS is_change_retailer_acc,
        IF(a.terminal_id <=> b.terminal_id   AND b.terminal_id IS NULL,0,1)   AS is_change_terminal_id,
        IF(a.agent_code  <=> b.agent_code    AND b.agent_code IS  NULL ,0,1)   AS is_change_agent_code ,
        IF(a.prepaid_area  <=> b.prepaid_area AND b.prepaid_area IS  NULL  ,0,1)   AS is_change_prepaid_area,
        IF(a.prepaid_market  <=> b.prepaid_market AND b.prepaid_market IS NULL  ,0,1)   AS is_change_prepaid_market,
        IF(a.prepaid_region  <=> b.prepaid_region AND b.prepaid_region IS NULL  ,0,1)   AS is_change_prepaid_region,
        IF(a.ism  <=> b.ism AND b.ism IS NULL ,0,1)   AS is_changed_ism,
        IF(a.account_owner  <=> b.account_owner AND b.account_owner IS NULL ,0,1)   AS is_changed_account_owner,
        IF(a.parent_account   <=> b.parent_account AND b.parent_account IS NULL ,0,1)   AS is_changed_parent_account,
        IF(a.account_id_2    <=> b.account_id_2 AND b.account_id_2 IS NULL  ,0,1)   AS is_changed_account_id_2,
        IF(a.prepaid_door_type    <=> b.prepaid_door_type AND b.prepaid_door_type IS NULL   ,0,1)   AS is_changed_prepaid_door_type,
        IF(a.account_name      <=> b.account_name   AND b.account_name IS  NULL  ,0,1)   AS is_changed_account_name,
        IF(a.account_address      <=> b.account_address AND b.account_address IS NULL     ,0,1)   AS is_changed_account_address,
        IF(a.account_city      <=> b.account_city AND b.account_city IS NULL    ,0,1)   AS is_changed_account_city,
        IF(a.acccount_state_province      <=> b.acccount_state_province AND b.acccount_state_province IS NULL    ,0,1)   AS is_changed_acccount_state_province,
        IF(a.account_zip_postal_code      <=> b.account_zip_postal_code AND b.account_zip_postal_code IS NULL    ,0,1)   AS is_changed_account_zip_postal_code,
        IF(a.phone_number      <=> b.phone_number    AND b.phone_number IS NULL ,0,1)   AS is_changed_phone_number,
        IF(a.prepaid_status      <=> b.prepaid_status AND b.prepaid_status IS NULL    ,0,1)   AS is_changed_prepaid_status,
        IF(a.prepaid_open_date      <=> b.prepaid_open_date AND b.prepaid_open_date IS NULL    ,0,1)   AS is_changed_prepaid_open_date,
        IF(a.dealer_profile_id       <=> b.dealer_profile_id AND b.dealer_profile_id IS NULL     ,0,1)   AS is_changed_dealer_profile_id,
        IF(a.location_name       <=> b.location_name AND b.location_name IS NULL     ,0,1)   AS is_changed_location_name,
        IF(a.sales_channel       <=> b.sales_channel AND b.sales_channel IS NULL    ,0,1)   AS is_changed_sales_channel,
        IF(a.status_text        <=> b.status_text    AND b.status_text IS NULL     ,0,1)   AS is_changed_status_text,
        IF(a.date_onboarded        <=> b.date_onboarded AND b.date_onboarded IS NULL       ,0,1)   AS is_changed_date_onboarded
FROM boost_dealer_data a
INNER JOIN boost_dealer_data_new b ON (a.sales_portal_id = b.sales_portal_id)
WHERE a.sales_portal_id=40384
) AS a 
WHERE 
    is_change_account =0 
AND is_change_account_1 = 0
AND is_change_retailer_acc=0
AND is_change_terminal_id=0
AND is_change_agent_code=0
AND is_change_prepaid_area=0
AND is_change_prepaid_market=0
AND is_change_prepaid_region=0
AND is_changed_ism=0
AND is_changed_account_owner=0
AND is_changed_parent_account=0
AND is_changed_account_id_2=0
AND is_changed_prepaid_door_type=0
AND is_changed_account_name=0
AND is_changed_account_address=0
AND is_changed_account_city=0
AND is_changed_acccount_state_province=0
AND is_changed_account_zip_postal_code=0
AND is_changed_phone_number=0
AND is_changed_prepaid_status=0
AND is_changed_prepaid_open_date=0
AND is_changed_dealer_profile_id=0
AND is_changed_dealer_profile_id=0
AND is_changed_sales_channel=0
AND is_changed_status_text=0
AND is_changed_date_onboarded=0





UPDATE boost_dealer_data a 
    INNER JOIN boost_dealer_data_new b ON (a.sales_portal_id = b.sales_portal_id)
    SET a.prepaid_market = CASE 
                                  WHEN a.prepaid_market <=> b.prepaid_market
                                     OR 
                                      b.prepaid_market IS NULL              THEN a.prepaid_market
                                  WHEN a.prepaid_market <> b.prepaid_market THEN b.prepaid_market
                                                                            ELSE b.prepaid_market
                             END 



       IF(a.prepaid_market <=> b.prepaid_market,0,1)                   AS `mismatched prepaid market`,
       IF(a.prepaid_region <=> b.prepaid_region,0,1)                   AS `mismatched prepaid region`,
       IF(a.ism <=> b.ism,0,1)                                         AS `mismatch ism`,
       IF(a.prepaid_door_type <=> b.prepaid_door_type,0,1)             AS `mismatched prepaid_door_type`,
       IF(a.account_id_2 <=> b.account_id_2,0,1)                       AS `mismatched account_id_2`,
       IF(a.account_name <=> b.account_name,0,1)                       AS `mismatched account_name`,
       IF(a.account_address <=> b.account_address,0,1)                 AS `mismatched account_address`,
       IF(a.account_city <=> b.account_city,0,1)                       AS `mismatched account_city`,
       IF(a.acccount_state_province <=> b.acccount_state_province,0,1) AS `mismatched acccount_state_province`,
       IF(a.account_zip_postal_code <=> b.account_zip_postal_code,0,1) AS `mismatched account_zip_postal_code`


START TRANSACTION;

UPDATE boost_dealer_data a 
INNER JOIN 
(
SELECT
        c.sales_portal_id             AS sales_portal_id_new_table,
        d.sales_portal_id             AS sales_portal_id_old_table,
        c.account_id                  AS account_id_new_table,
        c.account_id_1                AS account_id_1_new_table,
        c.retailer_acc                AS retailer_acc_new_table,
        c.terminal_id                 AS terminal_id_new_table,
        c.agent_code                  AS agent_code_new_table, 
        c.prepaid_area                AS prepaid_area_new_table, 
        c.prepaid_market              AS prepaid_market_new_table, 
        c.trial_group                 AS trial_group_new_table,
        c.prepaid_region              AS prepaid_region_new_table, 
        c.ism                         AS ism_new_table,
        c.account_owner               AS account_owner_new_table,
        c.parent_account              AS parent_account_new_table,
        c.account_id_2                AS account_id_2_new_table, 
        c.prepaid_door_type           AS prepaid_door_type_new_table,
        c.account_name                AS account_name_new_table,
        c.account_address             AS account_address_new_table,
        c.account_city                AS account_city_new_table,
        c.acccount_state_province     AS acccount_state_province_new_table,
        c.account_zip_postal_code     AS account_zip_postal_code_new_table,
        c.phone_number                AS phone_number_new_table, 
        c.prepaid_status              AS prepaid_status_new_table,
        c.prepaid_open_date           AS prepaid_open_date_new_table,
        c.dealer_profile_id           AS dealer_profile_id_new_table, 
        c.location_name               AS location_name_new_table,
        c.sales_channel               AS sales_channel_new_table, 
        c.status_text                 AS status_text_new_table, 
        c.date_onboarded              AS date_onboarded_new_table,
        c.ma_rep_name                 AS ma_rep_name_new_table 
FROM boost_dealer_data_new c
INNER JOIN (
SELECT 
       a.sales_portal_id,
       a.account_address,
       a.account_city,
       a.acccount_state_province,
       a.account_zip_postal_code,
       a.prepaid_region
FROM boost_dealer_data a 
LEFT JOIN boost_dealer_data_new b ON (a.sales_portal_id = b.sales_portal_id)
WHERE b.id IS NULL 
) d ON (  c.account_address = d.account_address
        AND 
         c.account_zip_postal_code = d.account_zip_postal_code
        )
) AS b ON (a.sales_portal_id = b.sales_portal_id_old_table)
SET a.sales_portal_id = b.sales_portal_id_new_table,
    a.account_id = CASE 
        WHEN  a.account_id <=> b.account_id_new_table
            OR 
              b.account_id_new_table IS NULL              THEN a.account_id
         WHEN a.account_id <> b.account_id_new_table      THEN b.account_id_new_table
                                                          ELSE b.account_id_new_table
    END,
    a.account_id_1= CASE 
        WHEN  a.account_id_1 <=> b.account_id_1_new_table
            OR 
              b.account_id_1_new_table IS NULL              THEN a.account_id_1
         WHEN a.account_id_1 <> b.account_id_1_new_table    THEN b.account_id_1_new_table
                                                            ELSE b.account_id_1_new_table
    END,
    a.retailer_acc= CASE 
        WHEN  a.retailer_acc <=> b.retailer_acc_new_table
            OR 
              b.retailer_acc_new_table IS NULL              THEN a.retailer_acc
         WHEN a.retailer_acc <> b.retailer_acc_new_table    THEN b.retailer_acc_new_table
                                                            ELSE b.retailer_acc_new_table
    END,
    a.terminal_id= CASE 
        WHEN  a.terminal_id <=> b.terminal_id_new_table
            OR 
              b.terminal_id_new_table IS NULL               THEN a.terminal_id
         WHEN a.terminal_id <> b.terminal_id_new_table      THEN b.terminal_id_new_table
                                                            ELSE b.terminal_id_new_table
    END,
    a.agent_code= CASE 
        WHEN  a.agent_code <=> b.agent_code_new_table 
            OR 
              b.agent_code_new_table  IS NULL                THEN a.agent_code
         WHEN a.agent_code <> b.agent_code_new_table         THEN b.agent_code_new_table 
                                                             ELSE b.agent_code_new_table 
    END,
    a.prepaid_area= CASE 
        WHEN   a.prepaid_area <=> b.prepaid_area_new_table
             OR 
              b.prepaid_area_new_table IS NULL                THEN a.prepaid_area
         WHEN a.prepaid_area <> b.prepaid_area_new_table      THEN b.prepaid_area_new_table
                                                              ELSE b.prepaid_area_new_table
    END,
    a.prepaid_market = CASE 
        WHEN   a.prepaid_market <=> b.prepaid_market_new_table
             OR 
              b.prepaid_market_new_table IS NULL              THEN a.prepaid_market
         WHEN a.prepaid_market <> b.prepaid_market_new_table  THEN b.prepaid_market_new_table
                                                              ELSE b.prepaid_market_new_table
    END,
    a.prepaid_region = CASE 
        WHEN   a.prepaid_region <=> b.prepaid_region_new_table
             OR 
              b.prepaid_region_new_table IS NULL              THEN a.prepaid_region
         WHEN a.prepaid_region <> b.prepaid_region_new_table  THEN b.prepaid_region_new_table
                                                              ELSE b.prepaid_region_new_table
    END,
    a.ism = CASE 
        WHEN   a.ism <=> b.ism_new_table
             OR 
              b.ism_new_table IS NULL                         THEN a.ism
         WHEN a.ism <> b.ism_new_table                        THEN b.ism_new_table
                                                              ELSE b.ism_new_table
    END,
    a.account_owner= CASE 
        WHEN   a.account_owner <=> b.account_owner_new_table
             OR 
              b.account_owner_new_table IS NULL               THEN a.account_owner
         WHEN a.account_owner <> b.account_owner_new_table    THEN b.account_owner_new_table
                                                              ELSE b.account_owner_new_table
    END,
     a.parent_account= CASE 
        WHEN   a.parent_account <=> b.parent_account_new_table
             OR 
              b.parent_account_new_table IS NULL               THEN a.parent_account
         WHEN a.parent_account <> b.parent_account_new_table   THEN b.parent_account_new_table
                                                               ELSE b.parent_account_new_table
    END,
    a.account_id_2= CASE 
        WHEN   a.account_id_2 <=> b.account_id_2_new_table
             OR 
              b.account_id_2_new_table IS NULL              THEN a.account_id_2
         WHEN a.account_id_2 <> b.account_id_2_new_table    THEN b.account_id_2_new_table
                                                            ELSE b.account_id_2_new_table
    END,
    a.prepaid_door_type =CASE 
        WHEN   a.prepaid_door_type <=> b.prepaid_door_type_new_table
             OR 
              b.prepaid_door_type_new_table IS NULL                   THEN a.prepaid_door_type
         WHEN a.prepaid_door_type <> b.prepaid_door_type_new_table    THEN b.prepaid_door_type_new_table
                                                                      ELSE b.prepaid_door_type_new_table
    END,
    a.account_name = CASE 
        WHEN   a.account_name <=> b.account_name_new_table
             OR 
              b.account_name_new_table IS NULL                   THEN a.account_name
         WHEN a.account_name <> b.account_name_new_table         THEN b.account_name_new_table
                                                                 ELSE b.account_name_new_table
    END,
    a.account_address = CASE 
        WHEN   a.account_address <=> b.account_address_new_table
             OR 
              b.account_address_new_table IS NULL                   THEN a.account_address
         WHEN a.account_address <> b.account_address_new_table      THEN b.account_address_new_table
                                                                    ELSE b.account_address_new_table
    END,
    a.account_city =CASE 
        WHEN   a.account_city <=> b.account_city_new_table
             OR 
              b.account_city_new_table IS NULL                   THEN a.account_city
         WHEN a.account_city <> b.account_city_new_table         THEN b.account_city_new_table
                                                                 ELSE b.account_city_new_table
    END,
    a.acccount_state_province = CASE 
        WHEN   a.acccount_state_province <=> b.acccount_state_province_new_table
             OR 
              b.acccount_state_province_new_table IS NULL                          THEN a.acccount_state_province
         WHEN a.acccount_state_province <> b.acccount_state_province_new_table     THEN b.acccount_state_province_new_table
                                                                                   ELSE b.acccount_state_province_new_table
    END,
    a.account_zip_postal_code = CASE 
        WHEN   a.account_zip_postal_code <=> b.account_zip_postal_code_new_table
             OR 
              b.account_zip_postal_code_new_table IS NULL                          THEN a.account_zip_postal_code
         WHEN a.account_zip_postal_code <> b.account_zip_postal_code_new_table     THEN b.account_zip_postal_code_new_table
                                                                                   ELSE b.account_zip_postal_code_new_table
    END,
     a.phone_number =CASE 
        WHEN   a.phone_number <=> b.phone_number_new_table
             OR 
              b.phone_number_new_table IS NULL                                    THEN a.phone_number
         WHEN a.phone_number <> b.phone_number_new_table                          THEN b.phone_number_new_table
                                                                                  ELSE b.phone_number_new_table
    END,
    a.prepaid_status =CASE 
        WHEN   a.prepaid_status <=> b.prepaid_status_new_table
             OR 
              b.prepaid_status_new_table IS NULL                                  THEN a.prepaid_status
         WHEN a.prepaid_status <> b.prepaid_status_new_table                      THEN b.prepaid_status_new_table
                                                                                  ELSE b.prepaid_status_new_table
    END,
    a.prepaid_open_date =CASE 
        WHEN   a.prepaid_open_date <=> b.prepaid_open_date_new_table
             OR 
              b.prepaid_open_date_new_table IS NULL                               THEN a.prepaid_open_date
         WHEN a.prepaid_open_date <> b.prepaid_open_date_new_table                THEN b.prepaid_open_date_new_table
                                                                                  ELSE b.prepaid_open_date_new_table
    END,
    a.dealer_profile_id =CASE 
        WHEN   a.dealer_profile_id <=> b.dealer_profile_id_new_table
             OR 
              b.dealer_profile_id_new_table IS NULL                               THEN a.dealer_profile_id
         WHEN a.dealer_profile_id <> b.dealer_profile_id_new_table                THEN b.dealer_profile_id_new_table
                                                                                  ELSE b.dealer_profile_id_new_table
    END,
    a.location_name =CASE 
        WHEN   a.location_name <=> b.location_name_new_table
             OR 
              b.location_name_new_table IS NULL                               THEN a.location_name
         WHEN a.location_name <> b.location_name_new_table                    THEN b.location_name_new_table
                                                                              ELSE b.location_name_new_table
    END,
    a.sales_channel =CASE 
        WHEN   a.sales_channel <=> b.sales_channel_new_table
             OR 
              b.sales_channel_new_table IS NULL                               THEN a.sales_channel
         WHEN a.sales_channel <> b.sales_channel_new_table                    THEN b.sales_channel_new_table
                                                                              ELSE b.sales_channel_new_table
    END,
    a.status_text =CASE 
        WHEN   a.status_text <=> b.status_text_new_table
             OR 
              b.status_text_new_table IS NULL                               THEN a.status_text
         WHEN a.status_text <> b.status_text_new_table                      THEN b.status_text_new_table
                                                                            ELSE b.status_text_new_table
    END,
    a.date_onboarded = CASE 
        WHEN   a.date_onboarded <=> b.date_onboarded_new_table
             OR 
              b.date_onboarded_new_table IS NULL                            THEN a.date_onboarded
         WHEN a.date_onboarded <> b.date_onboarded_new_table                THEN b.date_onboarded_new_table
                                                                            ELSE b.date_onboarded_new_table
    END,
    a.ma_rep_name = CASE 
        WHEN   a.ma_rep_name <=> b.ma_rep_name_new_table
             OR 
              b.ma_rep_name_new_table IS NULL                  THEN a.ma_rep_name
         WHEN a.ma_rep_name <> b.ma_rep_name_new_table         THEN b.ma_rep_name_new_table
                                                               ELSE b.ma_rep_name_new_table
    END 


    a.updated_at        = CURRENT_TIMESTAMP




INSERT INTO boost_dealer_data  (
        account_id,
        sales_portal_id,
        account_id_1,
        retailer_acc,
        terminal_id,
        agent_code, 
        prepaid_area, 
        prepaid_market,
        -- trial_group,
        prepaid_region, 
        ism,
        account_owner,
        parent_account,
        account_id_2, 
        prepaid_door_type,
        account_name,
        account_address,
        account_city,
        acccount_state_province,
        account_zip_postal_code,
        phone_number, 
        prepaid_status,
        prepaid_open_date,
        dealer_profile_id, 
        location_name,
        sales_channel, 
        status_text, 
        date_onboarded,
        trial_group,
        created_at,
        updated_at 
)
  SELECT 
        a.account_id,
        a.sales_portal_id,
        a.account_id_1,
        a.retailer_acc,
        a.terminal_id,
        a.agent_code, 
        a.prepaid_area, 
        a.prepaid_market,
        -- a.trial_group,
        a.prepaid_region, 
        a.ism,
        a.account_owner,
        a.parent_account,
        a.account_id_2, 
        a.prepaid_door_type,
        a.account_name,
        a.account_address,
        a.account_city,
        a.acccount_state_province,
        a.account_zip_postal_code,
        a.phone_number, 
        a.prepaid_status,
        a.prepaid_open_date,
        a.dealer_profile_id, 
        a.location_name,
        a.sales_channel, 
        a.status_text, 
        a.date_onboarded,
        (SELECT trial_group 
          FROM boost_dealer_data
          WHERE prepaid_market = a.prepaid_market
          LIMIT 1 
        )  AS trial_group,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP 
  FROM boost_dealer_data_new a 
  LEFT JOIN boost_dealer_data b ON (a.sales_portal_id = b.sales_portal_id)
  WHERE b.id IS NULL 




INSERT INTO boost_dealer_data  (
        account_id,
        sales_portal_id,
        account_id_1,
        retailer_acc,
        terminal_id,
        agent_code,
        prepaid_area,
        prepaid_market,
        prepaid_region,
        ism,
        account_owner,
        parent_account,
        account_id_2,
        prepaid_door_type,
        account_name,
        account_address,
        account_city,
        acccount_state_province,
        account_zip_postal_code,
        phone_number,
        prepaid_status,
        prepaid_open_date,
        dealer_profile_id,
        location_name,
        sales_channel,
        status_text,
        date_onboarded,
        ma_rep_name,
        trial_group,
        created_at,
        updated_at
)
  SELECT
        a.account_id,
        a.sales_portal_id,
        a.account_id_1,
        a.retailer_acc,
        a.terminal_id,
        a.agent_code,
        a.prepaid_area,
        a.prepaid_market,
        a.prepaid_region,
        a.ism,
        a.account_owner,
        a.parent_account,
        a.account_id_2,
        a.prepaid_door_type,
        a.account_name,
        a.account_address,
        a.account_city,
        a.acccount_state_province,
        a.account_zip_postal_code,
        a.phone_number,
        a.prepaid_status,
        a.prepaid_open_date,
        a.dealer_profile_id,
        a.location_name,
        a.sales_channel,
        a.status_text,
        a.date_onboarded,
        a.ma_rep_name,
        (SELECT trial_group
          FROM boost_dealer_data
          WHERE prepaid_market = a.prepaid_market
          LIMIT 1
        )  AS trial_group,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
  FROM boost_dealer_data_new a
  LEFT JOIN boost_dealer_data b ON (a.sales_portal_id = b.sales_portal_id)
  WHERE b.id IS NULL








  


