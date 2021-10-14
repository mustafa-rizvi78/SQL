ALTER TABLE mustafa_test.dbo.Applications
ALTER COLUMN [Applicant__c] nVARCHAR(255)
COLLATE SQL_Latin1_General_CP1_CS_AS

CREATE TABLE Dim_Contact
(
 Contact_Id                       INT IDENTITY(1,1) NOT NULL,
 Contact_Id_Code                  VARCHAR(150) NOT NULL,
 
 /*  Contact related information */
 First_Name                       VARCHAR(150),
 Full_Name                        VARCHAR(150),
 Last_Name                        VARCHAR(150),
 Middle_Name                      VARCHAR(100),
 Gender                           VARCHAR(10),
 Birthday                         DATE,
 Age                              FLOAT,
 Email                            VARCHAR(100),
 Country_of_Citizenship           VARCHAR(100), 
 Home_Phone                       VARCHAR(100),
 Home_Phone_Copy                  VARCHAR(100),
 Phone                            VARCHAR(100),
 Mobile_Phone                     VARCHAR(100),
 Fax                              VARCHAR(100),
 MailingCity                      VARCHAR(100),
 MailingCountry                   VARCHAR(100),
 MailingState                     VARCHAR(150),
 MailingStreet                    VARCHAR(250),
 MailingPostalCode                VARCHAR(100),
 MailingLongitude                 VARCHAR(100),
 MailingLatitude                  VARCHAR(100),
 Military                         VARCHAR(3),
 Military_Branch                  VARCHAR(100),
 Military_Status                  VARCHAR(100),
  
  /* Professional Info */
 Current_Employer                 VARCHAR(150),
 Income                           VARCHAR(20),
 Industry                         VARCHAR(100),
 Profession                       VARCHAR(100),
 Work_Phone_Number                VARCHAR(100),
 Work_Extension                   VARCHAR(100),
 Years_of_Experience              VARCHAR(40),
 Title                            VARCHAR(150),
 
 /* Preferred Number */
 Preferred_Number                  VARCHAR(100),
 Preferred_Time_To_Contact         VARCHAR(100), 
 
 /* Other ?? */
 OtherCity                         VARCHAR(100),
 Other_First_Name                  VARCHAR(100),
 Other_Last_Name                   VARCHAR(100),
 Other_Phone                       VARCHAR(100),
 Other_State                       VARCHAR(100),
 Other_Country                     VARCHAR(100),
 Other_Street                      VARCHAR(150),
 Other_Postal_Code                 VARCHAR(100),
 
 /* Current Data */
 Current_Registration_Status       VARCHAR(100),
 Current_Term                      VARCHAR(100),
 Current_Term_End_Date             DATE /* date */,
 Current_Units                     VARCHAR(10),
 
 /* Inquiry Related */
 Intended_Level                     VARCHAR(100),
 Intended_Location                  VARCHAR(100),
 Intended_Start_Term                VARCHAR(100),
 Program_of_Interest                VARCHAR(100),
 Level_Completed                    VARCHAR(100),
 Most_Recent_Inquiry_Date           DATETIME,
 Time_Frame                         VARCHAR(50),
 
 /* Source and Channel */
 Lead_Source                        VARCHAR(100),
 Lead_Status                        VARCHAR(100),
 Origin_Channel                     VARCHAR(100),
 Origin_Source                      VARCHAR(100),
  
 /* Other */
 Contact_Priority                   VARCHAR(100),
 Contact_Status                     VARCHAR(100),
 Conact_Type                        VARCHAR(100),
 Stage                              VARCHAR(100),
  
 /* Internation Student? */
 Immigration_Status                 VARCHAR(100),
 International_Credentials          VARCHAR(50),
 International_Phone_Number         VARCHAR(100),
 International_Student              VARCHAR(50),
 I20_Effective_Date                 DATE,
 I20_Expiration_Date                DATE,
 OPT_Start_Date                     DATE,
 OPT_End_Date                       DATE,
 Tuition_Deposit                    VARCHAR(30),
 Tuition_Deposit_Date               DATE,
 Tuition_Deposit_Term               VARCHAR(100),
 Work_Study                         VARCHAR(100),
 Visa_Type                          VARCHAR(100),
 Visa_Sponsor                       VARCHAR(100),
 
 /* Registration Info */
 StudentID                          VARCHAR(15),
 GGU_ID                             VARCHAR(15),
 Student_ID_GGU_ID_Dupe_Conversion  VARCHAR(15),
 Reg_Date                           DATETIME,
 First_Registration_Date            DATETIME,
 Registered_Level                   VARCHAR(100),
 Cumulative_GPA                     VARCHAR(100),
 Units_Complete                     VARCHAR(100),
 Last_Redg_Term                     VARCHAR(50),
 First_Redg_Term                    VARCHAR(50),
 Revenue                            FLOAT,
 
 /* Salesforce Create specific */
 Create_Date                        DATE /* date */,
 Last_Activity_Date                 DATE /* date */,
 Last_Modified_Date                 DATE /* date */, 
 
 /* Datawarehouse specifics */
 Source_System_Code                 TINYINT,
 Create_TimeStamp                   DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp                   DATETIME DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY CLUSTERED (Contact_Id)  
)

GO

 CREATE TABLE Dim_Date
 (
   Date_Id              INT IDENTITY(1,1) NOT NULL,
  [Date]                DATE,
  [Day]                 TINYINT,
  [Day_of_the_week]     TINYINT,
  [Day_Name]            VARCHAR(10),
  [Week_Number]         TINYINT,
  [Month]               TINYINT,
  [Month_Name]          VARCHAR(10),
  [Quarter]             CHAR(2),
  [Year]                SMALLINT,
  Create_TimeStamp      DATETIME DEFAULT CURRENT_TIMESTAMP,
  Update_TimeStamp      DATETIME DEFAULT CURRENT_TIMESTAMP
  PRIMARY KEY CLUSTERED (Date_Id)
 )
 
 GO

/*
 CREATE TABLE Dim_Area_of_Interest
(
 Area_of_Interest_Id  INT IDENTITY(1,1) NOT NULL,
 Area_of_Interest     VARCHAR(150),
 Create_TimeStamp     DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp     DATETIME DEFAULT CURRENT_TIMESTAMP
 )
  
 GO    
    
  CREATE TABLE Dim_Intended_Level
(
 Intended_Level_Id   INT IDENTITY(1,1) NOT NULL,
 Intended_Level      VARCHAR(150),
 Create_TimeStamp    DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp    DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 GO
 */
 CREATE TABLE Dim_Channel
(
 Channel_Id        INT IDENTITY(1,1) NOT NULL,
 Channel           VARCHAR(150),
 Create_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 GO
 
 CREATE TABLE Dim_Source
(
 Source_Id         INT IDENTITY(1,1) NOT NULL,
 Source            VARCHAR(150),
 Create_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 
 GO
 
 
 CREATE TABLE Dim_VisaType
(
 VisaType_Id       INT IDENTITY(1,1) NOT NULL,
 VisaType          VARCHAR(150),
 Create_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 
 GO
 
 CREATE TABLE Dim_Lead_Status
(
 Lead_Status_Id    INT IDENTITY(1,1) NOT NULL,
 Lead_Status       VARCHAR(150),
 Lead_Status_Group VARCHAR(100),
 Create_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 GO
 
 CREATE TABLE Dim_Area_of_Interest_Intended_Level
(
 Area_of_Interest_Intended_Level_Id           INT IDENTITY(1,1) NOT NULL,
 Area_of_Interest                             VARCHAR(150),
 Intended_Level                               VARCHAR(50),
 Area_of_Interest_Intended_Level_Grouping     VARCHAR(100),
 Create_TimeStamp                             DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp                             DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 GO
 
 
 CREATE TABLE Dim_International
(
 International_Id          INT IDENTITY(1,1) NOT NULL,
 International              TINYINT,
 International_Group        VARCHAR(100), 
 Create_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP,
 Update_TimeStamp  DATETIME DEFAULT CURRENT_TIMESTAMP
 )
 
 
 GO
 
 
 
 MERGE INTO Dim_Area_of_Interest_Intended_Level AS target
 USING
     (
            SELECT
                 DISTINCT
                       ISNULL(Area_of_Interest_del__c,'Unknown')                 AS Area_of_Interest,
                       ISNULL(Intended_Level__c,'NS')                            AS Intended_Level,
                       CASE
                             WHEN (
                                     (
                                           Intended_Level__c IS NULL
                                       OR
                                           Intended_Level__c = 'Unknown'
                                     )    
                                   OR
                                     (
                                          Area_of_Interest_del__c IS NULL
                                      OR
                                          Area_of_Interest_del__c = 'Unknown'
                                     )
                                   OR
                                     (
                                         Intended_Level__c = 'NS'
                                     OR
                                         Area_of_Interest_del__c IN ('Unknown','Not Offered')
                                     )                                                                      
                                  )                                                                          THEN 'Non Matriculated'
                            WHEN Intended_Level__c = 'Bachelors'                                             THEN 'UGP'
                            WHEN Area_of_Interest_del__c = 'Accounting'                                      THEN 'SOA GR'                      
                            WHEN (
                                     Intended_Level__c IN ('SJD','LAW','LLM','JD Part-time Evening Program') 
                                  OR 
                                     Area_of_Interest_del__c = 'Law' 
                                  )                                                                          THEN 'LAW' 
                            WHEN     (  
                                           Intended_Level__c IN ('Doctorate','Masters')                                                 
                                      AND 
                                           Area_of_Interest_del__c NOT IN ('Accounting','Taxation','Law')       
                                      )                                                                      THEN 'ASOB GR'
                            WHEN    Area_of_Interest_del__c ='Taxation'                                      THEN 'Taxation'
                                                                                                             ELSE  Area_of_Interest_del__c
                        END  [NewGrouping]
           FROM [mustafa_test].[dbo].[ContractExport_1]
    ) AS source
  ON (      target.Area_of_Interest                          = source.Area_of_Interest  
      AND   target.Intended_Level                            = source.Intended_Level
      AND   target.Area_of_Interest_Intended_Level_Grouping  = source.NewGrouping
     )  
  WHEN NOT MATCHED THEN
  INSERT
         (
          Area_of_Interest,
          Intended_Level,
          Area_of_Interest_Intended_Level_Grouping,
          Create_TimeStamp,
          Update_TimeStamp          
         )
  VALUES
       (
        source.Area_of_Interest,
        source.Intended_Level,
        source.NewGrouping,
        GETDATE(),
        GETDATE()
       );
  
  
  
    GO
 
 
 /*
   INSERT INTO Dim_Area_of_Interest
   (
       Area_of_Interest
   )
 
        SELECT DISTINCT ISNULL(Area_of_Interest_del__c,'Unknown')
        FROM [mustafa_test].[dbo].[ContractExport_1]
 
 GO

 
   INSERT INTO Dim_Intended_Level
   (
      Intended_Level
    )
    SELECT DISTINCT ISNULL(Intended_Level__c,'NS')
    FROM [mustafa_test].[dbo].[ContractExport_1]
    
    GO
    
*/

MERGE INTO Dim_Channel AS target
USING
     (
        SELECT
              DISTINCT ISNULL(Origin_Channel__c,'C-UNKNOWN')  AS Channel
        FROM [mustafa_test].[dbo].[ContractExport_1]
     ) AS source
ON
   (
     target.Channel = source.Channel    
   )
WHEN NOT MATCHED THEN
 INSERT
       (
        Channel,
        Create_TimeStamp,
        Update_TimeStamp
       )
 VALUES
       (
        source.Channel,
        GETDATE(),
        GETDATE()
       );    
 GO


MERGE INTO Dim_Source AS target
USING
     (
        SELECT
               DISTINCT ISNULL(Origin_Source__c,'S-UNKNOWN') AS src
        FROM [mustafa_test].[dbo].[ContractExport_1]
     ) AS source
ON  (target.Source = source.src)
WHEN NOT MATCHED THEN
INSERT
      (
       Source,
       Create_TimeStamp,
       Update_TimeStamp
      )
VALUES
      (
       source.src,
       GETDATE(),
       GETDATE()
      );
    
    GO
    
 
MERGE INTO Dim_VisaType AS target 
USING
    ( 
    SELECT
          DISTINCT ISNULL(Visa_Type__c,'Unknown') AS VisaType
    FROM [mustafa_test].[dbo].[ContractExport_1]
    ) AS source
ON (target.VisaType = source.VisaType)
WHEN NOT MATCHED THEN
INSERT
      (
       VisaType,
       Create_TimeStamp,
       Update_TimeStamp
      )
VALUES
     (
      source.VisaType,
      GETDATE(),
      GETDATE()
      
     );
    
    GO   
 
 
MERGE INTO Dim_Lead_Status AS target
USING
    (
        SELECT DISTINCT ISNULL(Lead_Status__c,'Unknown') AS Lead_Status,
                        CASE
                            WHEN Lead_Status__c IN (
                                                    'Attempted Contact 1','Attempted Contact 2','Attempted Contact 3',
                                                    'Auto F/J Email Sent','Dropped All Courses','Initial Contact',
                                                    'Law Inquiry','Not Admitted','Not Attempted','Not Enrolled',
                                                    'Not Ready to Apply','Open Enrollment','Pre Hand-Off',
                                                    'Ready to Apply','Relationship in Development','Pre Retention Transfer',
                                                    'Transfered to Retention'
                                                    )   
                                                 OR
                                                   (
                                                    Lead_Status__c IS NULL
                                                   ) 
                                                              THEN 'Active Lead'
                            WHEN Lead_Status__c = 'Bad Lead'  THEN 'Bad Lead'
                            WHEN Lead_Status__c IN (
                                                    'Canceled/Withdrawn','Denied','Expired',
                                                    'Inactive','Inactive (4th Attempt Made)',
                                                    'Post Hand-Off'
                                                   )              THEN 'Inactive Lead'
                            WHEN Lead_Status__c = 'Lost Lead'     THEN 'Lost Lead'
                            WHEN Lead_Status__c = 'Not Qualified' THEN 'Not Qualified'
                                                                  ELSE Lead_Status__c
                                                   
                        END         AS Lead_Status_Group  
        FROM [mustafa_test].[dbo].[ContractExport_1]
    ) AS source
 ON (
          target.Lead_Status       = source.Lead_Status
     AND  target.Lead_Status_Group = source.Lead_Status_Group
    )
 WHEN NOT MATCHED THEN
 INSERT
      (
       Lead_Status,
       Lead_Status_Group,
       Create_TimeStamp,
       Update_TimeStamp
      )
 VALUES
      (
        source.Lead_Status,
        source.Lead_Status_Group,
        GETDATE(),
        GETDATE()
      );
 
  GO
    

MERGE INTO Dim_International AS target
USING
    (
     SELECT DISTINCT
                   International_Student__c AS International,
                   CASE
                        WHEN International_Student__c = 1      THEN 'Intl'
                        WHEN
                            (
                              International_Student__c = 0
                            OR
                              International_Student__c IS NULL
                            )                                  THEN 'Domestic'
                   END  AS International_Group
    FROM [mustafa_test].[dbo].[ContractExport_1]
    ) AS source
ON (target.International  = source.International)
WHEN NOT MATCHED THEN
INSERT
      (
       International,
       International_Group,
       Create_TimeStamp,
       Update_TimeStamp
      )
VALUES
     (
     source.International,
     source.International_Group,
     GETDATE(),
     GETDATE()
     );

  GO 
  
  
  
  
    /* Populating Date Dimension Table */
    
  DECLARE @StartDate DATETIME = '07/01/2009' 
  DECLARE @EndDate   DATETIME = '06/30/2020'
  
  BEGIN TRANSACTION  
    WHILE (@StartDate < @EndDate)
    BEGIN    
            INSERT INTO Dim_Date (
                                  [Date],
                                  [Day],
                                  [Day_of_the_week],
                                  [Day_Name],
                                  [Week_Number],
                                  [Month],
                                  [Month_Name],
                                  [Quarter],
                                  [Year]
                                 )
                     VALUES
                                (
                                  @StartDate,
                                  DATEPART(DD,@StartDate),
                                  DATEPART(DW,@StartDate),
                                  DATENAME(DW,@StartDate),
                                  DATEPART(WK,@StartDate),
                                  DATEPART(MM,@StartDate),
                                  DATENAME(MM,@StartDate),
                                  DATEPART(QQ,@StartDate),
                                  DATEPART(YYYY,@StartDate)                                  
                                )
                         
            SET @StartDate = DATEADD(DD,1,@StartDate)
    END        
  COMMIT TRANSACTION
  
  
  
  
  
  
  
 INSERT INTO Dim_Contact
(
 Contact_Id_Code,

 /*  Contact related information */
 First_Name,
 Full_Name,
 Last_Name,
 Middle_Name,
 Gender,
 Birthday,
 Age,
 Email,
 Country_of_Citizenship, 
 Home_Phone,
 Home_Phone_Copy,
 Phone,
 Mobile_Phone,
 Fax,
 MailingCity,
 MailingCountry,
 MailingState,
 MailingStreet,
 MailingPostalCode,
 MailingLongitude,
 MailingLatitude,
 Military,
 Military_Branch,
 Military_Status,
  
  /* Professional Info */
 Current_Employer,
 Income,
 Industry,
 Profession,
 Work_Phone_Number,
 Work_Extension,
 Years_of_Experience,
 Title,
 
 /* Preferred Number */
 Preferred_Number,
 Preferred_Time_To_Contact, 
 
 /* Other ?? */
 OtherCity,
 Other_First_Name,
 Other_Last_Name,
 Other_Phone,
 Other_State,
 Other_Country,
 Other_Street,
 Other_Postal_Code,
 
 /* Current Data */
 Current_Registration_Status,
 Current_Term,
 Current_Term_End_Date,
 Current_Units,
 
 /* Inquiry Related */
 Intended_Level,
 Intended_Location,
 Intended_Start_Term,
 Program_of_Interest,
 Level_Completed,
 Most_Recent_Inquiry_Date,
 Time_Frame,
 
 /* Source and Channel */
 Lead_Source,
 Lead_Status,
 Origin_Channel,
 Origin_Source,
  
 /* Other */
 Contact_Priority,
 Contact_Status,
 Conact_Type,
 Stage,
  
 /* Internation Student? */
 Immigration_Status,
 International_Credentials,
 International_Phone_Number,
 International_Student,
 I20_Effective_Date,
 I20_Expiration_Date,
 OPT_Start_Date,
 OPT_End_Date,
 Tuition_Deposit,
 Tuition_Deposit_Date,
 Tuition_Deposit_Term,
 Work_Study,
 Visa_Type,
 Visa_Sponsor,
 
 /* Registration Info */
 StudentID,
 GGU_ID,
 Student_ID_GGU_ID_Dupe_Conversion,
 Reg_Date,
 First_Registration_Date,
 Registered_Level,
 Cumulative_GPA,
 Units_Complete,
 Last_Redg_Term,
 First_Redg_Term,
 
 /* Salesforce Create specific */
 Create_Date,
 Last_Activity_Date,
 Last_Modified_Date, 
 
 /* Datawarehouse specifics */
 Source_System_Code
 
)
 SELECT
         c.Id,
         FirstName,
         c.Name,
         LastName,
         Middle_Name__c,
         Gender__c,
         Birthdate,
         Age__c,
         Email,
         Country_of_Citizenship__c, 
         HomePhone,
         Home_Phone_copy__c,
         Phone,
         MobilePhone,
         Fax,
         MailingCity,
         MailingCountry,
         MailingState,
         MailingStreet,
         MailingPostalCode,
         MailingLongitude,
         MailingLatitude,
         Military__c,
         Military_Branch__c,
         Military_Status__c,
         Current_Employer__c,
         Income__c,
         Industry__c,
         Profession__c,
         Work_Phone_Number__c,
         Work_Extension__c,
         Years_of_Work_Experience__c,
         Title, 
         Preferred_Number__c,
         Preferred_Time_To_Contact__c,  
         OtherCity,
         Other_First_Name__c,
         Other_Last_Name__c,
         OtherPhone,
         OtherState,
         OtherCountry,
         OtherStreet,
         OtherPostalCode,
         Current_Registration_Status__c,
         Current_Term__c,
         Current_Term_End_Date__c,
         Current_Units__c, 
         Intended_Level__c,
         Intended_Location__c,
         Intended_Start_Term__c,
         Area_of_Interest_del__c,
         Level_Completed__c,
         Most_Recent_Inquiry_Date__c,
         Time_Frame__c,
         Origin_Source__c,
         Lead_Status__c,
         Origin_Channel__c,
         Origin_Source__c, 
         Contact_Priority__c,
         Contact_Status__c,
         Contact_Type__c,
         Stage__c,
         Immigration_Status__c,
         International_Credentials__c,
         International_Phone_Number__c,
         International_Student__c,
         I20_Effective_Date__c,
         I20_Expiration_Date__c,
         OPT_End_Date__c,
         OPT_Start_Date__c,
         Tuition_Deposit__c,
         Tuition_Deposit_Date__c,
         Tuition_Deposit_Term__c,
         Work_Study__c,
         Visa_Type__c,
         Visa_Sponsor__c,
         StudentID__c,
         GGU_ID__c,
         Student_ID_GGU_ID_Dupe_Conversion__c,
         Reg_Date__c,
         First_Registration_Date__c,
         Registered_Level__c,
         Cumulative_GPA__c,
         Units_Complete__c,
         tl.Reporting_Term__c,     -- Last_Regd_Term__c,
         tf.Reporting_Term__c,     -- First_Regd_Term__c,
         c.CreatedDate,
         c.LastActivityDate,
         c.LastModifiedDate,  
         1 -- Source system = 1 - Salesforce, 2 - Colleague
 FROM [mustafa_test].[dbo].[ContractExport_1] c
 LEFT JOIN [mustafa_test].[dbo].[Terms] tf ON (c.First_Regd_Term__c = tf.Id)
 LEFT JOIN [mustafa_test].[dbo].[Terms] tl ON (c.Last_Regd_Term__c  = tl.Id)
 
 
 
  CREATE TABLE Fact_Inquiry
 (
   Fact_Id                                    INT IDENTITY(1,1) NOT NULL, 
   -- These ID columns make up the unique row for the Fact table
   Contact_Id                                 INT,
   Date_Id                                    INT,
   Area_of_Interest_Intended_Level_Id         INT,
   Lead_Status_Id                             INT,
   Source_Id                                  INT,
   VisaType_Id                                INT,
   International_Id                           INT,
   Channel_Id                                 INT,
   -- These flags are necessary for counting the DISTINCT COUNT
   Inquiry_Flag                               TINYINT DEFAULT 1,
   Application_Flag                           TINYINT,
   Admit_Flag                                 TINYINT,
   Enrolled_Flag                              TINYINT,
   -- Time difference measures.
   -- These measures are essential for difference between inuqiry date and the applied and admit dates
   TimeApplied                                FLOAT,
   TimeAdmitted                               FLOAT,
   TimeEnrolled                               FLOAT,
   -- Application and Admit Count measures.
   Degree_Application_Count                   INT,
   NonDegree_Application_Count                INT,
   Degree_Admit_Count                         INT,               
   NonDegree_Admit_Count                      INT,
   Total_Applications                         INT,
   Total_Admits                               INT,  
   -- Timestamp columns for Fact table.   
   Created_Date                               DATETIME DEFAULT CURRENT_TIMESTAMP,
   Updated_Date                               DATETIME DEFAULT CURRENT_TIMESTAMP
  --PRIMARY KEY CLUSTERED (Date_Id)
 )
 
 GO
 
 /* Fact table load statement */
 
 MERGE Fact_Inquiry AS target
 USING
 (
        SELECT
              Contact_Id,
              Date_Id,
              Area_of_Interest_Intended_Level_Id,       
              Lead_Status_Id,
              Source_Id,
              VisaType_Id,
              International_Id,
              Channel_Id,
              Inquiry_Flag,
              Application_Flag,
              Admit_Flag,
              CASE
                    WHEN First_Registration_Date >= dt.[Date] THEN 1
                                                              ELSE 0
              END                                                    AS Enrolled_Flag,                                           
              /* Measures for Fact table */
              DATEDIFF(MM,InquiryDate,Application_Date_Min)          AS TimeApplied,
              CASE
                    WHEN Admit_Date_Min >= dt.[Date] THEN DATEDIFF(MM,InquiryDate,Admit_Date_Min)
                                                     ELSE NULL 
              END                                                    AS TimeAdmitted,              
              -- This check is necessary to avoid any pre existing enrollments
              CASE
                    WHEN First_Registration_Date >= dt.[Date] THEN DATEDIFF(MM,InquiryDate,First_Registration_Date)
                                                              ELSE NULL 
              END                                                     AS TimeEnrolled,     
              ISNULL(Degree_Application_Count,0)                      AS Degree_Application_Count,
              ISNULL(NonDegree_Application_Count,0)                   AS NonDegree_Application_Count,
              ISNULL(Degree_Admit_Count,0)                            AS Degree_Admit_Count,               
              ISNULL(NonDegree_Admit_Count,0)                         AS NonDegree_Admit_Count,
              ISNULL(Total_Applications,0)                            AS Total_Applications,
              ISNULL(Total_Admits,0)                                  AS Total_Admits,
              GETDATE()                                               AS Created_Date,
              GETDATE()                                               AS Updated_Date
        FROM
            ( 
                   SELECT dc.Contact_Id,
                          Area_of_Interest_Intended_Level_Id,                   
                          Lead_Status_Id,
                          Source_Id,
                          VisaType_Id,
                          International_Id,
                          Channel_Id,
                          First_Registration_Date,
                          /* These flags are essential for Distinctly Counting each body */
                          1                                         AS [Inquiry_Flag],
                          CASE
                              WHEN (   ISNULL(Total_Applications,0) > 0
                                    OR
                                       dc.Stage = 'Applied'
                                   )                      THEN 1
                                                          ELSE 0
                          END                                       AS [Application_Flag],
                           CASE
                              WHEN (   ISNULL(Total_Admits,0) > 0
                                    OR
                                       dc.Stage = 'Admitted'
                                   )                      THEN 1
                                                          ELSE 0
                          END                                       AS [Admit_Flag],
                          CASE
                               WHEN Applicant__c IS NULL                              THEN Most_Recent_Inquiry_Date
                               -- This should not be happening but data is little funky, hence this is necessary
                               WHEN (
                                          Most_Recent_Inquiry_Date IS NULL
                                     AND
                                         Application_Date_Min IS NOT NULL
                                    )                                                 THEN Application_Date_Min
                               WHEN (Most_Recent_Inquiry_Date > Application_Date_Min) THEN
                                                                                          CASE
                                                                                              WHEN (    DATEPART(YYYY,Most_Recent_Inquiry_Date)  = DATEPART(YYYY,Application_Date_Min)
                                                                                                    AND
                                                                                                       (
                                                                                                           (
                                                                                                                 DATEPART(MM,Most_Recent_Inquiry_Date) BETWEEN 7 AND 12
                                                                                                              AND
                                                                                                                 DATEPART(MM,Application_Date_Min)     BETWEEN 7 AND 12
                                                                                                           )
                                                                                                        OR                                                                                             
                                                                                                           (
                                                                                                                 DATEPART(MM,Most_Recent_Inquiry_Date) BETWEEN 1 AND 6
                                                                                                              AND
                                                                                                                 DATEPART(MM,Application_Date_Min)     BETWEEN 1 AND 6
                                                                                                           )                                                                                            
                                                                                                           
                                                                                                       )
                                                                                                    )      THEN  Application_Date_Min
                                                                                                           ELSE  COALESCE(Application_Date_Min,Most_Recent_Inquiry_Date)  
                                                                                          END
                                                                                              -- Possibility of Most Recent Inquiry date could be NULL
                                                                                      ELSE    COALESCE(Most_Recent_Inquiry_Date,Application_Date_Min)                  
                                                                  
                          END                                      AS [InquiryDate],
                          Application_Date_Min,
                          Admit_Date_Min,
                          /* Measures for Fact table */
                          Degree_Application_Count,
                          NonDegree_Application_Count,
                          Degree_Admit_Count,               
                          NonDegree_Admit_Count,
                          Total_Applications,
                          Total_Admits       
                   FROM  [mustafa_test].[dbo].[ContractExport_11] AS a  
                   LEFT JOIN   ( 
                                   SELECT
                                        Applicant__c,
                                        Degree_Application_Count,
                                        NonDegree_Application_Count,
                                        Degree_Admit_Count,               
                                        NonDegree_Admit_Count,
                                        COALESCE(Degree_Application_Date_First,Application_Date_First)             AS Application_Date_Min,
                                        COALESCE(Degree_Admit_Date_First,Admit_Date_First)                         AS Admit_Date_Min,
                                        ISNULL(Degree_Application_Count,0) + ISNULL(NonDegree_Application_Count,0) AS Total_Applications,
                                        ISNULL(Degree_Admit_Count,0)       + ISNULL(NonDegree_Admit_Count,0)       AS Total_Admits
                                   FROM
                                         (
                                               SELECT
                                                     Applicant__c,
                                                     COUNT(
                                                           CASE
                                                               WHEN (
                                                                       Program_Code__c NOT LIKE 'CERT%'
                                                                    AND
                                                                       Program_Code__c NOT LIKE 'OPEN%'
                                                                     )
                                                                    AND Application_Date__c IS NOT NULL
                                                                    AND Application_Date__c > '2009-01-01'  THEN Program_Code__c
                                                                                                            ELSE NULL
                                                           END
                                                           )          AS Degree_Application_Count,
                                                     COUNT(
                                                           CASE
                                                               WHEN (
                                                                       Program_Code__c NOT LIKE 'CERT%'
                                                                    AND
                                                                       Program_Code__c NOT LIKE 'OPEN%'
                                                                    )
                                                                    AND Admit_Date__c IS NOT NULL
                                                                    AND Admit_Date__c > '2009-01-01'        THEN Program_Code__c
                                                                                                            ELSE NULL
                                                               END
                                                           )          AS Degree_Admit_Count,
                                                      COUNT(
                                                            CASE
                                                                WHEN (
                                                                       Program_Code__c  LIKE 'CERT%'
                                                                     OR
                                                                      Program_Code__c  LIKE 'OPEN%'
                                                                      )
                                                                      AND Application_Date__c IS NOT NULL
                                                                      AND Application_Date__c > '2009-01-01'  THEN Program_Code__c
                                                                                                              ELSE NULL
                                                            END
                                                           )          AS NonDegree_Application_Count,
                                                       COUNT(
                                                             CASE
                                                                 WHEN (
                                                                        Program_Code__c  LIKE 'CERT%'
                                                                      OR
                                                                        Program_Code__c  LIKE 'OPEN%'
                                                                       )
                                                                       AND Admit_Date__c IS NOT NULL
                                                                       AND Admit_Date__c > '2009-01-01'        THEN Program_Code__c
                                                                                                               ELSE NULL
                                                             END
                                                            )          AS NonDegree_Admit_Count,   
                                                       MIN(
                                                           CASE
                                                               WHEN  (
                                                                          Program_Code__c NOT LIKE 'CERT%'
                                                                      AND
                                                                          Program_Code__c NOT LIKE 'OPEN%'
                                                                     )
                                                                     AND Application_Date__c IS NOT NULL
                                                                     AND Application_Date__c > '2009-01-01'  THEN Application_Date__c
                                                                                                             ELSE NULL
                                                           END
                                                           )          AS Degree_Application_Date_First,
                                                       MIN(
                                                           CASE
                                                               WHEN  (
                                                                         Program_Code__c NOT LIKE 'CERT%'
                                                                      AND
                                                                         Program_Code__c NOT LIKE 'OPEN%'
                                                                     )
                                                                     AND Admit_Date__c IS NOT NULL
                                                                     AND Admit_Date__c > '2009-01-01'       THEN Admit_Date__c
                                                                                                            ELSE NULL
                                                           END
                                                           )          AS Degree_Admit_Date_First,
                                                       MIN(
                                                           CASE
                                                               WHEN      Application_Date__c IS NOT NULL
                                                                     AND Application_Date__c > '2009-01-01'  THEN Application_Date__c
                                                                                                             ELSE NULL
                                                           END
                                                           )          AS Application_Date_First,
                                                       MIN(
                                                           CASE
                                                               WHEN      Admit_Date__c IS NOT NULL
                                                                     AND Admit_Date__c > '2009-01-01'       THEN Admit_Date__c
                                                                                                            ELSE NULL
                                                           END
                                                           )          AS Admit_Date_First                                     
                                               FROM [mustafa_test].[dbo].[Application] a
                                               LEFT JOIN [mustafa_test].[dbo].Programs b ON (b.Id = a.Applied_Program__c)
                                               WHERE Application_Status__c NOT IN ('Cancelled','Expired')
                                               GROUP BY Applicant__c
                                               ) AS a             
                                                                                      
                           ) AS app_main                                                  ON (    a.Id                                       = app_main.Applicant__c)
                   INNER JOIN [mustafa_test].[dbo].Dim_Contact dc                         ON (    a.ID                                       = dc.Contact_Id_Code   )
                   INNER JOIN [mustafa_test].[dbo].Dim_Channel dch                        ON (    ISNULL(dc.Origin_Channel,'C-UNKNOWN')      = dch.Channel          )
                   INNER JOIN [mustafa_test].[dbo].Dim_Area_of_Interest_Intended_Level al ON (    ISNULL(dc.Program_of_Interest,'Unknown')   = al.Area_of_Interest
                                                                                              AND ISNULL(dc.Intended_Level,'NS')             = al.Intended_Level
                                                                                              )             
                   INNER JOIN [mustafa_test].[dbo].Dim_Lead_Status                     ls ON (ISNULL(dc.Lead_Status,'Unknown')               = ls.Lead_Status       )
                   INNER JOIN [mustafa_test].[dbo].Dim_Source                          s  ON (ISNULL(dc.Lead_Source,'S-UNKNOWN')             = s.Source             )
                   INNER JOIN [mustafa_test].[dbo].Dim_VisaType                        vt ON (ISNULL(dc.Visa_Type,'Unknown')                 = vt.VisaType          )
                   INNER JOIN [mustafa_test].[dbo].Dim_International                   it ON (ISNULL(dc.International_Student,0)             = it.International     )
          ) AS main
          INNER JOIN [mustafa_test].[dbo].Dim_Date dt ON (main.[InquiryDate] = dt.[Date])
 ) AS source 
 ON (
        target.Contact_Id                             = source.Contact_Id
    AND target.Date_Id                                = source.Date_Id
    AND target.Area_of_Interest_Intended_Level_Id     = source.Area_of_Interest_Intended_Level_Id 
    AND target.Lead_Status_Id                         = source.Lead_Status_Id
    AND target.Source_Id                              = source.Source_Id
    AND target.VisaType_Id                            = source.VisaType_Id
    AND target.International_Id                       = source.International_Id    
    AND target.Channel_Id                             = source.Channel_Id
    )
 WHEN MATCHED AND   (
                         target.Inquiry_Flag                <> source.Inquiry_Flag
                     OR  target.Application_Flag            <> source.Application_Flag
                     OR  target.Admit_Flag                  <> source.Admit_Flag
                     OR  target.Enrolled_Flag               <> source.Enrolled_Flag
                     OR  target.TimeApplied                 <> source.TimeApplied
                     OR  target.TimeAdmitted                <> source.TimeAdmitted
                     OR  target.TimeEnrolled                <> source.TimeEnrolled
                     OR  target.Degree_Application_Count    <> source.Degree_Application_Count
                     OR  target.NonDegree_Application_Count <> source.NonDegree_Application_Count
                     OR  target.Degree_Admit_Count          <> source.Degree_Admit_Count
                     OR  target.NonDegree_Admit_Count       <> source.NonDegree_Admit_Count
                     OR  target.Total_Applications          <> source.Total_Applications
                     OR  target.Total_Admits                <> source.Total_Admits
                    ) 
 THEN UPDATE SET
                    target.Inquiry_Flag                = source.Inquiry_Flag,
                    target.Application_Flag            = source.Application_Flag,
                    target.Admit_Flag                  = source.Admit_Flag,
                    target.Enrolled_Flag               = source.Enrolled_Flag,
                    target.TimeApplied                 = source.TimeApplied,
                    target.TimeAdmitted                = source.TimeAdmitted,
                    target.TimeEnrolled                = source.TimeEnrolled,
                    target.Degree_Application_Count    = source.Degree_Application_Count,
                    target.NonDegree_Application_Count = source.NonDegree_Application_Count,
                    target.Degree_Admit_Count          = source.Degree_Admit_Count,
                    target.NonDegree_Admit_Count       = source.NonDegree_Admit_Count,
                    target.Total_Applications          = source.Total_Applications,
                    target.Total_Admits                = source.Total_Admits,
                    target.Updated_Date                = GETDATE()
            
 WHEN NOT MATCHED THEN
 INSERT (
         Contact_Id,
         Date_Id,
         Area_of_Interest_Intended_Level_Id,
         Lead_Status_Id,
         Source_Id,
         VisaType_Id,
         International_Id,  
         Channel_Id,
         Inquiry_Flag,
         Application_Flag,
         Admit_Flag,
         Enrolled_Flag,
         TimeApplied,
         TimeAdmitted,
         TimeEnrolled,
         Degree_Application_Count,
         NonDegree_Application_Count,
         Degree_Admit_Count,               
         NonDegree_Admit_Count,
         Total_Applications,
         Total_Admits,
         Created_Date,
         Updated_Date         
        )
 VALUES
        (
         source.Contact_Id,
         source.Date_Id,
         source.Area_of_Interest_Intended_Level_Id,
         source.Lead_Status_Id,
         source.Source_Id,
         source.VisaType_Id,
         source.International_Id,
         source.Channel_Id,
         source.Inquiry_Flag,
         source.Application_Flag,
         source.Admit_Flag,
         source.Enrolled_Flag,
         source.TimeApplied,
         source.TimeAdmitted,
         source.TimeEnrolled,
         source.Degree_Application_Count,
         source.NonDegree_Application_Count,
         source.Degree_Admit_Count,               
         source.NonDegree_Admit_Count,
         source.Total_Applications,
         source.Total_Admits,
         source.Created_Date,
         source.Updated_Date
        );
   
   
    
   
   
   
   
 SELECT 
      fi.Contact_Id            AS [Contact ID],
      ch.Channel               AS [Channel],
      sr.Source                AS [Source],
      c.Country_of_Citizenship AS [Country],
      ls.Lead_Status           AS [Current Status],
      Immigration_Status       AS [F or J Visa],
      c.Gender                 AS [Gender],
      NULL                     AS [Event Type],
      NULL                     AS [Application Date],
      NULL                     AS [Outside Sales Representative],
      dt.[Date]                AS [Inquiry Date],
      al.Intended_Level        AS [Intended Level],
      al.Area_of_Interest      AS [Area of Interest],
      NULL                     AS [Lead Owner],
      c.Stage                  AS [Stage],
      Area_of_Interest_Intended_Level_Grouping AS [Intended Level Group],
      NULL                     AS [Team],
      c.Create_Date            AS [TalismaExtractDate],
      c.Reg_Date               AS [Reg Date],
      fi.Inquiry_Flag,
      fi.Application_Flag,
      fi.Enrolled_Flag,
      fi.Total_Applications,
      fi.Total_Admits,
      fi.TimeApplied,
      fi.TimeAdmitted,
      fi.TimeEnrolled,
      0                        AS [Revenue],
      fi.Admit_Flag                                                          
FROM fact_inquiry fi
INNER JOIN dbo.Dim_Contact c                          ON (fi.Contact_Id = c.Contact_Id)
INNER JOIN dbo.Dim_Date dt                            ON (fi.Date_Id    = dt.Date_Id)
INNER JOIN dbo.Dim_Channel ch                         ON (fi.Channel_Id = ch.Channel_Id)
INNER JOIN dbo.Dim_Source  sr                         ON (fi.Source_Id  = sr.Source_Id)
INNER JOIN dbo.Dim_Area_of_Interest_Intended_Level al ON (fi.Area_of_Interest_Intended_Level_Id = al.Area_of_Interest_Intended_Level_Id)
INNER JOIN dbo.Dim_Lead_Status ls                     ON (fi.Lead_Status_Id = ls.Lead_Status_Id)
WHERE 
      (     
          (  
                 [year] IN (2011)
            AND  
                 [month] BETWEEN 7 AND 12
           )        
       OR  
           (  
                 [year] IN (2012)
            AND  
                 [month] BETWEEN 1 AND 6
           )   
     )       
   
   
BEGIN TRANSACTION
UPDATE c
SET c.Revenue = ISNULL(s.Revenue,0)
FROM ggu_Salesforce_DDS.dbo.Dim_Contact AS c 
INNER JOIN [ggu_students2].[dbo].[q_Student_Revenue] s ON (
                                                          COALESCE(c.[GGU_ID],c.Student_ID_GGU_ID_Dupe_Conversion) = s.Student
                                                          )
COMMIT



USE ggu_Salesforce_DDS
GO

IF OBJECT_ID('Salesforce_Fact','V') IS NOT NULL
DROP VIEW Salesforce_Fact;
GO
CREATE VIEW Salesforce_Fact
AS
SELECT 
      fi.Contact_Id                            AS [Contact ID],
      ch.Channel                               AS [Channel],
      sr.Source                                AS [Source],
      c.Country_of_Citizenship                 AS [Country],
      ls.Lead_Status                           AS [Current Status],
      Immigration_Status                       AS [F or J Visa],
      c.Gender                                 AS [Gender],
      NULL                                     AS [Event Type],
      NULL                                     AS [Application Date],
      NULL                                     AS [Outside Sales Representative],
      dt.[Date]                                AS [Inquiry Date],
      al.Intended_Level                        AS [Intended Level],
      al.Area_of_Interest                      AS [Area of Interest],
      NULL                                     AS [Lead Owner],
      c.Stage                                  AS [Stage],
      Area_of_Interest_Intended_Level_Grouping AS [Intended Level Group],
      NULL                                     AS [Team],
      c.Create_Date                            AS [TalismaExtractDate],
      c.Reg_Date                               AS [Reg Date],
      c.Revenue                                AS [Revenue],
      it.International_Group                   AS [International],
      fi.Inquiry_Flag,
      fi.Application_Flag,
      fi.Enrolled_Flag,
      fi.Total_Applications,
      fi.Total_Admits,
      fi.TimeApplied,
      fi.TimeAdmitted,
      fi.TimeEnrolled,      
      fi.Admit_Flag                                                          
FROM ggu_Salesforce_DDS.dbo.fact_inquiry fi
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Contact c                          ON (fi.Contact_Id                         = c.Contact_Id)
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Date dt                            ON (fi.Date_Id                            = dt.Date_Id)
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Channel ch                         ON (fi.Channel_Id                         = ch.Channel_Id)
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Source  sr                         ON (fi.Source_Id                          = sr.Source_Id)
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Area_of_Interest_Intended_Level al ON (fi.Area_of_Interest_Intended_Level_Id = al.Area_of_Interest_Intended_Level_Id)
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_Lead_Status ls                     ON (fi.Lead_Status_Id                     = ls.Lead_Status_Id) 
INNER JOIN ggu_Salesforce_DDS.dbo.Dim_International it                   ON (fi.International_Id                   = it.International_Id)             
GO
   
   
   